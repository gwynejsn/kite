package com.gwynejsn.kite.shared.domain;

import org.springframework.util.Assert;

import java.util.UUID;

public record UserId(UUID id) implements DomainId {
    public UserId {
        Assert.notNull(id, "id is required");
    }

    public UserId() {
        this(UUID.randomUUID());
    }

    public UserId(String id) {
        this(UUID.fromString(id));
    }

    public static UserId from(String id) {
        return new UserId(UUID.fromString(id));
    }
}
