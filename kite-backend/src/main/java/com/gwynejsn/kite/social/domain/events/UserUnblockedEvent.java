package com.gwynejsn.kite.social.domain.events;

import com.gwynejsn.kite.shared.domain.UserId;

public record UserUnblockedEvent(
        UserId unblockerId,
        UserId unblockedId
) {
}
