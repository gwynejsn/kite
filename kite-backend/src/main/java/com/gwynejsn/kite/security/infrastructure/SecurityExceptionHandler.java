package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.infrastructure.exceptions.AccountDisabledException;
import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import com.gwynejsn.kite.security.api.dto.ErrorResponse;
import com.gwynejsn.kite.security.application.exceptions.UserAlreadyExistsException;
import org.springframework.dao.DuplicateKeyException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authorization.AuthorizationDeniedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class SecurityExceptionHandler {

    @ExceptionHandler({InvalidTokenException.class})
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

    @ExceptionHandler({BadCredentialsException.class})
    public ResponseEntity<ErrorResponse> handleBadCredentials(BadCredentialsException ex, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(
                        ErrorResponse
                                .builder()
                                .message("The username or password is incorrect")
                                .path(request.getRequestURI())
                                .httpStatusCode(HttpStatus.UNAUTHORIZED)
                                .timestamp(Instant.now())
                                .build()
                );
    }

    @ExceptionHandler({AccessDeniedException.class, AuthorizationDeniedException.class})
    public ResponseEntity<ErrorResponse> handleAccessDenied(
            Exception ex,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(
                        ErrorResponse
                                .builder()
                                .message("You do not have permission to perform this action")
                                .path(request.getRequestURI())
                                .httpStatusCode(HttpStatus.FORBIDDEN)
                                .timestamp(Instant.now())
                                .build()
                );
    }

    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleUserAlreadyExistsException(
            UserAlreadyExistsException ex,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(
                        ErrorResponse
                                .builder()
                                .message(ex.getMessage())
                                .path(request.getRequestURI())
                                .httpStatusCode(HttpStatus.CONFLICT)
                                .timestamp(Instant.now())
                                .build()
                );
    }

    @ExceptionHandler(DuplicateKeyException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateKeyException(
            DuplicateKeyException ex,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(
                        ErrorResponse
                                .builder()
                                .message("A user with this email or username already exists.")
                                .path(request.getRequestURI())
                                .httpStatusCode(HttpStatus.CONFLICT)
                                .timestamp(Instant.now())
                                .build()
                );
    }

    @ExceptionHandler({AccountDisabledException.class})
    public ResponseEntity<ErrorResponse> handleAccountDisabledException(AccountDisabledException ex, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(
                        ErrorResponse
                                .builder()
                                .message(ex.getMessage())
                                .path(request.getRequestURI())
                                .httpStatusCode(HttpStatus.UNAUTHORIZED)
                                .timestamp(Instant.now())
                                .build()
                );
    }
}
