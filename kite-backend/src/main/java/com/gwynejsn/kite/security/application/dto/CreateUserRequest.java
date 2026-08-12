package com.gwynejsn.kite.security.application.dto;

import com.gwynejsn.kite.shared.enums.Gender;

public record CreateUserRequest(
        String email,
        String password,
        String firstName,
        String lastName,
        String profileImageLink,
        String bio,
        Gender gender,
        String publicKey
) {
}
