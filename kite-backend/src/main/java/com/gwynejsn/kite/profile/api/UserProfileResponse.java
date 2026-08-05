package com.gwynejsn.kite.profile.api;

import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.PreferredTheme;

public record UserProfileResponse(
        String userId,
    String firstName,
    String lastName,
    String username,
    String profileImageLink,
    String bio,
    Gender gender,
    PreferredTheme preferredTheme
) {
}
