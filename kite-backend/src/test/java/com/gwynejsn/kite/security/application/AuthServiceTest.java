package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.dto.CreateUserRequest;
import com.gwynejsn.kite.security.application.dto.GeneratedRefreshToken;
import com.gwynejsn.kite.security.application.dto.LoginUserRequest;
import com.gwynejsn.kite.security.application.dto.LoginUserResponse;
import com.gwynejsn.kite.security.application.dto.RefreshTokenResponse;
import com.gwynejsn.kite.security.application.exceptions.UserAlreadyExistsException;
import com.gwynejsn.kite.security.domain.RefreshToken;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.domain.events.UserLoginEvent;
import com.gwynejsn.kite.security.domain.events.UserLogoutEvent;
import com.gwynejsn.kite.security.domain.events.UserRegisteredEvent;
import com.gwynejsn.kite.security.infrastructure.CustomUserDetails;
import com.gwynejsn.kite.security.infrastructure.JwtService;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.Role;
import com.gwynejsn.kite.shared.exceptions.UserNotFoundException;
import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepo userRepo;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private JwtService jwtService;

    @Mock
    private RefreshTokenService refreshTokenService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private AuthService authService;

    @Nested
    @DisplayName("loginUser")
    class LoginUserTests {

        @Test
        @DisplayName("""
                GIVEN: Valid credentials for an existing user
                WHEN: loginUser is called
                THEN: User is authenticated, JWT and refresh token are generated, login event published, and response returned
                """)
        void loginUser_success() {
            UserId userId = new UserId(UUID.randomUUID());
            User user = User.builder()
                    .id(userId)
                    .email("user@example.com")
                    .roles(Set.of(Role.USER))
                    .build();
            CustomUserDetails principal = CustomUserDetails.builder().user(user).build();
            Authentication auth = mock(Authentication.class);
            when(auth.getPrincipal()).thenReturn(principal);

            LoginUserRequest request = new LoginUserRequest("user@example.com", "password123");
            when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class))).thenReturn(auth);
            when(jwtService.generateToken("user@example.com", userId, Set.of(Role.USER))).thenReturn("jwt-token");
            GeneratedRefreshToken genRefreshToken = new GeneratedRefreshToken("raw-refresh-token", mock(RefreshToken.class));
            when(refreshTokenService.generateRefreshToken(userId)).thenReturn(genRefreshToken);

            LoginUserResponse response = authService.loginUser(request);

            assertThat(response).isNotNull();
            assertThat(response.token()).isEqualTo("jwt-token");
            assertThat(response.refreshToken()).isEqualTo("raw-refresh-token");
            assertThat(response.statusCode()).isEqualTo(HttpStatus.OK);

            ArgumentCaptor<UserLoginEvent> eventCaptor = ArgumentCaptor.forClass(UserLoginEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().userId()).isEqualTo(userId);
        }

        @Test
        @DisplayName("""
                GIVEN: Invalid credentials
                WHEN: loginUser is called
                THEN: AuthenticationException is propagated and no tokens or events are created
                """)
        void loginUser_invalidCredentials() {
            LoginUserRequest request = new LoginUserRequest("user@example.com", "wrong-password");
            when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                    .thenThrow(new BadCredentialsException("Bad credentials"));

            assertThatThrownBy(() -> authService.loginUser(request))
                    .isInstanceOf(BadCredentialsException.class)
                    .hasMessage("Bad credentials");

            verify(jwtService, never()).generateToken(any(), any(), any());
            verify(refreshTokenService, never()).generateRefreshToken(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("signUpUser")
    class SignUpUserTests {

        @Test
        @DisplayName("""
                GIVEN: Valid new user registration details
                WHEN: signUpUser is called
                THEN: User is saved, registered event published, and JWT token is returned
                """)
        void signUpUser_success() {
            CreateUserRequest request = new CreateUserRequest(
                    "john.doe@example.com",
                    "password123",
                    "John",
                    "Doe",
                    "https://example.com/avatar.png",
                    "Bio text",
                    Gender.MALE,
                    "public-key-abc"
            );

            when(userRepo.findUserByEmail(request.email())).thenReturn(Optional.empty());
            when(passwordEncoder.encode(request.password())).thenReturn("encoded-password");

            UserId generatedId = new UserId(UUID.randomUUID());
            User savedUser = User.builder()
                    .id(generatedId)
                    .email(request.email())
                    .password("encoded-password")
                    .publicKey(request.publicKey())
                    .roles(Set.of(Role.USER))
                    .build();
            when(userRepo.save(any(User.class))).thenReturn(savedUser);
            when(jwtService.generateToken(savedUser.getEmail(), savedUser.getId(), savedUser.getRoles()))
                    .thenReturn("jwt-token-xyz");

            String token = authService.signUpUser(request);

            assertThat(token).isEqualTo("jwt-token-xyz");

            ArgumentCaptor<UserRegisteredEvent> eventCaptor = ArgumentCaptor.forClass(UserRegisteredEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            UserRegisteredEvent event = eventCaptor.getValue();
            assertThat(event.userId()).isEqualTo(generatedId);
            assertThat(event.firstName()).isEqualTo("John");
            assertThat(event.lastName()).isEqualTo("Doe");
            assertThat(event.username()).isEqualTo("john.doe.example");
            assertThat(event.gender()).isEqualTo(Gender.MALE);
            assertThat(event.bio()).isEqualTo("Bio text");
            assertThat(event.profileImageLink()).isEqualTo("https://example.com/avatar.png");
        }

        @Test
        @DisplayName("""
                GIVEN: An email that already exists in the system
                WHEN: signUpUser is called
                THEN: UserAlreadyExistsException is thrown
                """)
        void signUpUser_userAlreadyExists() {
            CreateUserRequest request = new CreateUserRequest(
                    "existing@example.com",
                    "password123",
                    "Jane",
                    "Doe",
                    null,
                    null,
                    Gender.FEMALE,
                    "public-key"
            );

            when(userRepo.findUserByEmail(request.email()))
                    .thenReturn(Optional.of(User.builder().email(request.email()).build()));

            assertThatThrownBy(() -> authService.signUpUser(request))
                    .isInstanceOf(UserAlreadyExistsException.class)
                    .hasMessage("A user with email existing@example.com already exists.");

            verify(userRepo, never()).save(any());
            verify(eventPublisher, never()).publishEvent(any());
            verify(jwtService, never()).generateToken(any(), any(), any());
        }
    }

    @Nested
    @DisplayName("logoutUser")
    class LogoutUserTests {

        @Test
        @DisplayName("""
                GIVEN: A valid refresh token and current user ID
                WHEN: logoutUser is called
                THEN: Refresh token is invalidated and UserLogoutEvent is published
                """)
        void logoutUser_success() {
            String refreshToken = "raw-refresh-token";
            UserId userId = new UserId(UUID.randomUUID());

            authService.logoutUser(refreshToken, userId);

            verify(refreshTokenService).invalidateRefreshToken(refreshToken);
            ArgumentCaptor<UserLogoutEvent> eventCaptor = ArgumentCaptor.forClass(UserLogoutEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().userId()).isEqualTo(userId);
        }
    }

    @Nested
    @DisplayName("refreshToken")
    class RefreshTokenTests {

        @Test
        @DisplayName("""
                GIVEN: Valid refresh token and matching user
                WHEN: refreshToken is called
                THEN: Token is rotated and new JWT + refresh token are returned
                """)
        void refreshToken_success() {
            String oldToken = "old-refresh-token";
            UserId userId = new UserId(UUID.randomUUID());
            RefreshToken refreshTokenEntity = RefreshToken.builder().userId(userId).build();
            GeneratedRefreshToken rotated = new GeneratedRefreshToken("new-refresh-token", refreshTokenEntity);

            User user = User.builder()
                    .id(userId)
                    .email("user@example.com")
                    .roles(Set.of(Role.USER))
                    .build();

            when(refreshTokenService.rotateRefreshToken(oldToken)).thenReturn(rotated);
            when(userRepo.findUserById(userId)).thenReturn(Optional.of(user));
            when(jwtService.generateToken(user.getEmail(), user.getId(), user.getRoles())).thenReturn("new-jwt-token");

            RefreshTokenResponse response = authService.refreshToken(oldToken);

            assertThat(response).isNotNull();
            assertThat(response.token()).isEqualTo("new-jwt-token");
            assertThat(response.refreshToken()).isEqualTo("new-refresh-token");
        }

        @Test
        @DisplayName("""
                GIVEN: Refresh token rotates but user is not found in database
                WHEN: refreshToken is called
                THEN: UserNotFoundException is thrown
                """)
        void refreshToken_userNotFound() {
            String oldToken = "old-refresh-token";
            UserId userId = new UserId(UUID.randomUUID());
            RefreshToken refreshTokenEntity = RefreshToken.builder().userId(userId).build();
            GeneratedRefreshToken rotated = new GeneratedRefreshToken("new-refresh-token", refreshTokenEntity);

            when(refreshTokenService.rotateRefreshToken(oldToken)).thenReturn(rotated);
            when(userRepo.findUserById(userId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> authService.refreshToken(oldToken))
                    .isInstanceOf(UserNotFoundException.class)
                    .hasMessage("User not found for session");

            verify(jwtService, never()).generateToken(any(), any(), any());
        }
    }

    @Nested
    @DisplayName("getUsernamePasswordAuthenticationToken")
    class GetUsernamePasswordAuthenticationTokenTests {

        @Test
        @DisplayName("""
                GIVEN: Claims with wrapped UserId string and roles
                WHEN: getUsernamePasswordAuthenticationToken is called
                THEN: Valid UsernamePasswordAuthenticationToken with CustomUserDetails principal is returned
                """)
        void getUsernamePasswordAuthenticationToken_wrappedUserId() {
            UUID rawUuid = UUID.randomUUID();
            Claims claims = mock(Claims.class);
            when(claims.getSubject()).thenReturn("john@example.com");
            when(claims.get("userId", String.class)).thenReturn("UserId[id=" + rawUuid + "]");
            when(claims.get("roles", List.class)).thenReturn(List.of("USER"));

            UsernamePasswordAuthenticationToken authentication =
                    authService.getUsernamePasswordAuthenticationToken(claims);

            assertThat(authentication).isNotNull();
            assertThat(authentication.getPrincipal()).isInstanceOf(CustomUserDetails.class);
            CustomUserDetails principal = (CustomUserDetails) authentication.getPrincipal();
            assertThat(principal.getUsername()).isEqualTo("john@example.com");
            assertThat(principal.getUserId().id()).isEqualTo(rawUuid);
            assertThat(principal.user().getRoles()).containsExactly(Role.USER);
        }

        @Test
        @DisplayName("""
                GIVEN: Claims with raw UUID string and null roles
                WHEN: getUsernamePasswordAuthenticationToken is called
                THEN: Valid token returned with empty roles
                """)
        void getUsernamePasswordAuthenticationToken_rawUuidAndNullRoles() {
            UUID rawUuid = UUID.randomUUID();
            Claims claims = mock(Claims.class);
            when(claims.getSubject()).thenReturn("john@example.com");
            when(claims.get("userId", String.class)).thenReturn(rawUuid.toString());
            when(claims.get("roles", List.class)).thenReturn(null);

            UsernamePasswordAuthenticationToken authentication =
                    authService.getUsernamePasswordAuthenticationToken(claims);

            assertThat(authentication).isNotNull();
            CustomUserDetails principal = (CustomUserDetails) authentication.getPrincipal();
            assertThat(principal.getUserId().id()).isEqualTo(rawUuid);
            assertThat(principal.user().getRoles()).isEmpty();
        }

        @Test
        @DisplayName("""
                GIVEN: Claims without userId
                WHEN: getUsernamePasswordAuthenticationToken is called
                THEN: InvalidTokenException is thrown
                """)
        void getUsernamePasswordAuthenticationToken_missingUserId() {
            Claims claims = mock(Claims.class);
            when(claims.getSubject()).thenReturn("john@example.com");
            when(claims.get("userId", String.class)).thenReturn(null);

            assertThatThrownBy(() -> authService.getUsernamePasswordAuthenticationToken(claims))
                    .isInstanceOf(InvalidTokenException.class)
                    .hasMessage("Token missing userId claim. Please log in again.");
        }
    }
}
