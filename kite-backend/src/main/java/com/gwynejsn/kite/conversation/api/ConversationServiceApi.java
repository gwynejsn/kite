package com.gwynejsn.kite.conversation.api;

import com.gwynejsn.kite.shared.domain.UserId;

public interface ConversationServiceApi {
    public void initializeConversation(UserId currentUserId, UserId targetUserId);
}
