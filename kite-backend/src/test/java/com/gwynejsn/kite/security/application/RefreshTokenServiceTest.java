package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.dto.GeneratedRefreshToken;
import com.gwynejsn.kite.security.application.exceptions.InvalidRefreshTokenException;
import com.gwynejsn.kite.security.application.exceptions.RefreshTokenNotFoundException;
import com.gwynejsn.kite.security.domain.RefreshToken;
import com.gwynejsn.kite.security.infrastructure.RefreshTokenRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.AdditionalAnswers.returnsFirstArg;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RefreshTokenServiceTest {

    @Mock
    private RefreshTokenRepo refreshTokenRepo;

    @InjectMocks
    private RefreshTokenService refreshTokenService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(refreshTokenService, "EXPIRATION_IN_DAYS", 7L);
    }

    @Nested
    @DisplayName("hashToken")
    class HashTokenTests {

        @Test
        @DisplayName("""
                GIVEN: A raw token string
                WHEN: hashToken is called
                THEN: A deterministic SHA-256 hex string is returned
                """)
        void hashToken_deterministic() {
            String token = "sample-raw-token";
            String hash1 = RefreshTokenService.hashToken(token);
            String hash2 = RefreshTokenService.hashToken(token);

            assertThat(hash1).isNotEmpty().isEqualTo(hash2);
            assertThat(hash1).matches("^[a-f0-9]{64}$");
        }
    }

    @Nested
    @DisplayName("generateRefreshToken")
    class GenerateRefreshTokenTests {

        @Test
        @DisplayName("""
                GIVEN: A valid UserId
                WHEN: generateRefreshToken is called
                THEN: A new opaque token and hashed RefreshToken entity are created and saved
                """)
        void generateRefreshToken_success() {
            UserId userId = new UserId(UUID.randomUUID());
            when(refreshTokenRepo.save(any(RefreshToken.class))).then(returnsFirstArg());

            GeneratedRefreshToken result = refreshTokenService.generateRefreshToken(userId);

            assertThat(result).isNotNull();
            assertThat(result.rawToken()).isNotBlank();
            assertThat(result.entity()).isNotNull();
            assertThat(result.entity().getUserId()).isEqualTo(userId);
            assertThat(result.entity().isRevoked()).isFalse();
            assertThat(result.entity().getExpiresAt()).isAfter(Instant.now());

            ArgumentCaptor<RefreshToken> captor = ArgumentCaptor.forClass(RefreshToken.class);
            verify(refreshTokenRepo).save(captor.capture());
            RefreshToken saved = captor.getValue();
            assertThat(saved.getToken()).isEqualTo(RefreshTokenService.hashToken(result.rawToken()));
        }
    }

    @Nested
    @DisplayName("invalidateRefreshToken")
    class InvalidateRefreshTokenTests {

        @Test
        @DisplayName("""
                GIVEN: An existing active refresh token
                WHEN: invalidateRefreshToken is called
                THEN: The token is marked as revoked and saved
                """)
        void invalidateRefreshToken_success() {
            String rawToken = "my-token";
            String hashedToken = RefreshTokenService.hashToken(rawToken);
            RefreshToken existingToken = RefreshToken.builder()
                    .token(hashedToken)
                    .isRevoked(false)
                    .build();

            when(refreshTokenRepo.findRefreshTokenByToken(hashedToken)).thenReturn(Optional.of(existingToken));

            refreshTokenService.invalidateRefreshToken(rawToken);

            assertThat(existingToken.isRevoked()).isTrue();
            verify(refreshTokenRepo).save(existingToken);
        }

        @Test
        @DisplayName("""
                GIVEN: A non-existent refresh token
                WHEN: invalidateRefreshToken is called
                THEN: RefreshTokenNotFoundException is thrown
                """)
        void invalidateRefreshToken_notFound() {
            String rawToken = "missing-token";
            String hashedToken = RefreshTokenService.hashToken(rawToken);

            when(refreshTokenRepo.findRefreshTokenByToken(hashedToken)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> refreshTokenService.invalidateRefreshToken(rawToken))
                    .isInstanceOf(RefreshTokenNotFoundException.class);

            verify(refreshTokenRepo, never()).save(any());
        }
    }

    @Nested
    @DisplayName("rotateRefreshToken")
    class RotateRefreshTokenTests {

        @Test
        @DisplayName("""
                GIVEN: A valid, active, non-expired refresh token
                WHEN: rotateRefreshToken is called
                THEN: Old token is revoked and saved, and a newly generated refresh token is returned
                """)
        void rotateRefreshToken_success() {
            String oldRawToken = "valid-old-token";
            String oldHashedToken = RefreshTokenService.hashToken(oldRawToken);
            UserId userId = new UserId(UUID.randomUUID());

            RefreshToken oldToken = RefreshToken.builder()
                    .token(oldHashedToken)
                    .userId(userId)
                    .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
                    .isRevoked(false)
                    .build();

            when(refreshTokenRepo.findRefreshTokenByToken(oldHashedToken)).thenReturn(Optional.of(oldToken));
            when(refreshTokenRepo.save(any(RefreshToken.class))).then(returnsFirstArg());

            GeneratedRefreshToken rotated = refreshTokenService.rotateRefreshToken(oldRawToken);

            assertThat(oldToken.isRevoked()).isTrue();
            assertThat(rotated).isNotNull();
            assertThat(rotated.rawToken()).isNotBlank();
            assertThat(rotated.rawToken()).isNotEqualTo(oldRawToken);
            assertThat(rotated.entity().getUserId()).isEqualTo(userId);
        }

        @Test
        @DisplayName("""
                GIVEN: A non-existent refresh token
                WHEN: rotateRefreshToken is called
                THEN: InvalidRefreshTokenException is thrown
                """)
        void rotateRefreshToken_tokenNotFound() {
            String rawToken = "unknown-token";
            String hashedToken = RefreshTokenService.hashToken(rawToken);

            when(refreshTokenRepo.findRefreshTokenByToken(hashedToken)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> refreshTokenService.rotateRefreshToken(rawToken))
                    .isInstanceOf(InvalidRefreshTokenException.class);
        }

        @Test
        @DisplayName("""
                GIVEN: An expired refresh token
                WHEN: rotateRefreshToken is called
                THEN: InvalidRefreshTokenException is thrown
                """)
        void rotateRefreshToken_tokenExpired() {
            String rawToken = "expired-token";
            String hashedToken = RefreshTokenService.hashToken(rawToken);

            RefreshToken expiredToken = RefreshToken.builder()
                    .token(hashedToken)
                    .userId(new UserId(UUID.randomUUID()))
                    .expiresAt(Instant.now().minus(1, ChronoUnit.DAYS))
                    .isRevoked(false)
                    .build();

            when(refreshTokenRepo.findRefreshTokenByToken(hashedToken)).thenReturn(Optional.of(expiredToken));

            assertThatThrownBy(() -> refreshTokenService.rotateRefreshToken(rawToken))
                    .isInstanceOf(InvalidRefreshTokenException.class);
        }

        @Test
        @DisplayName("""
                GIVEN: An already revoked refresh token
                WHEN: rotateRefreshToken is called
                THEN: InvalidRefreshTokenException is thrown
                """)
        void rotateRefreshToken_tokenRevoked() {
            String rawToken = "revoked-token";
            String hashedToken = RefreshTokenService.hashToken(rawToken);

            RefreshToken revokedToken = RefreshToken.builder()
                    .token(hashedToken)
                    .userId(new UserId(UUID.randomUUID()))
                    .expiresAt(Instant.now().plus(1, ChronoUnit.DAYS))
                    .isRevoked(true)
                    .build();

            when(refreshTokenRepo.findRefreshTokenByToken(hashedToken)).thenReturn(Optional.of(revokedToken));

            assertThatThrownBy(() -> refreshTokenService.rotateRefreshToken(rawToken))
                    .isInstanceOf(InvalidRefreshTokenException.class);
        }
    }
}
