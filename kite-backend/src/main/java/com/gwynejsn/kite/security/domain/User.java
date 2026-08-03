package com.gwynejsn.kite.security.domain;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.util.Assert;

import java.util.HashSet;
import java.util.Set;

@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Document(collection = "users")
public class User {

    @Id
    private UserId id;

    @Indexed(unique = true)
    private String email;

    private String password;

    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @Builder.Default
    private boolean enabled = true;

    public static User create(String email, String passwordHash) {
        Assert.hasText(email, "Email is required");
        Assert.hasText(passwordHash, "Password hash is required");

        User user = new User();
        user.id = new UserId();
        user.email = email.toLowerCase().trim();
        user.password = passwordHash;
        user.roles.add(Role.USER); // Default role
        return user;
    }

    public static User create(UserId id, String email, String passwordHash) {
        Assert.notNull(id, "UserId is required");
        Assert.hasText(email, "Email is required");
        Assert.hasText(passwordHash, "Password hash is required");

        User user = new User();
        user.id = id;
        user.email = email.toLowerCase().trim();
        user.password = passwordHash;
        user.roles.add(Role.USER); // Default role
        return user;
    }

    public void changePassword(String newPasswordHash) {
        Assert.hasText(newPasswordHash, "New password hash cannot be empty");
        this.password = newPasswordHash;
    }

    public void addRole(Role role) {
        Assert.notNull(role, "Role cannot be null");
        this.roles.add(role);
    }

    public void disableAccount() {
        this.enabled = false;
    }

    public void enableAccount() {
        this.enabled = true;
    }
}
