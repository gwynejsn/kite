package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import com.gwynejsn.kite.shared.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class SecurityExceptionHandler {

    @ExceptionHandler(InvalidTokenException.class)
    public ResponseEntity<ErrorResponse> handleInvalidTokenException(InvalidTokenException ex, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(
                        ErrorResponse
                                .builder()
                                .message("The provided JWT token is invalid or expired")
                                .path(request.getRequestURI())
                                .httpStatusCode(HttpStatus.UNAUTHORIZED)
                                .timestamp(Instant.now())
                                .build()
                );
    }
}
