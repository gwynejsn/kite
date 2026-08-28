package com.gwynejsn.kite.social.domain.events;

import com.gwynejsn.kite.shared.domain.UserId;

public record UserBlockedEvent(
        UserId blockerId,
        UserId blockedId
) {
}
