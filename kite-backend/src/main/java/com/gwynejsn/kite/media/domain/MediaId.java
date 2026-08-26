package com.gwynejsn.kite.media.domain;

import org.springframework.util.Assert;

import java.util.UUID;

public record MediaId(UUID id){
    public MediaId {
        Assert.notNull(id, "id is required");
    }

    public MediaId() {
        this(UUID.randomUUID());
    }
}
