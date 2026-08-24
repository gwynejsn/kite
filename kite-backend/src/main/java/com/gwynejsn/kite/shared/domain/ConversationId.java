package com.gwynejsn.kite.shared.domain;

import org.springframework.util.Assert;

import java.util.UUID;

public record ConversationId(UUID id) implements DomainId {
    public ConversationId {
        Assert.notNull(id, "id is required");
    }

    public ConversationId(String conversationId) {
        this(UUID.fromString(conversationId));
    }

    public ConversationId() {
        this(UUID.randomUUID());
    }
}
