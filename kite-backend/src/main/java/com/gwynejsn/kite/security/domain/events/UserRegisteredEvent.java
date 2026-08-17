package com.gwynejsn.kite.security.domain.events;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Gender;
import lombok.Builder;

@Builder
public record UserRegisteredEvent(
        UserId userId,
        String firstName,
        String lastName,
        String username,
        String profileImageLink,
        String bio,
        Gender gender
) {
}
