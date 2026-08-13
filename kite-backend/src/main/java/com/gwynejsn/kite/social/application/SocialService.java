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
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static com.gwynejsn.kite.social.infrastructure.SocialMapper.INSTANCE;

@Service
@RequiredArgsConstructor
@Slf4j
public class SocialService {

    private final UserRelationRepository userRelationRepository;
    private final UserProfileServiceApi userProfileServiceApi;
    private final ConversationServiceApi conversationServiceApi;

    public UserRelationResponse sendFriendRequest(UserId requesterId, UserId addresseeId) {
        if (requesterId.equals(addresseeId)) {
            throw new IllegalArgumentException("Cannot send friend request to yourself");
        }

        Optional<UserRelation> existingRelation = userRelationRepository.findRelationBetween(requesterId, addresseeId);

        if (existingRelation.isPresent()) {
            UserRelation relation = existingRelation.get();
            if (relation.getStatus() == RelationStatus.PENDING || relation.getStatus() == RelationStatus.ACCEPTED) {
                throw new IllegalStateException("Relation already exists between users with status: " + relation.getStatus());
            }
            // If declined previously, re-initiate request
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
                .orElseThrow(() -> new IllegalArgumentException("Relation not found: " + relationId));

        if (!relation.getAddresseeId().equals(currentUserId)) {
            throw new IllegalStateException("Only the addressee can accept the friend request");
        }

        if (relation.getStatus() != RelationStatus.PENDING) {
            throw new IllegalStateException("Cannot accept friend request with status: " + relation.getStatus());
        }

        relation.setStatus(RelationStatus.ACCEPTED);
        relation.setUpdatedAt(Instant.now());
        UserRelation saved = userRelationRepository.save(relation);
        log.info("Accepted friend request relation {}", relationId);

        // Automatically initialize direct conversation between both users
        try {
            conversationServiceApi.initializeConversation(currentUserId, relation.getRequesterId());
        } catch (Exception e) {
            log.error("Failed to initialize conversation upon accepting friend request", e);
        }

        return INSTANCE.toUserRelationResponse(saved);
    }

    public UserRelationResponse declineFriendRequest(UserId currentUserId, RelationId relationId) {
        UserRelation relation = userRelationRepository.findById(relationId)
                .orElseThrow(() -> new IllegalArgumentException("Relation not found: " + relationId));

        if (!relation.getAddresseeId().equals(currentUserId)) {
            throw new IllegalStateException("Only the addressee can decline the friend request");
        }

        relation.setStatus(RelationStatus.DECLINED);
        relation.setUpdatedAt(Instant.now());
        UserRelation saved = userRelationRepository.save(relation);
        log.info("Declined friend request relation {}", relationId);
        return INSTANCE.toUserRelationResponse(saved);
    }

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

    public List<UserDiscoveryResponse> getPeopleToConnect(UserId currentUserId) {
        List<UserProfileResponse> profiles = userProfileServiceApi.getUserProfiles(currentUserId);

        return profiles.stream()
                .filter(profile ->
                        profile.userId() != null
                                && !profile.userId().equals(currentUserId.id().toString())
                )
                // requires the admin profile username to be always "admin" !!
                .filter(profile ->
                        !profile.username().equalsIgnoreCase("admin")
                                && !"ADMIN".equalsIgnoreCase(profile.username())
                )
                .map(profile -> {
                    UserId targetId = UserId.from(profile.userId());
                    Optional<UserRelation> relationOpt = userRelationRepository.findRelationBetween(currentUserId, targetId);

                    RelationStatus status = null;
                    Boolean isRequester = null;
                    String relationIdStr = null;

                    if (relationOpt.isPresent()) {
                        UserRelation relation = relationOpt.get();
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
                            relationIdStr
                    );
                })
                .toList();
    }
}
