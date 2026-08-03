package com.gwynejsn.kite.profile.web;

import com.gwynejsn.kite.profile.application.UserProfileService;
import com.gwynejsn.kite.profile.application.dto.UpdateUserProfileRequest;
import com.gwynejsn.kite.profile.application.dto.UserProfileResponse;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/user-profile")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    /**
     * If user, get own profile.
     * If admin with no specified userId, get own profile
     * If admin with specified userId, get that specific userId's user profile
     * @param userId
     * @param currentUserDetails
     * @return A specific user profile
     */
    @GetMapping
    public ResponseEntity<UserProfileResponse> getUserProfile(
            @RequestParam(required = false) UserId userId,
            @AuthenticationPrincipal AuthenticatedUser currentUserDetails
    ) {
        return ResponseEntity.ok(
                userProfileService.getUserProfile(userId, currentUserDetails)
        );
    }

    /**
     * Only admins can return all user profiles.
     * @return List of user profiles
     */
    @GetMapping("/all")
    public ResponseEntity<List<UserProfileResponse>> getAllUserProfiles() {
        return ResponseEntity.ok(
                userProfileService.getUserProfiles()
        );
    }

    /**
     * You can only update your own user profile.
     * @param updateUserProfileRequest
     * @param currentUserDetails
     * @return Updated user profile
     */
    @PutMapping
    public ResponseEntity<UserProfileResponse> updateUserProfile(
            @RequestBody UpdateUserProfileRequest updateUserProfileRequest,
            @AuthenticationPrincipal AuthenticatedUser currentUserDetails
    ) {
        return ResponseEntity.ok(
                userProfileService.updateUserProfile(updateUserProfileRequest, currentUserDetails)
        );
    }
}