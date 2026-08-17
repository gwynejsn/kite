package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.shared.domain.UserId;

import java.time.Instant;
import java.util.Map;
import java.util.Set;

public record ConversationResponse(
        String id,
        ConversationType type,
        String name,
        String conversationPhoto,
        Set<UserId> memberIds,
        Set<UserId> adminIds,
        Map<String, String> memberPublicKeys,
        LastMessageResponse lastMessage,
        Instant createdAt,
        Instant updatedAt
) { }