package com.gwynejsn.kite.conversation.domain;

import com.gwynejsn.kite.shared.interfaces.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record MessageId(UUID id) implements DomainId {
    public MessageId {
        Assert.notNull(id, "id is required");
    }

    public MessageId() {
        this(UUID.randomUUID());
    }
}
