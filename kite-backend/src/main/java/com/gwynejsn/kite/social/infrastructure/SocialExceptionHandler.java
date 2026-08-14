package com.gwynejsn.kite.social.infrastructure;

import com.gwynejsn.kite.security.api.dto.ErrorResponse;
import com.gwynejsn.kite.social.application.exceptions.RelationException;
import com.gwynejsn.kite.social.application.exceptions.RelationNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class SocialExceptionHandler {

    @ExceptionHandler(RelationNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleRelationNotFoundException(
            RelationNotFoundException ex,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(
                        ErrorResponse.builder()
                                .httpStatusCode(HttpStatus.NOT_FOUND)
                                .message(ex.getMessage())
                                .timestamp(Instant.now())
                                .path(request.getRequestURI())
                                .build()
                );
    }

    @ExceptionHandler(RelationException.class)
    public ResponseEntity<ErrorResponse> handleRelationException(
            RelationException ex,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(
                        ErrorResponse.builder()
                                .httpStatusCode(HttpStatus.BAD_REQUEST)
                                .message(ex.getMessage())
                                .timestamp(Instant.now())
                                .path(request.getRequestURI())
                                .build()
                );
    }
}
