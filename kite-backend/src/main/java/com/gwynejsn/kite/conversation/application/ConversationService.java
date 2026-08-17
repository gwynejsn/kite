package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.api.ConversationServiceApi;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.infrastructure.ConversationRepo;
import com.gwynejsn.kite.conversation.infrastructure.exceptions.ConversationNotFoundException;
import com.gwynejsn.kite.conversation.infrastructure.exceptions.UserIsNotAMemberException;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.security.api.UserKeyServiceApi;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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

    public Conversation validateMember(ConversationId conversationId, UserId currentUserId) {
        Conversation conversation = conversationRepo
                .findConversationById(conversationId)
                .orElseThrow(() -> new ConversationNotFoundException(conversationId.id().toString()));

        if (!conversation.getMemberIds().contains(currentUserId)) {
            throw new UserIsNotAMemberException("User is not a member of conversation");
        }
        return conversation;
    }

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
     * helper that resolves name, photo, and member public keys
     */
    private ConversationResponse mapToResponse(Conversation conversation, UserId currentUserId) {
        ConversationResponse baseResponse = INSTANCE.toConversationResponse(conversation);
        // <id, public key>
        Map<String, String> memberPublicKeys = userKeyService.getPublicKeysByUserIds(conversation.getMemberIds());

        String name = baseResponse.name();
        String profilePhoto = baseResponse.conversationPhoto();

        // maps the user's profile picture and name appropriately if 1-1 chat
        if (conversation.getType() == ConversationType.DIRECT) {
            Optional<UserId> otherMember = conversation.getMemberIds().stream()
                    .filter(id -> !id.equals(currentUserId))
                    .findFirst();

            if (otherMember.isPresent()) {
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

        return new ConversationResponse(
                baseResponse.id(),
                baseResponse.type(),
                name,
                profilePhoto,
                baseResponse.memberIds(),
                baseResponse.adminIds(),
                memberPublicKeys,
                baseResponse.lastMessage(),
                baseResponse.createdAt(),
                baseResponse.updatedAt()
        );
    }
}
