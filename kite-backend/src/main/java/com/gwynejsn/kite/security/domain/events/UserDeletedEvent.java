package com.gwynejsn.kite.security.domain.events;

import com.gwynejsn.kite.shared.domain.UserId;

public record UserDeletedEvent(UserId userId) {}
