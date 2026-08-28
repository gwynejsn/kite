package com.gwynejsn.kite.conversation.infrastructure.listeners;

import com.gwynejsn.kite.conversation.application.ConversationService;
import com.gwynejsn.kite.social.domain.events.FriendRequestAcceptedEvent;
import com.gwynejsn.kite.social.domain.events.UserBlockedEvent;
import com.gwynejsn.kite.social.domain.events.UserUnblockedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
@RequiredArgsConstructor
public class UserRelationEventListener {

    private final ConversationService conversationService;

    // note we are using @EventListener here because we want it to update immediately (synchronous)

    /**
     * Auto initialize conversation whenever friend request is accepted
     * @param event
     */
    @EventListener
    public void onFriendRequestAccepted(FriendRequestAcceptedEvent event) {
        log.info("Received FriendRequestAcceptedEvent: userA={}, userB={}",
                event.userA(), event.userB());
        try {
            conversationService.initializeConversation(event.userA(), event.userB());
        } catch (Exception e) {
            log.error("Failed to initialize conversation from FriendRequestAcceptedEvent", e);
        }
    }

    /**
     * Broadcast on the conversation whenever a member of that convo is blocked
     * @param event
     */
    @EventListener
    public void onUserBlock(UserBlockedEvent event) {
        log.info("Received UserBlockedEvent: blocker={}, blocked={}", 
                event.blockerId(), event.blockedId());
        try {
            conversationService.setDirectConversationDisabled(event.blockerId(), event.blockedId(), true);
        } catch (Exception e) {
            log.error("Failed to disable direct conversation from UserBlockedEvent", e);
        }
    }

    @EventListener
    public void onUserUnblock(UserUnblockedEvent event) {
        log.info("Received UserUnblockedEvent: unblocker={}, unblocked={}", 
                event.unblockerId(), event.unblockedId());
        try {
            conversationService.setDirectConversationDisabled(event.unblockerId(), event.unblockedId(), false);
        } catch (Exception e) {
            log.error("Failed to enable direct conversation from UserUnblockedEvent", e);
        }
    }
}
