package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.dto.CreateUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserResponse;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.domain.events.UserRegisteredEvent;
import com.gwynejsn.kite.security.infrastructure.JwtService;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.security.application.exceptions.UserNotFoundException;
import com.gwynejsn.kite.security.application.exceptions.UserAlreadyExistsException;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;

@Service
@Slf4j
@RequiredArgsConstructor
public class AuthService {
    private final UserRepo userRepo;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final ApplicationEventPublisher eventPublisher;

    public LoginUserResponse loginUser(LoginUserRequest loginUserRequest) throws UserNotFoundException, AuthenticationException {
        log.info("Login user request: {}", loginUserRequest);
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginUserRequest.email(),
                        loginUserRequest.password()
                )
        );
        User user = userRepo
                .findUserByEmail(loginUserRequest.email())
                .orElseThrow(() -> new UserNotFoundException(loginUserRequest.email() + " not found."));

        log.info("Logged in user: {}", user);
        String jwtToken = jwtService.generateToken(user.getEmail());
        return LoginUserResponse.builder().jwtToken(jwtToken).statusCode(HttpStatus.OK).build();
    }

    @Transactional
    public String signUpUser(CreateUserRequest user) {
        if (userRepo.findUserByEmail(user.email()).isPresent()) {
            throw new UserAlreadyExistsException("A user with email " + user.email() + " already exists.");
        }

        User userCreated = userRepo.save(
                User
                        .builder()
                        .id(new UserId())
                        .email(user.email())
                        .password(passwordEncoder.encode(user.password()))
                        .roles(Set.of(Role.USER))
                        .build()

        );
        eventPublisher.publishEvent(UserRegisteredEvent
                .builder()
                .userId(userCreated.getId())
                .firstName(user.firstName())
                .lastName(user.lastName())
                .username(user.email()) // default username is the email
                .gender(user.gender())
                .bio(user.bio())
                .profileImageLink(user.profileImageLink())
                .build()
        );
        return jwtService.generateToken(userCreated.getEmail());
    }
}
