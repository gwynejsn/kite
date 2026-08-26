package com.gwynejsn.kite.media.infrastructure;

import com.gwynejsn.kite.media.application.exceptions.NoFileFoundException;
import com.gwynejsn.kite.media.application.exceptions.NoFileParameterException;
import com.gwynejsn.kite.media.application.exceptions.UploadingFileIOException;
import com.gwynejsn.kite.security.api.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;

@RestControllerAdvice
public class MediaExceptionHandler {
    @ExceptionHandler(NoFileParameterException.class)
    public ResponseEntity<ErrorResponse> handleNoFileParameterException(
            NoFileParameterException ex,
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

    @ExceptionHandler(NoFileFoundException.class)
    public ResponseEntity<ErrorResponse> handleNoFileFoundException(
            NoFileFoundException ex,
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
    @ExceptionHandler(UploadingFileIOException.class)
    public ResponseEntity<ErrorResponse> handleNoFileFoundException(
            UploadingFileIOException ex,
            HttpServletRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(
                        ErrorResponse.builder()
                                .httpStatusCode(HttpStatus.INTERNAL_SERVER_ERROR)
                                .message(ex.getMessage())
                                .timestamp(Instant.now())
                                .path(request.getRequestURI())
                                .build()
                );
    }
}
