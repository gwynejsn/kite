package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.api.ConversationServiceApi;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.infrastructure.ConversationRepo;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static com.gwynejsn.kite.conversation.infrastructure.ConversationMapper.INSTANCE;

@Service
@Slf4j
@RequiredArgsConstructor
public class ConversationService implements ConversationServiceApi {

    private final ConversationRepo conversationRepo;
    private final UserProfileServiceApi userProfileService;

    public List<ConversationResponse> getAllConversations(UserId currentId) {
        log.info("Get all conversations for user {}", currentId);
        List<Conversation> myConversations = conversationRepo
                .findMyConversations(currentId)
                .orElse(List.of());

        return myConversations.stream()
                .map(conv -> mapToResponse(conv, currentId))
                .toList();
    }

    public ConversationResponse findDirectConversation(UserId currentId, UserId recipientId) {
        log.debug("Find or create direct conversation for {} to {}", currentId, recipientId);
        Conversation conversation = conversationRepo
                .findByDirectMembers(currentId, recipientId)
                .orElseGet(() -> {
                    log.info("Creating new direct conversation between {} and {}", currentId, recipientId);
                    Instant now = Instant.now();
                    Conversation newConv = Conversation.builder()
                            .id(new ConversationId())
                            .type(ConversationType.DIRECT)
                            .memberIds(Set.of(currentId, recipientId))
                            .createdAt(now)
                            .updatedAt(now)
                            .build();
                    return conversationRepo.save(newConv);
                });

        return mapToResponse(conversation, currentId);
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
     * helper that resolves name & photo for DIRECT chats based on currentUserId
     */
    private ConversationResponse mapToResponse(Conversation conversation, UserId currentUserId) {
        ConversationResponse baseResponse = INSTANCE.toConversationResponse(conversation);

        if (conversation.getType() == ConversationType.DIRECT) {
            Optional<UserId> otherMember = conversation.getMemberIds().stream()
                    .filter(id -> !id.equals(currentUserId))
                    .findFirst();

            // set the name and profile pic to the other member
            // perhaps another alternative to this in the future is to store separately conversations for direct / one-on-one
            if (otherMember.isPresent()) {
                try {
                    UserProfileResponse profile = userProfileService.getUserProfile(otherMember.get());
                    String name = (profile.firstName() + " " + profile.lastName()).trim();
                    if (name.isEmpty()) {
                        name = profile.username();
                    }
                    return new ConversationResponse(
                            baseResponse.id(),
                            baseResponse.type(),
                            name,
                            profile.profileImageLink(),
                            baseResponse.memberIds(),
                            baseResponse.adminIds(),
                            baseResponse.lastMessage(),
                            baseResponse.createdAt(),
                            baseResponse.updatedAt()
                    );
                } catch (Exception e) {
                    log.warn("Could not fetch profile for user {}", otherMember.get());
                }
            }
        }

        return baseResponse;
    }
}
