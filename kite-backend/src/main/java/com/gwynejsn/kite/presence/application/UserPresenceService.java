package com.gwynejsn.kite.presence.application;

import com.gwynejsn.kite.presence.application.exceptions.UserPresenceNotFound;
import com.gwynejsn.kite.presence.domain.PresenceId;
import com.gwynejsn.kite.presence.domain.UserPresence;
import com.gwynejsn.kite.presence.domain.enums.PresenceStatus;
import com.gwynejsn.kite.presence.infrastructure.UserPresenceRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserPresenceService {
    private final UserPresenceRepo userPresenceRepo;

    public

    @Transactional
    public void initializeUserPresence(UserId userId) {
        userPresenceRepo.save(UserPresence
                .builder()
                .userId(userId)
                .id(new PresenceId())
                .status(PresenceStatus.ONLINE)
                .lastSeenAt(Instant.now())
                .updatedAt(Instant.now())
                .build());
    }

    @Transactional
    public void updateUserPresence(UserId userId, PresenceStatus status) {
        UserPresence userPresence = userPresenceRepo
                .findUserPresenceByUserId(userId)
                .orElseThrow(() -> new UserPresenceNotFound("User presence not found"));
        userPresence.setStatus(status);
        userPresence.setLastSeenAt(Instant.now());
        userPresence.setUpdatedAt(Instant.now());
        userPresenceRepo.save(userPresence);
    }

    @Transactional
    public void deleteUserPresence(UserId userId) {
        userPresenceRepo.deleteUserPresenceByUserId(userId);
    }
}
