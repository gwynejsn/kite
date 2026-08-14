package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.RefreshToken;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepo extends MongoRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findRefreshTokenByToken(String hashedToken);
}
