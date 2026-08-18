package com.gwynejsn.kite.presence.infrastructure;

import com.gwynejsn.kite.presence.domain.UserPresence;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserPresenceRepo extends MongoRepository<UserPresence, UUID> {
    Optional<UserPresence> findUserPresenceByUserId(UserId userId);

    void deleteUserPresenceByUserId(UserId userId);
}
