package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.infrastructure.ConversationRepo;
import com.gwynejsn.kite.profile.api.UserProfileServiceApi;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Set;

import static com.gwynejsn.kite.conversation.infrastructure.ConversationMapper.INSTANCE;

@Service
@Slf4j
@RequiredArgsConstructor
public class ConversationService  {
    private final ConversationRepo conversationRepo;
    private final UserProfileServiceApi userProfileService;


    public ConversationResponse findDirectConversation(UserId currentId, UserId recipientId) {
        log.debug("Find or create direct conversation for {} to {}", currentId, recipientId);
        return conversationRepo
                .findByDirectMembers(currentId, recipientId)
                .map(INSTANCE::toConversationResponse)
                .orElseGet(() -> {
                    log.info("No direct conversation found between {} and {}. Creating a new one.", currentId, recipientId);
                    UserProfileResponse recipientProfile = userProfileService.getUserProfile(recipientId);
                    Instant now = Instant.now();
                    Conversation newConversation = Conversation.builder()
                            .id(new ConversationId())
                            .type(ConversationType.DIRECT)
                            .memberIds(Set.of(currentId, recipientId))
                            .createdAt(now)
                            .updatedAt(now)
                            .build();

                    Conversation conversation = conversationRepo.save(newConversation);
                    conversation.setName(recipientProfile.firstName() + " " + recipientProfile.lastName());
                    conversation.setConversationPhoto(recipientProfile.profileImageLink());
                    return INSTANCE.toConversationResponse(conversation);
                });
    }
}
