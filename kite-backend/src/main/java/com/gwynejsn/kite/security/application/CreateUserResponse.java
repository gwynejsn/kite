package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.domain.UserId;

public record CreateUserResponse(
        UserId userId,
        String message
) {
}
