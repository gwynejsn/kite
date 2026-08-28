package com.gwynejsn.kite.social.web;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import com.gwynejsn.kite.social.application.SocialService;
import com.gwynejsn.kite.social.application.dto.UserDiscoveryResponse;
import com.gwynejsn.kite.social.application.dto.UserRelationResponse;
import com.gwynejsn.kite.social.domain.RelationId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/social")
@RequiredArgsConstructor
@Slf4j
public class SocialController {

    private final SocialService socialService;

    @GetMapping("/people")
    public ResponseEntity<List<UserDiscoveryResponse>> getPeopleToConnect(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        return ResponseEntity.ok(socialService.getPeopleToConnect(authenticatedUser.getUserId()));
    }

    @PostMapping("/request/{targetUserId}")
    public ResponseEntity<UserRelationResponse> sendFriendRequest(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable String targetUserId
    ) {
        UserId targetId = new UserId(targetUserId);
        return ResponseEntity.ok(socialService.sendFriendRequest(authenticatedUser.getUserId(), targetId));
    }

    @PutMapping("/accept/{relationId}")
    public ResponseEntity<UserRelationResponse> acceptFriendRequest(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable String relationId
    ) {
        RelationId id = new RelationId(UUID.fromString(relationId));
        return ResponseEntity.ok(socialService.acceptFriendRequest(authenticatedUser.getUserId(), id));
    }

    @PutMapping("/decline/{relationId}")
    public ResponseEntity<UserRelationResponse> declineFriendRequest(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable String relationId
    ) {
        RelationId id = new RelationId(UUID.fromString(relationId));
        return ResponseEntity.ok(socialService.declineFriendRequest(authenticatedUser.getUserId(), id));
    }

    @PostMapping("/block/{targetUserId}")
    public ResponseEntity<UserRelationResponse> blockUser(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable String targetUserId
    ) {
        UserId targetId = new UserId(targetUserId);
        return ResponseEntity.ok(socialService.setUserBlockOption(authenticatedUser.getUserId(), targetId, true));
    }

    @PostMapping("/unblock/{targetUserId}")
    public ResponseEntity<UserRelationResponse> unblockUser(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable String targetUserId
    ) {
        UserId targetId = new UserId(targetUserId);
        return ResponseEntity.ok(socialService.setUserBlockOption(authenticatedUser.getUserId(), targetId, false));
    }

    @GetMapping("/pending")
    public ResponseEntity<List<UserRelationResponse>> getPendingRequests(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        return ResponseEntity.ok(socialService.getPendingRequests(authenticatedUser.getUserId()));
    }

    @GetMapping("/friends")
    public ResponseEntity<List<UserRelationResponse>> getFriends(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        return ResponseEntity.ok(socialService.getFriends(authenticatedUser.getUserId()));
    }
}
