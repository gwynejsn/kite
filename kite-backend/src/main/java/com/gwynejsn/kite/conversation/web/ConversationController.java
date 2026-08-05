package com.gwynejsn.kite.conversation.web;

import com.gwynejsn.kite.conversation.application.ConversationService;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/conversation")
@Slf4j
public class ConversationController {
    private final ConversationService conversationService;

    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }

    /**
     * Get a direct conversation. Create one if not yet existing
     * @param recipientId
     * @return
     */
    @MessageMapping("/direct/{recipientId}")
    @SendTo("/topic/conversations")
    public ConversationResponse findDirectConversation(
            @DestinationVariable String recipientId,
            Authentication authentication
    ) {
        if (authentication == null) {
            log.error("Unauthenticated STOMP request to /direct/{}", recipientId);
            throw new IllegalArgumentException("User is unauthenticated");
        }
        AuthenticatedUser currentUser = (AuthenticatedUser) authentication.getPrincipal();

        log.info("Finding direct conversation for recipientId: {} from currentUser: {}",
                recipientId, currentUser.getUserId().id());

        UserId recipientUserId = UserId.from(recipientId);
        return conversationService.findDirectConversation(currentUser.getUserId(), recipientUserId);
    }

    /**
     * Get a group conversation
     */
}
