package com.gwynejsn.kite.security.domain;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.springframework.util.Assert;

import java.io.Serializable;
import java.util.UUID;

public record RefreshTokenId(UUID id) implements DomainId {
    public RefreshTokenId {
        Assert.notNull(id, "id is required");
    }

    public RefreshTokenId() {
        this(UUID.randomUUID());
    }
}
