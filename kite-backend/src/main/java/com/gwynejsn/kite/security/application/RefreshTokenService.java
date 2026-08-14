package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.dto.GeneratedRefreshToken;
import com.gwynejsn.kite.security.application.exceptions.InvalidRefreshTokenException;
import com.gwynejsn.kite.security.application.exceptions.RefreshTokenNotFoundException;
import com.gwynejsn.kite.security.domain.RefreshToken;
import com.gwynejsn.kite.security.domain.RefreshTokenId;
import com.gwynejsn.kite.security.infrastructure.RefreshTokenRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Optional;

@Service
@Slf4j
public class RefreshTokenService {
    private final RefreshTokenRepo refreshTokenRepo;
    @Value("${jwt.refresh.token.expiration}")
    private long EXPIRATION_IN_DAYS;

    private static final SecureRandom secureRandom = new SecureRandom();

    private static String generateOpaqueToken() {
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);

        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    // hashing to protect when attackers get access to the DB
    public static String hashToken(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 algorithm not available", e);
        }
    }


    public RefreshTokenService(RefreshTokenRepo refreshTokenRepo) {
        this.refreshTokenRepo = refreshTokenRepo;
    }

    @Transactional
    public GeneratedRefreshToken generateRefreshToken(UserId userId) {
        String generatedToken = generateOpaqueToken();
        String hashedToken = hashToken(generatedToken);
        RefreshToken savedEntity = refreshTokenRepo.save(
                RefreshToken
                        .builder()
                        .id(new RefreshTokenId())
                        .userId(userId)
                        .token(hashedToken)
                        .expiresAt(Instant.now().plus(EXPIRATION_IN_DAYS, ChronoUnit.DAYS))
                        .isRevoked(false)
                        .build()
        );
        return new GeneratedRefreshToken(generatedToken, savedEntity);
    }

    private Optional<RefreshToken> getRefreshToken(String refreshToken) {
        String hashedToken = hashToken(refreshToken);
        return refreshTokenRepo.findRefreshTokenByToken(hashedToken);
    }

    @Transactional
    public void invalidateRefreshToken(String refreshToken) {
        Optional<RefreshToken> tokenFromDb = getRefreshToken(refreshToken);
        if (tokenFromDb.isPresent()) {
            RefreshToken token = tokenFromDb.get();
            token.setRevoked(true);
            refreshTokenRepo.save(token);
            return;
        }
        throw new RefreshTokenNotFoundException(refreshToken);
    }

    private boolean refreshTokenIsValid(RefreshToken refreshToken) {
        return refreshToken.getExpiresAt().isAfter(Instant.now()) && !refreshToken.isRevoked();
    }

    /**
     * Rotates the refresh tokens which makes it a one time use only
     * @param refreshToken raw refresh token string from client
     * @return a new GeneratedRefreshToken wrapper holding raw token and entity
     */
    @Transactional
    public GeneratedRefreshToken rotateRefreshToken(String refreshToken) {
        Optional<RefreshToken> tokenFromDb = getRefreshToken(refreshToken);
        if (tokenFromDb.isPresent() && refreshTokenIsValid(tokenFromDb.get())) {
            // invalidate the current refresh token
            RefreshToken token = tokenFromDb.get();
            token.setRevoked(true);
            refreshTokenRepo.save(token);
            // generate a new one
            return generateRefreshToken(token.getUserId());
        } else {
            throw new InvalidRefreshTokenException(refreshToken);
        }
    }
}
