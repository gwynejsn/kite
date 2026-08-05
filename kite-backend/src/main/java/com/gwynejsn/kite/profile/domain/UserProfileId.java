package com.gwynejsn.kite.profile.domain;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record UserProfileId(UUID id) implements DomainId {
    public UserProfileId {
        Assert.notNull(id, "id is required");
    }

    public UserProfileId() {
        this(UUID.randomUUID());
    }
}
