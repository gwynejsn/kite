package com.gwynejsn.kite.social.domain.events;

import com.gwynejsn.kite.shared.domain.UserId;

public record FriendRequestAcceptedEvent(
        UserId userA,
        UserId userB
) {
}
