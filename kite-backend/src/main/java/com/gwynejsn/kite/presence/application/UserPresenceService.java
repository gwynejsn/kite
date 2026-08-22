package com.gwynejsn.kite.presence.application;

import com.gwynejsn.kite.presence.application.dto.UserPresenceResponse;
import com.gwynejsn.kite.presence.application.exceptions.UserPresenceNotFound;
import com.gwynejsn.kite.presence.domain.PresenceId;
import com.gwynejsn.kite.presence.domain.UserPresence;
import com.gwynejsn.kite.presence.domain.enums.PresenceStatus;
import com.gwynejsn.kite.presence.infrastructure.UserPresenceRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static com.gwynejsn.kite.presence.infrastructure.UserPresenceMapper.INSTANCE;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserPresenceService {
    private final UserPresenceRepo userPresenceRepo;
    private final SimpMessagingTemplate messagingTemplate;

    public UserPresenceResponse getUserPresence(UserId userId) {
        return userPresenceRepo
                .findUserPresenceByUserId(userId)
                .map(INSTANCE::toResponse)
                .orElse(new UserPresenceResponse(
                        new PresenceId().id().toString(),
                        userId.id().toString(),
                        PresenceStatus.OFFLINE,
                        Instant.now(),
                        Instant.now()
                ));
    }

    public Map<String, UserPresenceResponse> getPresencesByUserIds(Set<UserId> userIds) {
        List<UserPresence> found = userPresenceRepo.findByUserIdIn(userIds.stream().toList());
        Map<String, UserPresenceResponse> map = found.stream()
                .collect(Collectors.toMap(
                        p -> p.getUserId().id().toString(),
                        INSTANCE::toResponse
                ));

        for (UserId uId : userIds) {
            String strId = uId.id().toString();
            if (!map.containsKey(strId)) {
                map.put(strId, new UserPresenceResponse(
                        new PresenceId().id().toString(),
                        strId,
                        PresenceStatus.OFFLINE,
                        Instant.now(),
                        Instant.now()
                ));
            }
        }
        return map;
    }

    @Transactional
    public void initializeUserPresence(UserId userId) {
        UserPresence presence = UserPresence
                .builder()
                .userId(userId)
                .id(new PresenceId())
                .status(PresenceStatus.ONLINE)
                .lastSeenAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        userPresenceRepo.save(presence);
        broadcastPresenceUpdate(INSTANCE.toResponse(presence));
    }

    @Transactional
    public void updateUserPresence(UserId userId, PresenceStatus status) {
        UserPresence userPresence = userPresenceRepo
                .findUserPresenceByUserId(userId)
                .orElseGet(() -> UserPresence.builder()
                        .userId(userId)
                        .id(new PresenceId())
                        .status(status)
                        .lastSeenAt(Instant.now())
                        .updatedAt(Instant.now())
                        .build());
        userPresence.setStatus(status);
        userPresence.setLastSeenAt(Instant.now());
        userPresence.setUpdatedAt(Instant.now());
        UserPresence saved = userPresenceRepo.save(userPresence);

        broadcastPresenceUpdate(INSTANCE.toResponse(saved));
    }

    @Transactional
    public void deleteUserPresence(UserId userId) {
        userPresenceRepo.deleteUserPresenceByUserId(userId);
    }

    public void broadcastPresenceUpdate(UserPresenceResponse presenceResponse) {
        if (presenceResponse.userId() != null) {
            log.info("Broadcasting presence update for user {}: {}", presenceResponse.userId(), presenceResponse.status());
            messagingTemplate.convertAndSend(
                    "/topic/presence." + presenceResponse.userId(),
                    presenceResponse
            );
        }
    }
}
