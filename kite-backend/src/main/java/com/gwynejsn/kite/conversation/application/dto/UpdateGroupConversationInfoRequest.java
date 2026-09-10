package com.gwynejsn.kite.conversation.application.dto;

import org.jspecify.annotations.Nullable;

public record UpdateGroupConversationInfoRequest (String conversationId, @Nullable String groupName, @Nullable String conversationPhoto) {
}
