package com.gwynejsn.kite.profile.infrastructure.listeners;

import com.gwynejsn.kite.profile.application.UserProfileService;
import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.profile.domain.UserProfileId;
import com.gwynejsn.kite.security.domain.events.UserRegisteredEvent;
import com.gwynejsn.kite.shared.enums.PreferredTheme;
import lombok.extern.slf4j.Slf4j;
import org.springframework.modulith.events.ApplicationModuleListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class UserRegisteredEventListener {
    private final UserProfileService userProfileService;

    public UserRegisteredEventListener(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    /**
     * Create a User profile for the user created
     * @param event
     */
    @ApplicationModuleListener
    public void onUserRegisteredEvent(UserRegisteredEvent event) {
        UserProfile profile = UserProfile.builder()
                .id(new UserProfileId())
                .userId(event.userId())
                .firstName(event.firstName())
                .lastName(event.lastName())
                .username(event.username())
                .profileImageLink(event.profileImageLink())
                .bio(event.bio())
                .gender(event.gender())
                .preferredTheme(PreferredTheme.DARK)
                .build();
        userProfileService.createUserProfile(profile);
        log.info("Created user profile: {}", profile);
    }
}
