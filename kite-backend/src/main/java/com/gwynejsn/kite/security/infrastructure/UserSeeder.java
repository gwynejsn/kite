package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@Order(1) // Run first to ensure User exists before profile runs
public class UserSeeder implements CommandLineRunner {

    private final UserRepo userRepo;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.admin.email:admin@kite.com}")
    private String adminEmail;

    @Value("${app.admin.password:password}")
    private String adminPassword;

    public UserSeeder(UserRepo userRepo, PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (userRepo.count() == 0) {
            String encodedPassword = passwordEncoder.encode(adminPassword);
            User admin = User.create(UserId.ADMIN_ID, adminEmail, encodedPassword);
            admin.addRole(Role.ADMIN);
            userRepo.save(admin);
        }
    }
}
