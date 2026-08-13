package com.gwynejsn.kite.security.web.user;

import com.gwynejsn.kite.security.application.AccountService;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * User specific account controller
 */
@RestController
@RequestMapping("/account")
@Slf4j
public class UserAccountController {
    private final AccountService accountService;
    private final UserRepo userRepo;

    public UserAccountController(AccountService accountService, UserRepo userRepo) {
        this.accountService = accountService;
        this.userRepo = userRepo;
    }

    /**
     * Delete own account
     * @param currentUser
     * @return
     */
    @DeleteMapping
    public ResponseEntity<Void> deleteAccount(@AuthenticationPrincipal AuthenticatedUser currentUser) {
        log.info("Request to delete account for userId: {}", currentUser.getUserId());
        accountService.deleteUser(currentUser.getUserId());
        return ResponseEntity.noContent().build();
    }

    /**
     * Get user's public key
     * @return public key
     */
    @GetMapping("/{userId}/key")
    public ResponseEntity<String> getKey(@PathVariable UserId userId) {
        log.info("Request to get key for userId: {}", userId);
        return ResponseEntity.ok(accountService.getUserPublicKey(userId));
    }
}
