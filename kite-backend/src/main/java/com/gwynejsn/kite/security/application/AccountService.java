package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.application.exceptions.UserNotFoundException;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.domain.events.UserDeletedEvent;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class AccountService {
    private final UserRepo userRepo;
    private final ApplicationEventPublisher eventPublisher;

    public AccountService(UserRepo userRepo, ApplicationEventPublisher eventPublisher) {
        this.userRepo = userRepo;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public void deleteUser(UserId userId) {
        User user = userRepo.findUserById(userId)
                .orElseThrow(() -> new UserNotFoundException("User " + userId + " not found."));
        userRepo.delete(user);
        eventPublisher.publishEvent(new UserDeletedEvent(userId));
        log.info("User " + userId + " has been deleted.");
    }
}
