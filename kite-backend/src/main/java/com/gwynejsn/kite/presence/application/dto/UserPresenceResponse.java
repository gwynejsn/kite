package com.gwynejsn.kite.presence.application.dto;

import com.gwynejsn.kite.presence.domain.PresenceId;
import com.gwynejsn.kite.presence.domain.enums.PresenceStatus;
import com.gwynejsn.kite.shared.domain.UserId;

import java.time.Instant;

public record UserPresenceResponse(
        PresenceId id,
        UserId userId,
        PresenceStatus status,
        Instant lastSeenAt,
        Instant updatedAt
) {
}
