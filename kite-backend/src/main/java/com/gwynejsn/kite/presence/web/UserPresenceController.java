package com.gwynejsn.kite.presence.web;

import com.gwynejsn.kite.presence.application.UserPresenceService;
import com.gwynejsn.kite.presence.application.dto.UserPresenceResponse;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/presence")
@RequiredArgsConstructor
@Slf4j
public class UserPresenceController {
    private final UserPresenceService userPresenceService;

    @GetMapping("/{userId}")
    public ResponseEntity<UserPresenceResponse> getPresence(@PathVariable String userId) {
        return ResponseEntity.ok(userPresenceService.getUserPresence(new UserId(UUID.fromString(userId))));
    }

    @PostMapping("/batch")
    public ResponseEntity<Map<String, UserPresenceResponse>> getBatchPresence(@RequestBody Set<String> userIds) {
        Set<UserId> ids = userIds.stream()
                .map(id -> new UserId(UUID.fromString(id)))
                .collect(Collectors.toSet());
        return ResponseEntity.ok(userPresenceService.getPresencesByUserIds(ids));
    }
}
