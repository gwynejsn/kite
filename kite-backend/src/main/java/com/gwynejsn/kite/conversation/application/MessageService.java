package com.gwynejsn.kite.conversation.application;

import com.gwynejsn.kite.conversation.application.dto.MessageRequest;
import com.gwynejsn.kite.conversation.application.dto.MessageResponse;
import com.gwynejsn.kite.conversation.domain.*;
import com.gwynejsn.kite.conversation.domain.enums.MessageStatus;
import com.gwynejsn.kite.conversation.infrastructure.MessageRepo;
import com.gwynejsn.kite.shared.domain.ConversationId;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.ZoneId;
import java.util.List;

import static com.gwynejsn.kite.conversation.infrastructure.MessageMapper.INSTANCE;

@Service
@Slf4j
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepo messageRepo;
    private final ConversationService conversationService;

    public List<MessageResponse> getAllMessages(ConversationId conversationId, UserId currentUserId) {
        conversationService.validateMember(conversationId, currentUserId);
        return messageRepo
                .findMessagesByConversationId(conversationId)
                .stream()
                .map(INSTANCE::toMessageResponse)
                .toList();
    }

    @Transactional
    public MessageResponse sendMessage(MessageRequest messageRequest, UserId senderId) {
        ConversationId conversationId = new ConversationId(messageRequest.conversationId());
        Conversation conversation = conversationService
                .validateMember(conversationId, senderId);

        Instant now = Instant.now().atZone(ZoneId.systemDefault()).toInstant();
        MessageId messageId = new MessageId();

        EncryptedPayload encryptedPayload = messageRequest.encryptedPayload();

        Message message = Message.builder()
                .id(messageId)
                .conversationId(conversationId)
                .senderId(senderId)
                .encryptedPayload(new EncryptedPayload(
                        encryptedPayload.getCipherText(),
                        encryptedPayload.getNonce(),
                        encryptedPayload.getMac(),
                        encryptedPayload.getSenderPublicKey(),
                        encryptedPayload.getEncryptedGroupKeys())
                )
                .mediaUrl(messageRequest.mediaUrl())
                .messageType(messageRequest.messageType())
                .status(MessageStatus.SENT)
                .replyToMessageId(messageRequest.replyToMessageId() != null ? new MessageId(messageRequest.replyToMessageId()) : null)
                .createdAt(now)
                .updatedAt(now)
                .build();

        Message savedMessage = messageRepo.save(message);

        // update conversation last message
        LastMessage lastMessage = LastMessage.builder()
                .messageId(savedMessage.getId())
                .senderId(senderId)
                .encryptedPayload(encryptedPayload)
                .messageType(savedMessage.getMessageType())
                .timestamp(savedMessage.getCreatedAt())
                .build();

        conversation.setLastMessage(lastMessage);
        conversation.setUpdatedAt(now);
        conversationService.updateConversation(conversation);

        log.info("Saved message {} for conversation {}", savedMessage.getId(), conversationId);
        return INSTANCE.toMessageResponse(savedMessage);
    }
}
