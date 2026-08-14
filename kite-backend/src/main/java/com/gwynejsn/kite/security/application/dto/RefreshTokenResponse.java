package com.gwynejsn.kite.security.application.dto;

import lombok.Builder;

@Builder
public record RefreshTokenResponse(
        String token,
        String refreshToken
) {
}
