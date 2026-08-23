package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.api.ConversationServiceApi;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.application.dto.CreateGroupConversationRequest;
import com.gwynejsn.kite.conversation.application.dto.MemberProfileResponse;
import com.gwynejsn.kite.conversation.application.exceptions.ConversationAlreadyExistsException;
import com.gwynejsn.kite.conversation.application.exceptions.UserIsNotAnAdminException;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.infrastructure.ConversationRepo;
import com.gwynejsn.kite.conversation.application.exceptions.ConversationNotFoundException;
import com.gwynejsn.kite.conversation.application.exceptions.UserIsNotAMemberException;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.security.api.UserKeyServiceApi;
import com.gwynejsn.kite.security.api.UserServiceApi;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.infrastructure.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static com.gwynejsn.kite.conversation.infrastructure.ConversationMapper.INSTANCE;

@Service
@Slf4j
@RequiredArgsConstructor
public class ConversationService implements ConversationServiceApi {

    private final ConversationRepo conversationRepo;
    private final UserProfileServiceApi userProfileService;
    private final UserKeyServiceApi userKeyService;
    private final UserServiceApi userService;

    public List<ConversationResponse> getAllConversations(UserId currentId) {
        log.info("Get all conversations for user {}", currentId);
        List<Conversation> myConversations = conversationRepo
                .findMyConversations(currentId)
                .orElse(List.of());

        return myConversations.stream()
                .map(conv -> mapToResponse(conv, currentId))
                .toList();
    }

    public ConversationResponse getConversationForUser(ConversationId conversationId, UserId currentUserId) {
        Conversation conversation = conversationRepo
                .findConversationById(conversationId)
                .orElseThrow(() -> new ConversationNotFoundException(conversationId.id().toString()));
        return mapToResponse(conversation, currentUserId);
    }

    public void updateConversation(Conversation conversation) {
        conversationRepo.save(conversation);
    }

    /**
     * checks if the user is a member of a conversation
     * @param conversationId
     * @param currentUserId
     * @return Conversation
     */
    public Conversation validateMember(ConversationId conversationId, UserId currentUserId) {
        Conversation conversation = conversationRepo
                .findConversationById(conversationId)
                .orElseThrow(() -> new ConversationNotFoundException(conversationId.id().toString()));

        if (!conversation.getMemberIds().contains(currentUserId)) {
            throw new UserIsNotAMemberException("User is not a member of conversation");
        }
        return conversation;
    }

    /**
     * this is for 1-1 chat to be initialized whenever a user accepts a friend request
     * @param currentUserId
     * @param targetUserId
     */
    @Transactional
    @Override
    public void initializeConversation(UserId currentUserId, UserId targetUserId) {
        log.info("Initializing conversation between {} and {}", currentUserId, targetUserId);
        Optional<Conversation> existing = conversationRepo.findByDirectMembers(currentUserId, targetUserId);
        if (existing.isPresent()) {
            log.info("Direct conversation already exists between {} and {}", currentUserId, targetUserId);
            return;
        }

        Instant now = Instant.now();
        Conversation conversation = Conversation.builder()
                .id(new ConversationId())
                .type(ConversationType.DIRECT)
                .memberIds(Set.of(currentUserId, targetUserId))
                .createdAt(now)
                .updatedAt(now)
                .build();

        conversationRepo.save(conversation);
        log.info("Successfully initialized direct conversation {}", conversation.getId());
    }

    /**
     * helper that resolves name, photo, member public keys, and member profiles
     */
    private ConversationResponse mapToResponse(Conversation conversation, UserId currentUserId) {
        ConversationResponse baseResponse = INSTANCE.toConversationResponse(conversation);
        // <id, public key>
        Map<String, String> memberPublicKeys = userKeyService.getPublicKeysByUserIds(conversation.getMemberIds());

        Map<String, MemberProfileResponse> memberProfiles = new java.util.HashMap<>();
        try {
            List<UserProfileResponse> profiles = userProfileService.getUserProfilesByUserIds(conversation.getMemberIds());
            for (UserProfileResponse profile : profiles) {
                if (profile.userId() != null) {
                    memberProfiles.put(
                            profile.userId(),
                            new MemberProfileResponse(
                                    profile.userId(),
                                    profile.firstName(),
                                    profile.lastName(),
                                    profile.username(),
                                    profile.profileImageLink()
                            )
                    );
                }
            }
        } catch (Exception e) {
            log.warn("Could not fetch member profiles for conversation {}", conversation.getId(), e);
        }

        String name = baseResponse.name();
        String profilePhoto = baseResponse.conversationPhoto();

        // maps the user's profile picture and name appropriately if 1-1 chat
        if (conversation.getType() == ConversationType.DIRECT) {
            Optional<UserId> otherMember = conversation.getMemberIds().stream()
                    .filter(id -> !id.equals(currentUserId))
                    .findFirst();

            if (otherMember.isPresent()) {
                MemberProfileResponse otherProfile = memberProfiles.get(otherMember.get().id().toString());
                if (otherProfile != null) {
                    name = ((otherProfile.firstName() != null ? otherProfile.firstName() : "") + " " +
                            (otherProfile.lastName() != null ? otherProfile.lastName() : "")).trim();
                    if (name.isEmpty()) {
                        name = otherProfile.username();
                    }
                    profilePhoto = otherProfile.profilePhoto();
                } else {
                    try {
                        UserProfileResponse profile = userProfileService.getUserProfile(otherMember.get());
                        name = (profile.firstName() + " " + profile.lastName()).trim();
                        if (name.isEmpty()) {
                            name = profile.username();
                        }
                        profilePhoto = profile.profileImageLink();
                    } catch (Exception e) {
                        log.warn("Could not fetch profile for user {}", otherMember.get());
                    }
                }
            }
        }

        return new ConversationResponse(
                baseResponse.id(),
                baseResponse.type(),
                name,
                profilePhoto,
                baseResponse.memberIds(),
                baseResponse.adminIds(),
                memberProfiles,
                memberPublicKeys,
                conversation.getGroupKeyMap(),
                baseResponse.lastMessage(),
                baseResponse.createdAt(),
                baseResponse.updatedAt()
        );
    }

    /**
     * creates a group conversation
     * @param createGroupConversationRequest
     * @param creatorId
     * @return ConversationResponse
     */
    @Transactional
    public ConversationResponse createGroupConversation(CreateGroupConversationRequest createGroupConversationRequest, UserId creatorId) {
        if (conversationRepo.existsByName(createGroupConversationRequest.conversationName())) {
            throw new ConversationAlreadyExistsException(createGroupConversationRequest.conversationName());
        }

        Set<UserId> members = UserMapper.INSTANCE.stringUserToUserIdSet(
                createGroupConversationRequest.membersId()
        );
        members = (members == null) ? new java.util.HashSet<>() : new java.util.HashSet<>(members);
        members.add(creatorId);

        Set<UserId> admins = UserMapper.INSTANCE.stringUserToUserIdSet(
                createGroupConversationRequest.adminsId()
        );
        admins = (admins == null || admins.isEmpty()) ? new java.util.HashSet<>() : new java.util.HashSet<>(admins);
        admins.add(creatorId);

        // ensure all admins are also members
        members.addAll(admins);

        // check if each member exists (throws an error if at least 1 is not found)
        userService.usersExist(members);

        Instant now = Instant.now();
        Conversation groupConversation = Conversation
                .builder()
                .id(new ConversationId())
                .type(ConversationType.GROUP)
                .name(createGroupConversationRequest.conversationName())
                .conversationPhoto(createGroupConversationRequest.conversationPhoto())
                .memberIds(members)
                .adminIds(admins)
                .groupKeyMap(createGroupConversationRequest.groupKeyMap() != null ? createGroupConversationRequest.groupKeyMap() : new java.util.HashMap<>())
                .createdAt(now)
                .updatedAt(now)
                .build();
        conversationRepo.save(groupConversation);
        return mapToResponse(groupConversation, creatorId);
    }

    @Transactional
    public ConversationResponse addMembersToGroup(ConversationId conversationId, List<String> newMemberIds, Map<String, String> groupKeyMap, UserId currentUserId) {
        Conversation conversation = validateMember(conversationId, currentUserId);
        if (conversation.getType() != ConversationType.GROUP) {
            throw new IllegalArgumentException("Cannot add members to a direct conversation");
        }
        if (!conversation.getAdminIds().contains(currentUserId)) {
            throw new UserIsNotAnAdminException("Only admins can add members to the group");
        }

        Set<UserId> newMembers = UserMapper.INSTANCE.stringUserToUserIdSet(newMemberIds);
        if (newMembers != null && !newMembers.isEmpty()) {
            userService.usersExist(newMembers);
            conversation.getMemberIds().addAll(newMembers);
            if (groupKeyMap != null && !groupKeyMap.isEmpty()) {
                conversation.getGroupKeyMap().putAll(groupKeyMap);
            }
            conversation.setUpdatedAt(Instant.now());
            conversationRepo.save(conversation);
        }
        return mapToResponse(conversation, currentUserId);
    }

    @Transactional
    public ConversationResponse kickMemberFromGroup(ConversationId conversationId, UserId targetMemberId, UserId currentUserId) {
        Conversation conversation = validateMember(conversationId, currentUserId);
        if (conversation.getType() != ConversationType.GROUP) {
            throw new IllegalArgumentException("Cannot kick members from a direct conversation");
        }
        if (!conversation.getAdminIds().contains(currentUserId)) {
            throw new UserIsNotAnAdminException("Only admins can kick members from the group");
        }
        if (targetMemberId.equals(currentUserId)) {
            throw new IllegalArgumentException("Admins cannot kick themselves. Use leave instead.");
        }

        conversation.getMemberIds().remove(targetMemberId);
        conversation.getAdminIds().remove(targetMemberId);
        conversation.setUpdatedAt(Instant.now());
        conversationRepo.save(conversation);

        return mapToResponse(conversation, currentUserId);
    }

    @Transactional
    public ConversationResponse leaveGroupConversation(ConversationId conversationId, UserId currentUserId) {
        Conversation conversation = validateMember(conversationId, currentUserId);
        if (conversation.getType() != ConversationType.GROUP) {
            throw new IllegalArgumentException("Cannot leave a direct conversation");
        }

        conversation.getMemberIds().remove(currentUserId);
        conversation.getAdminIds().remove(currentUserId);

        if (conversation.getMemberIds().isEmpty()) {
            conversationRepo.delete(conversation);
            log.info("Group conversation {} was deleted because all members left", conversationId);
            return mapToResponse(conversation, currentUserId);
        }

        // auto-promote another member to Admin if no admins remain
        if (conversation.getAdminIds().isEmpty()) {
            UserId nextAdmin = conversation.getMemberIds().iterator().next();
            conversation.getAdminIds().add(nextAdmin);
            log.info("Auto-promoted user {} to admin in conversation {}", nextAdmin, conversationId);
        }

        conversation.setUpdatedAt(Instant.now());
        conversationRepo.save(conversation);

        return mapToResponse(conversation, currentUserId);
    }
}
