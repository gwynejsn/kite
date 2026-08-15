package com.gwynejsn.kite.conversation.web;

import com.gwynejsn.kite.conversation.application.ConversationService;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.application.dto.MessageResponse;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Process: when user logs in, get initial conversation (http)
 * but they should also listen to the stomp
 * when someone messages the user, update them using stomp
 * when user navigates to the chat room, the conversation is passed, and initially load the messages using the conversationId
 * the user also listens to the chat room
 * when a chat is added to the conversation, the user gets updated using stomp
 */
@RestController
@RequestMapping("/conversation")
@Slf4j
public class ConversationController {
    private final ConversationService conversationService;

    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }

    /**
     * Get all of current user's conversations (when the app is initialized)
     * after this, the app should listen to the websocket for any changes
     * @param authenticatedUser
     * @return current user's conversations
     */
    @GetMapping("/all")
    public ResponseEntity<List<ConversationResponse>> getInitialConversations(@AuthenticationPrincipal AuthenticatedUser authenticatedUser) {
        return ResponseEntity.ok(conversationService.getAllConversations(authenticatedUser.getUserId()));
    }

    @GetMapping("/{conversationId}")
    public ResponseEntity<List<MessageResponse>> getInitialMessages(@AuthenticationPrincipal AuthenticatedUser authenticatedUser,
                                                                    @PathVariable String conversationId) {
        return ResponseEntity.ok(conversationService.getAllMessages(new ConversationId(conversationId), authenticatedUser.getUserId()));
    }

//    @MessageMapping("/chat.send")
//    public void sendMessageToConversation(
//            @Payload MessageRequest messageRequest
//    ) {
//        log.info("Sending message to conversation: {}", messageRequest);
//    }


}
