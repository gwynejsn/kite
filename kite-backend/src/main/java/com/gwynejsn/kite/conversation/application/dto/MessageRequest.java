package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.enums.MessageType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record MessageRequest(
        @NotNull(message = "Conversation ID is required")
        String conversationId,

        @Size(max = 4000, message = "Content cannot exceed 4000 characters")
        String content,

        String mediaUrl,

        @NotNull(message = "Message type is required")
        MessageType messageType,

        String replyToMessageId
) {
    public MessageRequest {
        if (messageType == MessageType.TEXT && (content == null || content.isBlank())) {
            throw new IllegalArgumentException("Content cannot be empty for text messages");
        }
    }
}