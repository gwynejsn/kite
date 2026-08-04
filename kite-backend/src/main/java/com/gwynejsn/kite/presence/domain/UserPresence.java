package com.gwynejsn.kite.presence.domain;

import com.gwynejsn.kite.presence.domain.enums.PresenceStatus;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "user_presences")
public class UserPresence {

    @Id
    private PresenceId id;
    private UserId userId;
    private PresenceStatus status;
    private Instant lastSeenAt;
    private String customStatus;
    private Instant updatedAt;
}
