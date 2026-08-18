package com.gwynejsn.kite.presence.infrastructure;

import com.gwynejsn.kite.presence.domain.UserPresence;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserPresenceRepo extends MongoRepository<UserPresence, UUID> {
    Optional<UserPresence> findUserPresenceByUserId(UserId userId);

    List<UserPresence> findByUserIdIn(List<UserId> userIds);

    void deleteUserPresenceByUserId(UserId userId);
}
