package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest;

import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataMongoTest
class UserRepoTest {

    @Autowired
    private UserRepo userRepo;

    @BeforeEach
    void setUp() {
        userRepo.deleteAll();
    }

    @Test
    @DisplayName("Should save and find user by email")
    void findUserByEmail_success() {
        UserId userId = new UserId(UUID.randomUUID());
        User user = User.builder()
                .id(userId)
                .email("john.doe@example.com")
                .password("hashed-password")
                .publicKey("public-key")
                .roles(Set.of(Role.USER))
                .enabled(true)
                .build();

        userRepo.save(user);

        var found = userRepo.findUserByEmail("john.doe@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getId()).isEqualTo(userId);
        assertThat(found.get().getEmail()).isEqualTo("john.doe@example.com");
    }

    @Test
    @DisplayName("Should save and find user by id")
    void findUserById_success() {
        UserId userId = new UserId(UUID.randomUUID());
        User user = User.builder()
                .id(userId)
                .email("jane.doe@example.com")
                .password("hashed-password")
                .publicKey("public-key")
                .roles(Set.of(Role.USER))
                .enabled(true)
                .build();

        userRepo.save(user);

        var found = userRepo.findUserById(userId);

        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("jane.doe@example.com");
        assertThat(found.get().isEnabled()).isTrue();
    }

    @Test
    @DisplayName("Should return empty when user email does not exist")
    void findUserByEmail_notFound() {
        var found = userRepo.findUserByEmail("missing@example.com");

        assertThat(found).isEmpty();
    }
}
