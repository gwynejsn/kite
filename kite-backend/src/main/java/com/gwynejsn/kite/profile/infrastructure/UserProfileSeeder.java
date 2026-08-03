package com.gwynejsn.kite.profile.infrastructure;

import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.profile.domain.UserProfileId;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.PreferredTheme;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@Order(2) // Run after UserSeeder
public class UserProfileSeeder implements CommandLineRunner {

    private final UserProfileRepo userProfileRepo;

    public UserProfileSeeder(UserProfileRepo userProfileRepo) {
        this.userProfileRepo = userProfileRepo;
    }

    @Override
    public void run(String... args) {
        if (userProfileRepo.count() == 0) {
            UserProfile adminProfile = UserProfile.builder()
                    .id(new UserProfileId(UUID.randomUUID()))
                    .userId(UserId.ADMIN_ID) // Link using the shared static admin ID
                    .firstName("System")
                    .lastName("Admin")
                    .username("admin")
                    .bio("System Administrator Account")
                    .gender(Gender.MALE)
                    .preferredTheme(PreferredTheme.DARK)
                    .build();
            userProfileRepo.save(adminProfile);
        }
    }
}
