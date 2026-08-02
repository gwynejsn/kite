package com.gwynejsn.kite.profile.web;

import com.gwynejsn.kite.profile.application.UserProfileService;
import com.gwynejsn.kite.profile.application.dto.UserProfileResponse;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user-profile")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping
    public UserProfileResponse getUserProfile(
            @RequestParam(required = false) UserId userId,
            @AuthenticationPrincipal AuthenticatedUser currentUserDetails
    ) {
        return userProfileService.getUserProfile(userId, currentUserDetails);
    }
}