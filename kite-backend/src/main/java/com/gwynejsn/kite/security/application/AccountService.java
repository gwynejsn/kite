package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.api.UserServiceApi;
import com.gwynejsn.kite.shared.exceptions.UserNotFoundException;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.domain.events.UserDeletedEvent;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Stream;

@Service
@Slf4j
@RequiredArgsConstructor
public class AccountService implements UserServiceApi {
    private final UserRepo userRepo;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public void deleteUser(UserId userId) {
        User user = userRepo.findUserById(userId)
                .orElseThrow(() -> new UserNotFoundException("User " + userId + " not found."));
        userRepo.delete(user);
        eventPublisher.publishEvent(new UserDeletedEvent(userId));
        log.info("User " + userId + " has been deleted.");
    }

    public String getUserPublicKey(UserId userId) {
        return userRepo.findUserById(userId)
                .map(User::getPublicKey)
                .orElseThrow(() -> new UserNotFoundException("User " + userId + " not found."));
    }

    @Override
    public void usersExist(Set<UserId> members) {
        members
                .forEach(userId ->
                        userRepo.findUserById(userId)
                                .orElseThrow(() -> new UserNotFoundException(userId.id() + " not Found!"))
                );
    }
}
