package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.shared.domain.UserId;

import java.time.Instant;
import java.util.Set;

public record ConversationResponse(
        ConversationId id,
        ConversationType type,
        String name,
        String conversationPhoto,
        Set<UserId> memberIds,
        Set<UserId> adminIds,
        LastMessageResponse lastMessage,
        Instant createdAt,
        Instant updatedAt
) {
}