package com.gwynejsn.kite.conversation.application.dto;

import com.gwynejsn.kite.conversation.domain.enums.ConversationType;

import java.time.Instant;
import java.util.Map;
import java.util.Set;

public record ConversationResponse(
        String id,
        ConversationType type,
        String name,
        String conversationPhoto,
        Set<String> memberIds,
        Set<String> adminIds,
        Map<String, MemberProfileResponse> memberProfiles,
        Map<String, String> memberPublicKeys,
        Map<String, String> groupKeyMap,
        LastMessageResponse lastMessage,
        Instant createdAt,
        Instant updatedAt
) { }