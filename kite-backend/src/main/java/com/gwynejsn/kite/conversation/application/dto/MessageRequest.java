package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.EncryptedPayload;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;

public record MessageRequest(
        String conversationId,
        EncryptedPayload encryptedPayload,
        String mediaUrl,
        MessageType messageType,
        String replyToMessageId
) { }