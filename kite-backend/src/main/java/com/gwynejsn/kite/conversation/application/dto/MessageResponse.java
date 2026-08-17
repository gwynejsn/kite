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
) { }