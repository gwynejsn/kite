package com.gwynejsn.kite.presence.infrastructure.listeners;

import com.gwynejsn.kite.presence.application.UserPresenceService;
import com.gwynejsn.kite.presence.domain.enums.PresenceStatus;
import com.gwynejsn.kite.security.domain.events.UserDeletedEvent;
import com.gwynejsn.kite.security.domain.events.UserLoginEvent;
import com.gwynejsn.kite.security.domain.events.UserLogoutEvent;
import com.gwynejsn.kite.security.domain.events.UserRegisteredEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.modulith.events.ApplicationModuleListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class UserPresenceEventListener {
    private final UserPresenceService userPresenceService;

    /**
     * Updates the user presence when logging in
     * @param event
     */
    @ApplicationModuleListener
    public void onUserLogin(UserLoginEvent event) {
        userPresenceService.updateUserPresence(event.userId(), PresenceStatus.ONLINE);
    }


    /**
     * Initialize the creation of user presence when first sign up
     * @param event
     */
    @ApplicationModuleListener
    public void onUserSignUp(UserRegisteredEvent event) {
        userPresenceService.initializeUserPresence(event.userId());
        log.info("User Presence registered: {}", event.userId());
    }

    /**
     * Updates the user presence when logging out
     * @param event
     */
    @ApplicationModuleListener
    public void onUserLogout(UserLogoutEvent event) {
        userPresenceService.updateUserPresence(event.userId(), PresenceStatus.OFFLINE);
    }

    /**
     * Also delete the user presence when the user has been deleted
     * @param event
     */
    @ApplicationModuleListener
    public void onUserDeletedEvent(UserDeletedEvent event) {
        userPresenceService.deleteUserPresence(event.userId());
        log.info("Deleted user presence for userId: {}", event.userId());
    }
}
