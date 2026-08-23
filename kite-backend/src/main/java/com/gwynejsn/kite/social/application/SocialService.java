package com.gwynejsn.kite.social.application;

import com.gwynejsn.kite.conversation.api.ConversationServiceApi;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.social.application.dto.UserDiscoveryResponse;
import com.gwynejsn.kite.social.application.dto.UserRelationResponse;
import com.gwynejsn.kite.social.domain.RelationId;
import com.gwynejsn.kite.social.domain.UserRelation;
import com.gwynejsn.kite.social.domain.UserRelationRepository;
import com.gwynejsn.kite.social.domain.enums.RelationStatus;
import com.gwynejsn.kite.social.application.exceptions.RelationNotFoundException;
import com.gwynejsn.kite.social.application.exceptions.RelationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static com.gwynejsn.kite.social.infrastructure.SocialMapper.INSTANCE;

@Service
@RequiredArgsConstructor
@Slf4j
public class SocialService {

    private final UserRelationRepository userRelationRepository;
    private final UserProfileServiceApi userProfileServiceApi;
    private final ConversationServiceApi conversationServiceApi;

    /**
     * Create a relation with status pending, or if declined, send another one
     * @param requesterId
     * @param addresseeId
     * @return UserRelationResponse
     */
    public UserRelationResponse sendFriendRequest(UserId requesterId, UserId addresseeId) {
        if (requesterId.equals(addresseeId)) {
            throw new RelationException("Cannot send friend request to yourself");
        }

        Optional<UserRelation> existingRelation = userRelationRepository.findRelationBetween(requesterId, addresseeId);

        if (existingRelation.isPresent()) {
            UserRelation relation = existingRelation.get();
            if (relation.getStatus() == RelationStatus.PENDING || relation.getStatus() == RelationStatus.ACCEPTED) {
                throw new RelationException("Relation already exists between users with status: " + relation.getStatus());
            }
            // if declined previously, re-initiate request
            relation.setRequesterId(requesterId);
            relation.setAddresseeId(addresseeId);
            relation.setStatus(RelationStatus.PENDING);
            relation.setUpdatedAt(Instant.now());
            UserRelation saved = userRelationRepository.save(relation);
            log.info("Re-initiated friend request from {} to {}", requesterId, addresseeId);
            return INSTANCE.toUserRelationResponse(saved);
        }

        UserRelation newRelation = UserRelation.builder()
                .id(new RelationId())
                .requesterId(requesterId)
                .addresseeId(addresseeId)
                .status(RelationStatus.PENDING)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        UserRelation saved = userRelationRepository.save(newRelation);
        log.info("Sent friend request from {} to {}", requesterId, addresseeId);
        return INSTANCE.toUserRelationResponse(saved);
    }

    public UserRelationResponse acceptFriendRequest(UserId currentUserId, RelationId relationId) {
        UserRelation relation = userRelationRepository.findById(relationId)
                .orElseThrow(() -> new RelationNotFoundException("Relation not found: " + relationId));

        if (!relation.getAddresseeId().equals(currentUserId)) {
            throw new RelationException("Only the addressee can accept the friend request");
        }

        if (relation.getStatus() != RelationStatus.PENDING) {
            throw new RelationException("Cannot accept friend request with status: " + relation.getStatus());
        }

        relation.setStatus(RelationStatus.ACCEPTED);
        relation.setUpdatedAt(Instant.now());
        UserRelation saved = userRelationRepository.save(relation);
        log.info("Accepted friend request relation {}", relationId);

        // automatically initialize direct conversation between both users
        try {
            conversationServiceApi.initializeConversation(currentUserId, relation.getRequesterId());
        } catch (Exception e) {
            log.error("Failed to initialize conversation upon accepting friend request", e);
        }

        return INSTANCE.toUserRelationResponse(saved);
    }

    public UserRelationResponse declineFriendRequest(UserId currentUserId, RelationId relationId) {
        UserRelation relation = userRelationRepository.findById(relationId)
                .orElseThrow(() -> new RelationNotFoundException("Relation not found: " + relationId));

        if (!relation.getAddresseeId().equals(currentUserId)) {
            throw new RelationException("Only the addressee can decline the friend request");
        }

        relation.setStatus(RelationStatus.DECLINED);
        relation.setUpdatedAt(Instant.now());
        UserRelation saved = userRelationRepository.save(relation);
        log.info("Declined friend request relation {}", relationId);
        return INSTANCE.toUserRelationResponse(saved);
    }

    /**
     * Block a user even if you already have a relation
     * @param currentUserId
     * @param targetUserId
     * @return UserRelationResponse
     */
    public UserRelationResponse blockUser(UserId currentUserId, UserId targetUserId) {
        Optional<UserRelation> existingRelation = userRelationRepository.findRelationBetween(currentUserId, targetUserId);

        UserRelation relation;
        if (existingRelation.isPresent()) {
            relation = existingRelation.get();
            relation.setRequesterId(currentUserId);
            relation.setAddresseeId(targetUserId);
            relation.setStatus(RelationStatus.BLOCKED);
            relation.setUpdatedAt(Instant.now());
        } else {
            relation = UserRelation.builder()
                    .id(new RelationId())
                    .requesterId(currentUserId)
                    .addresseeId(targetUserId)
                    .status(RelationStatus.BLOCKED)
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();
        }

        UserRelation saved = userRelationRepository.save(relation);
        log.info("User {} blocked target user {}", currentUserId, targetUserId);
        return INSTANCE.toUserRelationResponse(saved);
    }

    public List<UserRelationResponse> getPendingRequests(UserId currentUserId) {
        return userRelationRepository.findByAddresseeIdAndStatus(currentUserId, RelationStatus.PENDING)
                .stream()
                .map(INSTANCE::toUserRelationResponse)
                .toList();
    }

    public List<UserRelationResponse> getFriends(UserId currentUserId) {
        return userRelationRepository.findAllRelationsByUserIdAndStatus(currentUserId, RelationStatus.ACCEPTED)
                .stream()
                .map(INSTANCE::toUserRelationResponse)
                .toList();
    }

    /**
     * Returns all user profiles with the relation properties
     * @param currentUserId
     * @return UserDiscoveryResponse
     */
    public List<UserDiscoveryResponse> getPeopleToConnect(UserId currentUserId) {
        List<UserRelation> myRelations = userRelationRepository.findAllRelationsForUser(currentUserId);
        Map<String, UserRelation> relationMap = new HashMap<>();
        for (UserRelation rel : myRelations) {
            UserId otherId = rel.getOtherUserId(currentUserId);
            if (otherId != null && otherId.id() != null) {
                relationMap.put(otherId.id().toString(), rel);
            }
        }

        List<UserProfileResponse> profiles = userProfileServiceApi.getUserProfiles(currentUserId);

        return profiles.stream()
                .filter(profile -> profile.userId() != null && !profile.userId().equals(currentUserId.id().toString()))
                .filter(profile -> profile.username() == null || !profile.username().equalsIgnoreCase("admin"))
                .map(profile -> {
                    UserRelation relation = relationMap.get(profile.userId());

                    RelationStatus status = null;
                    Boolean isRequester = null;
                    String relationIdStr = null;

                    if (relation != null) {
                        status = relation.getStatus();
                        isRequester = relation.getRequesterId().equals(currentUserId);
                        relationIdStr = relation.getId().id().toString();
                    }

                    return new UserDiscoveryResponse(
                            profile.userId(),
                            profile.firstName(),
                            profile.lastName(),
                            profile.username(),
                            profile.profileImageLink(),
                            profile.bio(),
                            status,
                            isRequester,
                            relationIdStr,
                            profile.publicKey()
                    );
                })
                .toList();
    }
}
