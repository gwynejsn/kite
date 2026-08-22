package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.EncryptedPayload;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;

import java.time.Instant;

public record LastMessageResponse(
        String messageId,
        String senderId,
        EncryptedPayload encryptedPayload,
        MessageType messageType,
        Instant timestamp
) {
}