package com.gwynejsn.kite.security.domain;

import org.springframework.util.Assert;

import java.util.UUID;

public record UserId(UUID id) {
    public UserId {
        Assert.notNull(id, "id is required");
    }

    public UserId() {
        this(UUID.randomUUID());
    }
}
