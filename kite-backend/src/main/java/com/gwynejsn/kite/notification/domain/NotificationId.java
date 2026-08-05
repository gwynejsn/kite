package com.gwynejsn.kite.notification.domain;

import com.gwynejsn.kite.shared.domain.DomainId;
import org.springframework.util.Assert;

import java.util.UUID;

public record NotificationId(UUID id) implements DomainId {
    public NotificationId {
        Assert.notNull(id, "id is required");
    }

    public NotificationId() {
        this(UUID.randomUUID());
    }
}
