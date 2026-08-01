package com.gwynejsn.kite.profile.domain;

import org.springframework.util.Assert;

import java.util.UUID;

public record UserProfileId(UUID id) {
    public UserProfileId {
        Assert.notNull(id, "id is required");
    }

    public UserProfileId() {
        this(UUID.randomUUID());
    }
}
