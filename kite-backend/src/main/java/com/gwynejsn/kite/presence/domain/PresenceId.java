package com.gwynejsn.kite.presence.domain;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record PresenceId(UUID id) implements DomainId {
    public PresenceId {
        Assert.notNull(id, "id is required");
    }

    public PresenceId() {
        this(UUID.randomUUID());
    }
}
