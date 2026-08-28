package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import com.gwynejsn.kite.shared.config.MongoConfig;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.mongodb.test.autoconfigure.DataMongoTest;
import org.springframework.context.annotation.Import;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataMongoTest
@Import(MongoConfig.class)
class UserRepoTest {

    @Autowired
    private UserRepo userRepo;

    private final List<UserId> createdIds = new ArrayList<>();

    @BeforeEach
    void setUp() {
        createdIds.clear();
    }

    @AfterEach
    void tearDown() {
        if (!createdIds.isEmpty()) {
            userRepo.deleteAllById(createdIds);
        }
    }

    @Test
    @DisplayName("""
            GIVEN: User exists in database
            WHEN: findUserByEmail is called with matching email
            THEN: User is returned successfully
            AND: no exception is thrown
            """)
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
        createdIds.add(userId);

        var found = userRepo.findUserByEmail("john.doe@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getId()).isEqualTo(userId);
        assertThat(found.get().getEmail()).isEqualTo("john.doe@example.com");
    }

    @Test
    @DisplayName("""
            GIVEN: User exists in database
            WHEN: findUserById is called with matching userId
            THEN: User is returned successfully
            AND: no exception is thrown
            """)
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
        createdIds.add(userId);

        var found = userRepo.findUserById(userId);

        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("jane.doe@example.com");
        assertThat(found.get().isEnabled()).isTrue();
    }

    @Test
    @DisplayName("""
            GIVEN: User email does not exist in database
            WHEN: findUserByEmail is called
            THEN: Empty optional is returned
            AND: no exception is thrown
            """)
    void findUserByEmail_notFound() {
        var found = userRepo.findUserByEmail("missing@example.com");

        assertThat(found).isEmpty();
    }
}
