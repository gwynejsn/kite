package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.EncryptedPayload;
import com.gwynejsn.kite.conversation.domain.Message;
import com.gwynejsn.kite.conversation.domain.enums.MessageStatus;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;

import java.time.Instant;

public record MessageResponse(
        String id,
        String conversationId,
        String senderId,
        EncryptedPayload encryptedPayload,
        String mediaUrl,
        MessageType messageType,
        MessageStatus status,
        String replyToMessageId,
        Instant createdAt,
        Instant updatedAt
) {
    public static MessageResponse from(Message message) {
        return new MessageResponse(
                message.getId() != null ? message.getId().id().toString() : null,
                message.getConversationId() != null ? message.getConversationId().id().toString() : null,
                message.getSenderId() != null ? message.getSenderId().id().toString() : null,
                message.getEncryptedPayload(),
                message.getMediaUrl(),
                message.getMessageType(),
                message.getStatus(),
                message.getReplyToMessageId() != null ? message.getReplyToMessageId().id().toString() : null,
                message.getCreatedAt(),
                message.getUpdatedAt()
        );
    }
}