package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.infrastructure.exceptions.ConversationNotFoundException;
import com.gwynejsn.kite.security.api.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class ConversationExceptionHandler {
    @ExceptionHandler(ConversationNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleConversationNotFoundException(ConversationNotFoundException ex, HttpServletRequest request) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(
                ErrorResponse
                        .builder()
                        .message(ex.getMessage())
                        .httpStatusCode(HttpStatus.NOT_FOUND)
                        .path(request.getRequestURI())
                        .timestamp(Instant.now())
                        .build()
        );
    }
}
