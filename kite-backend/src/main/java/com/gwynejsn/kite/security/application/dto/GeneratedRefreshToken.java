package com.gwynejsn.kite.security.application.dto;

import com.gwynejsn.kite.security.domain.RefreshToken;

public record GeneratedRefreshToken(
        String rawToken,
        RefreshToken entity
) {}
