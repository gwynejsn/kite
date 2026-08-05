package com.gwynejsn.kite.social.domain;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record RelationId(UUID id) implements DomainId {
    public RelationId {
        Assert.notNull(id, "id is required");
    }

    public RelationId() {
        this(UUID.randomUUID());
    }
}
