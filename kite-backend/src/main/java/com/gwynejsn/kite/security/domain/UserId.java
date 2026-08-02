package com.gwynejsn.kite.security.domain;

import com.gwynejsn.kite.shared.interfaces.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record UserId(UUID id) implements DomainId {
    public UserId {
        Assert.notNull(id, "id is required");
    }

    public UserId() {
        this(UUID.randomUUID());
    }
}
