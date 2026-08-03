package com.gwynejsn.kite.profile.application.dto;

import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.PreferredTheme;

public record UpdateUserProfileRequest(
        String firstName,
        String lastName,
        String username,
        String profileImageLink,
        String bio,
        Gender gender,
        PreferredTheme preferredTheme
) {
}
