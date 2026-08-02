package com.gwynejsn.kite.security.web.user;

import com.gwynejsn.kite.security.application.UserService;
import com.gwynejsn.kite.security.application.dto.LoginUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth/user")
@Slf4j
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginUserResponse> login(@RequestBody LoginUserRequest loginUserRequest) {
        log.info("Login user request: {}", loginUserRequest);
        return ResponseEntity.ok(userService.loginUser(loginUserRequest));
    }
}
