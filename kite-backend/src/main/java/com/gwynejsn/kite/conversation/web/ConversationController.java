package com.gwynejsn.kite.conversation.web;

import com.gwynejsn.kite.conversation.application.ConversationService;
import com.gwynejsn.kite.conversation.application.MessageService;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.application.dto.CreateGroupConversationRequest;
import com.gwynejsn.kite.conversation.application.dto.MessageRequest;
import com.gwynejsn.kite.conversation.application.dto.MessageResponse;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/conversation")
@Slf4j
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationService conversationService;
    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * get all of current user's conversations
     */
    @GetMapping("/all")
    public ResponseEntity<List<ConversationResponse>> getInitialConversations(@AuthenticationPrincipal AuthenticatedUser authenticatedUser) {
        return ResponseEntity.ok(conversationService.getAllConversations(authenticatedUser.getUserId()));
    }

    @GetMapping("/{conversationId}")
    public ResponseEntity<List<MessageResponse>> getInitialMessages(@AuthenticationPrincipal AuthenticatedUser authenticatedUser,
                                                                    @PathVariable String conversationId) {
        return ResponseEntity.ok(messageService.getAllMessages(new ConversationId(conversationId), authenticatedUser.getUserId()));
    }

    @PostMapping("/message")
    public ResponseEntity<MessageResponse> sendMessage(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @RequestBody MessageRequest messageRequest
    ) {
        log.info("Sending message via REST HTTP to conversation {} by user {}", messageRequest.conversationId(), authenticatedUser.getUserId());
        MessageResponse response = messageService.sendMessage(messageRequest, authenticatedUser.getUserId());

        // broadcast message to active room subscribers
        messagingTemplate.convertAndSend("/topic/conversation." + messageRequest.conversationId(), response);

        // broadcast updated conversation list
        broadcastConversationUpdate(new ConversationId(messageRequest.conversationId()), authenticatedUser.getUserId());

        return ResponseEntity.ok(response);
    }

    private void broadcastConversationUpdate(ConversationId conversationId, UserId currentUserId) {
        try {
            Conversation conversation = conversationService.validateMember(conversationId, currentUserId);
            for (UserId memberId : conversation.getMemberIds()) {
                ConversationResponse convResponse = conversationService.getConversationForUser(conversationId, memberId);
                messagingTemplate.convertAndSend("/topic/user." + memberId.id().toString() + ".conversations", convResponse);
            }
        } catch (Exception e) {
            log.error("Failed to broadcast conversation update for {}", conversationId, e);
        }
    }

    private void broadcastGroupConversationUpdate(ConversationResponse response) {
        try {
            for (String memberId : response.memberIds()) {
                messagingTemplate.convertAndSend("/topic/user." + memberId + ".conversations", response);
            }
        } catch (Exception e) {
            log.error("Failed to broadcast group conversation update for {}", response.id(), e);
        }
    }

    @PostMapping("/group/create")
    public ResponseEntity<ConversationResponse> createGroupConversation(
            @Valid @RequestBody CreateGroupConversationRequest createGroupConversationRequest,
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        ConversationResponse response = conversationService.createGroupConversation(createGroupConversationRequest, authenticatedUser.getUserId());
        broadcastGroupConversationUpdate(response);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{conversationId}/members/add")
    public ResponseEntity<ConversationResponse> addMembersToGroup(
            @PathVariable String conversationId,
            @Valid @RequestBody com.gwynejsn.kite.conversation.application.dto.AddGroupMembersRequest request,
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        ConversationResponse response = conversationService.addMembersToGroup(
                new ConversationId(conversationId),
                request.memberIds(),
                request.groupKeyMap(),
                authenticatedUser.getUserId()
        );
        broadcastGroupConversationUpdate(response);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{conversationId}/members/kick/{targetMemberId}")
    public ResponseEntity<ConversationResponse> kickMemberFromGroup(
            @PathVariable String conversationId,
            @PathVariable String targetMemberId,
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        ConversationResponse response = conversationService.kickMemberFromGroup(
                new ConversationId(conversationId),
                new UserId(targetMemberId),
                authenticatedUser.getUserId()
        );
        broadcastGroupConversationUpdate(response);
        messagingTemplate.convertAndSend("/topic/user." + targetMemberId + ".conversations", response);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{conversationId}/leave")
    public ResponseEntity<Void> leaveGroupConversation(
            @PathVariable String conversationId,
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        String leavingUserId = authenticatedUser.getUserId().id().toString();
        ConversationResponse response = conversationService.leaveGroupConversation(
                new ConversationId(conversationId),
                authenticatedUser.getUserId()
        );
        if (response != null) {
            broadcastGroupConversationUpdate(response);
            messagingTemplate.convertAndSend("/topic/user." + leavingUserId + ".conversations", response);
        }
        return ResponseEntity.ok().build();
    }
}
