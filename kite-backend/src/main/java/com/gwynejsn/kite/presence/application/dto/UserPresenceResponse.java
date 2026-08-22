package com.gwynejsn.kite.presence.application.dto;

import com.gwynejsn.kite.presence.domain.enums.PresenceStatus;

import java.time.Instant;

public record UserPresenceResponse(
        String id,
        String userId,
        PresenceStatus status,
        Instant lastSeenAt,
        Instant updatedAt
) {
}
