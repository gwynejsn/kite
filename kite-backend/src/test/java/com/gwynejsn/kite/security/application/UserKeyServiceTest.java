package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserKeyServiceTest {

    @Mock
    private UserRepo userRepo;

    @InjectMocks
    private UserKeyService userKeyService;

    @Nested
    @DisplayName("getPublicKeysByUserIds")
    class GetPublicKeysByUserIdsTests {

        @Test
        @DisplayName("""
                GIVEN: A set of user IDs where some users have public keys and some have null keys
                WHEN: getPublicKeysByUserIds is called
                THEN: Only users with non-null public keys are returned in the map
                """)
        void getPublicKeysByUserIds_success() {
            UserId user1 = new UserId(UUID.randomUUID());
            UserId user2 = new UserId(UUID.randomUUID());
            UserId user3 = new UserId(UUID.randomUUID());

            User u1 = User.builder().id(user1).publicKey("key-1").build();
            User u2 = User.builder().id(user2).publicKey(null).build();
            User u3 = User.builder().id(user3).publicKey("key-3").build();

            Set<UserId> ids = Set.of(user1, user2, user3);
            when(userRepo.findAllById(ids)).thenReturn(List.of(u1, u2, u3));

            Map<String, String> result = userKeyService.getPublicKeysByUserIds(ids);

            assertThat(result)
                    .hasSize(2)
                    .containsEntry(user1.id().toString(), "key-1")
                    .containsEntry(user3.id().toString(), "key-3")
                    .doesNotContainKey(user2.id().toString());
        }

        @Test
        @DisplayName("""
                GIVEN: An empty set of user IDs
                WHEN: getPublicKeysByUserIds is called
                THEN: An empty map is returned
                """)
        void getPublicKeysByUserIds_empty() {
            when(userRepo.findAllById(Set.of())).thenReturn(List.of());

            Map<String, String> result = userKeyService.getPublicKeysByUserIds(Set.of());

            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getPublicKeyByUserId")
    class GetPublicKeyByUserIdTests {

        @Test
        @DisplayName("""
                GIVEN: User exists and has a public key
                WHEN: getPublicKeyByUserId is called
                THEN: The public key is returned
                """)
        void getPublicKeyByUserId_found() {
            UserId userId = new UserId(UUID.randomUUID());
            User user = User.builder().id(userId).publicKey("pub-key-xyz").build();

            when(userRepo.findUserById(userId)).thenReturn(Optional.of(user));

            String key = userKeyService.getPublicKeyByUserId(userId);

            assertThat(key).isEqualTo("pub-key-xyz");
        }

        @Test
        @DisplayName("""
                GIVEN: User does not exist in repository
                WHEN: getPublicKeyByUserId is called
                THEN: null is returned
                """)
        void getPublicKeyByUserId_notFound() {
            UserId userId = new UserId(UUID.randomUUID());

            when(userRepo.findUserById(userId)).thenReturn(Optional.empty());

            String key = userKeyService.getPublicKeyByUserId(userId);

            assertThat(key).isNull();
        }
    }
}
