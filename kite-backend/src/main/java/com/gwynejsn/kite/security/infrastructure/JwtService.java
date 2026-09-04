package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.infrastructure.exceptions.InvalidTokenException;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;

@Component
@Slf4j
public class JwtService {
    @Value("${jwt.secret.key}")
    private String SECRET;

    // in minutes
    @Value("${jwt.token.expiration}")
    private long EXPIRATION_IN_MINUTES;

    public String generateToken(String email, UserId userId, Set<Role> roles) {
        Map<String, Object> claims = new HashMap<>();
        // we are putting the roles and userId in the JWT
        // to avoid calling the db everytime we validate just to get user details
        claims.put("roles", roles);
        if (userId != null) {
            claims.put("userId", userId.id().toString());
        }
        return createToken(claims, email);
    }

    private String createToken(Map<String, Object> claims, String email) {
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(email)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(Date.from(Instant.now().plus(EXPIRATION_IN_MINUTES, ChronoUnit.MINUTES)))
                .signWith(getSignKey(), SignatureAlgorithm.HS256).compact();
    }

    private SecretKey getSignKey() {
        byte[] keyBytes;
        try {
            keyBytes = Decoders.BASE64URL.decode(SECRET);
        } catch (Exception e) {
            keyBytes = SECRET.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        }
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public Claims validateToken(String token) throws InvalidTokenException, JwtException {
        try {
            return Jwts.parser()
                    .verifyWith(getSignKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException ex) {
            log.info("Expired JWT token");
            throw new InvalidTokenException("Expired JWT token");
        } catch (SignatureException ex) {
            log.info("Token is invalid/tampered!");
            throw new InvalidTokenException("Token is invalid/tampered!");
        } catch (JwtException ex) {
            log.info("Invalid JWT token");
            throw new InvalidTokenException("Invalid JWT token");
        }
    }
}
