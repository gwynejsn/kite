package com.gwynejsn.kite.conversation.web;

import com.gwynejsn.kite.conversation.application.ConversationService;
import com.gwynejsn.kite.conversation.application.MessageService;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.application.dto.CreateGroupConversationRequest;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ConversationControllerTest {

    @Mock
    private ConversationService conversationService;
    @Mock
    private MessageService messageService;
    @Mock
    private SimpMessagingTemplate messagingTemplate;
    @Mock
    private AuthenticatedUser authenticatedUser;

    @InjectMocks
    private ConversationController conversationController;

    private UserId userId;
    private UserId member2Id;

    @BeforeEach
    void setUp() {
        userId = new UserId(UUID.randomUUID().toString());
        member2Id = new UserId(UUID.randomUUID().toString());
    }

    @Test
    @DisplayName("Should create group conversation and broadcast update to all member topics")
    void createGroupConversation_success() {
        // Arrange
        CreateGroupConversationRequest request = new CreateGroupConversationRequest(
                List.of(member2Id.id().toString()),
                "Group Chat",
                "photo.png",
                List.of()
        );

        ConversationResponse expectedResponse = new ConversationResponse(
                UUID.randomUUID().toString(),
                ConversationType.GROUP,
                "Group Chat",
                "photo.png",
                Set.of(userId.id().toString(), member2Id.id().toString()),
                Set.of(userId.id().toString()),
                Map.of(),
                Map.of(userId.id().toString(), "key1", member2Id.id().toString(), "key2"),
                null,
                Instant.now(),
                Instant.now()
        );

        when(authenticatedUser.getUserId()).thenReturn(userId);
        when(conversationService.createGroupConversation(request, userId)).thenReturn(expectedResponse);

        // Act
        ResponseEntity<ConversationResponse> responseEntity = conversationController.createGroupConversation(request, authenticatedUser);

        // Assert
        assertThat(responseEntity.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(responseEntity.getBody()).isEqualTo(expectedResponse);

        verify(messagingTemplate).convertAndSend("/topic/user." + userId.id().toString() + ".conversations", expectedResponse);
        verify(messagingTemplate).convertAndSend("/topic/user." + member2Id.id().toString() + ".conversations", expectedResponse);
    }
}
