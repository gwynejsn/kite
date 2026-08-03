package com.gwynejsn.kite.profile.infrastructure;


import com.gwynejsn.kite.profile.application.exceptions.UserIdNotSpecifiedException;
import com.gwynejsn.kite.profile.application.exceptions.UserProfileNotFoundException;
import com.gwynejsn.kite.shared.dto.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ProfileExceptionHandler {

    @ExceptionHandler(UserIdNotSpecifiedException.class)
    public ResponseEntity<ErrorResponse> handleUserIdNotSpecifiedException(UserIdNotSpecifiedException ex) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(
                        ErrorResponse
                                .builder()
                                .statusCode(HttpStatus.NOT_FOUND)
                                .errorMessage(ex.getMessage())
                                .exceptionClass(ex.getClass().getName())
                                .build()
                );
    }

    @ExceptionHandler(UserProfileNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserProfileNotFoundException(UserProfileNotFoundException ex) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(
                        ErrorResponse
                                .builder()
                                .statusCode(HttpStatus.NOT_FOUND)
                                .errorMessage(ex.getMessage())
                                .exceptionClass(ex.getClass().getName())
                                .build()
                );
    }
}
