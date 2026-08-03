package com.gwynejsn.kite.shared.dto;

import lombok.Builder;
import org.springframework.http.HttpStatusCode;

@Builder
public record ErrorResponse(
        String errorMessage,
        String exceptionClass,
        HttpStatusCode statusCode
) {
}
