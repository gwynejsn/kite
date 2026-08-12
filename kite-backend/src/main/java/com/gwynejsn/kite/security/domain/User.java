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

    private String publicKey;

    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @Builder.Default
    private boolean enabled = true;


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
