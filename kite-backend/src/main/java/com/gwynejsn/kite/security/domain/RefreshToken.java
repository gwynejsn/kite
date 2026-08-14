package com.gwynejsn.kite.security.domain;

import com.gwynejsn.kite.shared.domain.UserId;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Document(collection = "refresh_tokens")
@Builder
@Setter
@Getter
public class RefreshToken {
    @Id
    private RefreshTokenId id;
    private UserId userId;
    @Indexed(unique = true)
    private String token;
    private boolean isRevoked;
    private Instant expiresAt;
}
