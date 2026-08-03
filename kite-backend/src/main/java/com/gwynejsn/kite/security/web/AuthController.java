package com.gwynejsn.kite.security.web;

import com.gwynejsn.kite.security.application.AuthService;
import com.gwynejsn.kite.security.application.dto.CreateUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@Slf4j
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginUserResponse> login(@RequestBody LoginUserRequest loginUserRequest) {
        log.info("Login user request: {}", loginUserRequest);
        return ResponseEntity.ok(authService.loginUser(loginUserRequest));
    }

    @PostMapping("/sign-up")
    public ResponseEntity<String> signUp(@RequestBody CreateUserRequest user) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(authService.signUpUser(user));
    }

    // TODO: logout, refresh-token
}
