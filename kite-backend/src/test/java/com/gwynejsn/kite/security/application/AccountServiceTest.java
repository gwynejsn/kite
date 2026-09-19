package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.domain.events.UserDeletedEvent;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.exceptions.UserNotFoundException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AccountServiceTest {

    @Mock
    private UserRepo userRepo;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private AccountService accountService;

    @Nested
    @DisplayName("deleteUser")
    class DeleteUserTests {

        @Test
        @DisplayName("""
                GIVEN: User exists in database
                WHEN: deleteUser is called with matching userId
                THEN: User is deleted from repo and UserDeletedEvent is published
                AND: no exception is thrown
                """)
        void deleteUser_success() {
            UserId userId = new UserId(UUID.randomUUID());
            User user = User.builder()
                    .id(userId)
                    .email("test@example.com")
                    .publicKey("public-key-123")
                    .build();

            when(userRepo.findUserById(userId)).thenReturn(Optional.of(user));

            accountService.deleteUser(userId);

            verify(userRepo).delete(user);
            ArgumentCaptor<UserDeletedEvent> eventCaptor = ArgumentCaptor.forClass(UserDeletedEvent.class);
            verify(eventPublisher).publishEvent(eventCaptor.capture());
            assertThat(eventCaptor.getValue().userId()).isEqualTo(userId);
        }

        @Test
        @DisplayName("""
                GIVEN: User does not exist in database
                WHEN: deleteUser is called
                THEN: UserNotFoundException is thrown
                AND: repo delete and event publisher are not called
                """)
        void deleteUser_notFound() {
            UserId userId = new UserId(UUID.randomUUID());
            when(userRepo.findUserById(userId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> accountService.deleteUser(userId))
                    .isInstanceOf(UserNotFoundException.class)
                    .hasMessage("User " + userId + " not found.");

            verify(userRepo, never()).delete(any());
            verify(eventPublisher, never()).publishEvent(any());
        }
    }

    @Nested
    @DisplayName("getUserPublicKey")
    class GetUserPublicKeyTests {

        @Test
        @DisplayName("""
                GIVEN: User exists with a public key
                WHEN: getUserPublicKey is called with matching userId
                THEN: The public key is returned
                """)
        void getUserPublicKey_success() {
            UserId userId = new UserId(UUID.randomUUID());
            String expectedKey = "my-public-key";
            User user = User.builder()
                    .id(userId)
                    .publicKey(expectedKey)
                    .build();

            when(userRepo.findUserById(userId)).thenReturn(Optional.of(user));

            String publicKey = accountService.getUserPublicKey(userId);

            assertThat(publicKey).isEqualTo(expectedKey);
        }

        @Test
        @DisplayName("""
                GIVEN: User does not exist in database
                WHEN: getUserPublicKey is called
                THEN: UserNotFoundException is thrown
                """)
        void getUserPublicKey_notFound() {
            UserId userId = new UserId(UUID.randomUUID());
            when(userRepo.findUserById(userId)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> accountService.getUserPublicKey(userId))
                    .isInstanceOf(UserNotFoundException.class)
                    .hasMessage("User " + userId + " not found.");
        }
    }

    @Nested
    @DisplayName("usersExist")
    class UsersExistTests {

        @Test
        @DisplayName("""
                GIVEN: All requested user IDs exist in database
                WHEN: usersExist is called with set of user IDs
                THEN: No exception is thrown
                """)
        void usersExist_allExist() {
            UserId user1 = new UserId(UUID.randomUUID());
            UserId user2 = new UserId(UUID.randomUUID());
            Set<UserId> members = Set.of(user1, user2);

            when(userRepo.findUserById(user1)).thenReturn(Optional.of(User.builder().id(user1).build()));
            when(userRepo.findUserById(user2)).thenReturn(Optional.of(User.builder().id(user2).build()));

            assertThatCode(() -> accountService.usersExist(members))
                    .doesNotThrowAnyException();

            verify(userRepo).findUserById(user1);
            verify(userRepo).findUserById(user2);
        }

        @Test
        @DisplayName("""
                GIVEN: An empty set of user IDs
                WHEN: usersExist is called
                THEN: No exception is thrown and repository is not queried
                """)
        void usersExist_emptySet() {
            assertThatCode(() -> accountService.usersExist(Set.of()))
                    .doesNotThrowAnyException();

            verify(userRepo, never()).findUserById(any());
        }

        @Test
        @DisplayName("""
                GIVEN: At least one user ID does not exist in database
                WHEN: usersExist is called
                THEN: UserNotFoundException is thrown with expected error message
                """)
        void usersExist_userNotFound() {
            UserId missingUser = new UserId(UUID.randomUUID());
            Set<UserId> members = Set.of(missingUser);

            when(userRepo.findUserById(missingUser)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> accountService.usersExist(members))
                    .isInstanceOf(UserNotFoundException.class)
                    .hasMessage(missingUser.id() + " not Found!");
        }
    }
}
