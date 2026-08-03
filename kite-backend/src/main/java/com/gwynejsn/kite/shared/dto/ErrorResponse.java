package com.gwynejsn.kite.shared.dto;

import lombok.Builder;
import org.springframework.http.HttpStatusCode;

import java.time.Instant;

@Builder
public record ErrorResponse(
        Instant timestamp,
        HttpStatusCode httpStatusCode,
        String message,
        String path
) {
}
