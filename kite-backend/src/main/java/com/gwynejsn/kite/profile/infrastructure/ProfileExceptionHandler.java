package com.gwynejsn.kite.profile.infrastructure;


import com.gwynejsn.kite.profile.application.exceptions.UserIdNotSpecifiedException;
import com.gwynejsn.kite.profile.application.exceptions.UserProfileNotFoundException;
import com.gwynejsn.kite.security.api.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class ProfileExceptionHandler {

    @ExceptionHandler(UserIdNotSpecifiedException.class)
    public ResponseEntity<ErrorResponse> handleUserIdNotSpecifiedException(UserIdNotSpecifiedException ex, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(
                        ErrorResponse
                                .builder()
                                .httpStatusCode(HttpStatus.NOT_FOUND)
                                .message("User not found")
                                .timestamp(Instant.now())
                                .path(request.getRequestURI())
                                .build()
                );
    }

    @ExceptionHandler(UserProfileNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserProfileNotFoundException(UserProfileNotFoundException ex, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(
                        ErrorResponse
                                .builder()
                                .httpStatusCode(HttpStatus.NOT_FOUND)
                                .message("Profile not found")
                                .timestamp(Instant.now())
                                .path(request.getRequestURI())
                                .build()
                );
    }
}
