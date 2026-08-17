package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.EncryptedPayload;
import com.gwynejsn.kite.conversation.domain.MessageId;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;
import com.gwynejsn.kite.shared.domain.UserId;

import java.time.Instant;

public record LastMessageResponse(
        MessageId messageId,
        UserId senderId,
        EncryptedPayload encryptedPayload,
        MessageType messageType,
        Instant timestamp
) {
}