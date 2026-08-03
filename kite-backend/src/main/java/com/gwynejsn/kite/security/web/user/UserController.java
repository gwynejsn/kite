package com.gwynejsn.kite.security.web.user;

import com.gwynejsn.kite.security.application.dto.CreateUserRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("auth/user")
@Slf4j
public class UserController {

    // TODO: create account (signup), forgot password

}
