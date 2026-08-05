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

    public static UserId from(String id) {
        Assert.hasText(id, "id string must not be null or empty");
        return new UserId(UUID.fromString(id));
    }
}
