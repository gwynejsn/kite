package com.gwynejsn.kite.conversation.domain;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record ConversationId(UUID id) implements DomainId {
    public ConversationId {
        Assert.notNull(id, "id is required");
    }

    public ConversationId() {
        this(UUID.randomUUID());
    }
}
