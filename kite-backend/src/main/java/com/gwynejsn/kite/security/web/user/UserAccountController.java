package com.gwynejsn.kite.security.web.user;

import com.gwynejsn.kite.security.application.AccountService;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * User specific account controller
 */
@RestController
@RequestMapping("/account")
@Slf4j
public class UserAccountController {
    private final AccountService accountService;

    public UserAccountController(AccountService accountService) {
        this.accountService = accountService;
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
}
