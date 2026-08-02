package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.dto.LoginUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserResponse;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.exceptions.UserNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepo userRepo;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public UserService(UserRepo userRepo, AuthenticationManager authenticationManager, JwtService jwtService) {
        this.userRepo = userRepo;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
    }

    public LoginUserResponse loginUser(LoginUserRequest loginUserRequest) throws UserNotFoundException, AuthenticationException {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginUserRequest.email(),
                        loginUserRequest.password()
                )
        );
        User user = userRepo
                .findUserByEmail(loginUserRequest.email())
                .orElseThrow(() -> new UserNotFoundException(loginUserRequest.email() + " not found."));
        String jwtToken = jwtService.generateToken(user.getEmail());
        return LoginUserResponse.builder().jwtToken(jwtToken).statusCode(HttpStatus.OK).build();
    }
}
