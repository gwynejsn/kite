package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Base64;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {

    private JwtService jwtService;
    private static final String SECRET_KEY = Base64.getUrlEncoder().withoutPadding()
            .encodeToString("very-strong-secret-key-that-is-at-least-256-bits-long-for-hmac-sha-test!".getBytes());

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "SECRET", SECRET_KEY);
        ReflectionTestUtils.setField(jwtService, "EXPIRATION_IN_MINUTES", 60L);
    }

    @Nested
    @DisplayName("generateToken and validateToken")
    class GenerateAndValidateTests {

        @Test
        @DisplayName("""
                GIVEN: Valid email, userId, and roles
                WHEN: generateToken is called and then validated
                THEN: Claims contain the expected subject, userId, and roles
                """)
        void generateAndValidateToken_success() {
            String email = "test@example.com";
            UserId userId = new UserId(UUID.randomUUID());
            Set<Role> roles = Set.of(Role.USER);

            String token = jwtService.generateToken(email, userId, roles);

            assertThat(token).isNotBlank();

            Claims claims = jwtService.validateToken(token);
            assertThat(claims.getSubject()).isEqualTo(email);
            assertThat(claims.get("userId", String.class)).isEqualTo(userId.id().toString());
            assertThat(claims.get("roles", List.class)).contains("USER");
        }

        @Test
        @DisplayName("""
                GIVEN: Null userId
                WHEN: generateToken is called
                THEN: Token is valid and userId claim is not set
                """)
        void generateToken_nullUserId() {
            String email = "no-user@example.com";
            Set<Role> roles = Set.of(Role.USER);

            String token = jwtService.generateToken(email, null, roles);

            assertThat(token).isNotBlank();
            Claims claims = jwtService.validateToken(token);
            assertThat(claims.getSubject()).isEqualTo(email);
            assertThat(claims.get("userId")).isNull();
        }
    }

    @Nested
    @DisplayName("validateToken failure cases")
    class ValidateTokenFailureTests {

        @Test
        @DisplayName("""
                GIVEN: An expired JWT token
                WHEN: validateToken is called
                THEN: InvalidTokenException is thrown with 'Expired JWT token' message
                """)
        void validateToken_expired() {
            ReflectionTestUtils.setField(jwtService, "EXPIRATION_IN_MINUTES", -5L);
            String token = jwtService.generateToken("expired@example.com", new UserId(UUID.randomUUID()), Set.of(Role.USER));

            assertThatThrownBy(() -> jwtService.validateToken(token))
                    .isInstanceOf(InvalidTokenException.class)
                    .hasMessage("Expired JWT token");
        }

        @Test
        @DisplayName("""
                GIVEN: A tampered JWT token
                WHEN: validateToken is called
                THEN: InvalidTokenException is thrown
                """)
        void validateToken_tampered() {
            String token = jwtService.generateToken("test@example.com", new UserId(UUID.randomUUID()), Set.of(Role.USER));
            String tamperedToken = token.substring(0, token.lastIndexOf('.') + 1) + "tamperedSignature";

            assertThatThrownBy(() -> jwtService.validateToken(tamperedToken))
                    .isInstanceOf(InvalidTokenException.class);
        }

        @Test
        @DisplayName("""
                GIVEN: A malformed token string
                WHEN: validateToken is called
                THEN: InvalidTokenException is thrown
                """)
        void validateToken_malformed() {
            assertThatThrownBy(() -> jwtService.validateToken("not-a-valid-jwt-token"))
                    .isInstanceOf(InvalidTokenException.class);
        }
    }
}
