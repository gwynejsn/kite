package com.gwynejsn.kite.shared.domain;

import com.gwynejsn.kite.shared.interfaces.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record UserId(UUID id) implements DomainId {
    public static final UserId ADMIN_ID = new UserId(UUID.fromString("42a98f1b-5e4c-473d-9d10-8b1b827e8a93"));

    public UserId {
        Assert.notNull(id, "id is required");
    }

    public UserId() {
        this(UUID.randomUUID());
    }
}
