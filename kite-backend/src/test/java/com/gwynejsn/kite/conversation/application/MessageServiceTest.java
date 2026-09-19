package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.application.dto.MessageRequest;
import com.gwynejsn.kite.conversation.application.dto.MessageResponse;
import com.gwynejsn.kite.conversation.application.exceptions.UserIsNotAMemberException;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.EncryptedPayload;
import com.gwynejsn.kite.conversation.domain.Message;
import com.gwynejsn.kite.conversation.domain.MessageId;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.domain.enums.MessageStatus;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;
import com.gwynejsn.kite.conversation.infrastructure.MessageRepo;
import com.gwynejsn.kite.shared.domain.ConversationId;
import com.gwynejsn.kite.shared.domain.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.AdditionalAnswers.returnsFirstArg;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MessageServiceTest {

    @Mock
    private MessageRepo messageRepo;

    @Mock
    private ConversationService conversationService;

    @InjectMocks
    private MessageService messageService;

    @Nested
    @DisplayName("getAllMessages")
    class GetAllMessagesTests {

        @Test
        @DisplayName("""
                GIVEN: User is a member and conversation has messages
                WHEN: getAllMessages is called
                THEN: List of MessageResponse is returned
                """)
        void getAllMessages_success() {
            ConversationId convId = new ConversationId();
            UserId userId = new UserId(UUID.randomUUID());

            Message message = Message.builder()
                    .id(new MessageId())
                    .conversationId(convId)
                    .senderId(userId)
                    .encryptedPayload(new EncryptedPayload("cipher", "nonce", "mac", "key", Map.of()))
                    .messageType(MessageType.TEXT)
                    .status(MessageStatus.SENT)
                    .createdAt(Instant.now())
                    .updatedAt(Instant.now())
                    .build();

            when(messageRepo.findMessagesByConversationId(convId)).thenReturn(List.of(message));

            List<MessageResponse> responses = messageService.getAllMessages(convId, userId);

            assertThat(responses).hasSize(1);
            assertThat(responses.get(0).conversationId()).isEqualTo(convId.id().toString());
            assertThat(responses.get(0).senderId()).isEqualTo(userId.id().toString());
            assertThat(responses.get(0).messageType()).isEqualTo(MessageType.TEXT);
            verify(conversationService).validateMember(convId, userId);
        }

        @Test
        @DisplayName("""
                GIVEN: User is not a member of conversation
                WHEN: getAllMessages is called
                THEN: UserIsNotAMemberException is thrown
                """)
        void getAllMessages_notMember() {
            ConversationId convId = new ConversationId();
            UserId userId = new UserId(UUID.randomUUID());

            when(conversationService.validateMember(convId, userId))
                    .thenThrow(new UserIsNotAMemberException("User is not a member of conversation"));

            assertThatThrownBy(() -> messageService.getAllMessages(convId, userId))
                    .isInstanceOf(UserIsNotAMemberException.class);

            verify(messageRepo, never()).findMessagesByConversationId(any());
        }
    }

    @Nested
    @DisplayName("sendMessage")
    class SendMessageTests {

        @Test
        @DisplayName("""
                GIVEN: Valid MessageRequest from a conversation member
                WHEN: sendMessage is called
                THEN: Message is saved, conversation lastMessage is updated, and MessageResponse is returned
                """)
        void sendMessage_success() {
            ConversationId convId = new ConversationId();
            UserId senderId = new UserId(UUID.randomUUID());
            EncryptedPayload payload = new EncryptedPayload("cipher", "nonce", "mac", "pubKey", Map.of("u1", "k1"));

            MessageRequest request = new MessageRequest(
                    convId.id().toString(),
                    payload,
                    "http://media.png",
                    MessageType.MEDIA,
                    null
            );

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.GROUP)
                    .memberIds(Set.of(senderId))
                    .build();

            when(conversationService.validateMember(convId, senderId)).thenReturn(conv);
            when(messageRepo.save(any(Message.class))).then(returnsFirstArg());

            MessageResponse response = messageService.sendMessage(request, senderId);

            assertThat(response).isNotNull();
            assertThat(response.conversationId()).isEqualTo(convId.id().toString());
            assertThat(response.senderId()).isEqualTo(senderId.id().toString());
            assertThat(response.messageType()).isEqualTo(MessageType.MEDIA);
            assertThat(response.mediaUrl()).isEqualTo("http://media.png");

            ArgumentCaptor<Message> messageCaptor = ArgumentCaptor.forClass(Message.class);
            verify(messageRepo).save(messageCaptor.capture());
            Message saved = messageCaptor.getValue();
            assertThat(saved.getStatus()).isEqualTo(MessageStatus.SENT);
            assertThat(saved.getEncryptedPayload().getCipherText()).isEqualTo("cipher");

            verify(conversationService).updateConversation(conv);
            assertThat(conv.getLastMessage()).isNotNull();
            assertThat(conv.getLastMessage().getSenderId()).isEqualTo(senderId);
            assertThat(conv.getLastMessage().getMessageType()).isEqualTo(MessageType.MEDIA);
        }

        @Test
        @DisplayName("""
                GIVEN: MessageRequest with replyToMessageId
                WHEN: sendMessage is called
                THEN: Message is saved with parsed replyToMessageId
                """)
        void sendMessage_withReplyToMessageId() {
            ConversationId convId = new ConversationId();
            UserId senderId = new UserId(UUID.randomUUID());
            UUID replyUuid = UUID.randomUUID();
            EncryptedPayload payload = new EncryptedPayload("cipher", "nonce", "mac", "pubKey", Map.of());

            MessageRequest request = new MessageRequest(
                    convId.id().toString(),
                    payload,
                    null,
                    MessageType.TEXT,
                    replyUuid.toString()
            );

            Conversation conv = Conversation.builder()
                    .id(convId)
                    .type(ConversationType.DIRECT)
                    .memberIds(Set.of(senderId))
                    .build();

            when(conversationService.validateMember(convId, senderId)).thenReturn(conv);
            when(messageRepo.save(any(Message.class))).then(returnsFirstArg());

            MessageResponse response = messageService.sendMessage(request, senderId);

            assertThat(response).isNotNull();
            assertThat(response.replyToMessageId()).isEqualTo(replyUuid.toString());

            ArgumentCaptor<Message> messageCaptor = ArgumentCaptor.forClass(Message.class);
            verify(messageRepo).save(messageCaptor.capture());
            assertThat(messageCaptor.getValue().getReplyToMessageId().id()).isEqualTo(replyUuid);
        }
    }
}
