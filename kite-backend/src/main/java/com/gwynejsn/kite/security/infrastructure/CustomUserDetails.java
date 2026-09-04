package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.Set;

@Getter
@Builder
@AllArgsConstructor
public class CustomUserDetails implements AuthenticatedUser {

    private final UserId userId;
    private final String email;
    private final Set<Role> roles;
    @Builder.Default
    private final boolean enabled = true;
    private final String password;
    private final User user;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        Set<Role> activeRoles = roles != null ? roles : (user != null ? user.getRoles() : Set.of());
        return activeRoles.stream()
                .map(Role::toString)
                .map(role -> role.startsWith("ROLE_") ? role : "ROLE_" + role)
                .map(SimpleGrantedAuthority::new)
                .toList();
    }

    @Override
    public @Nullable String getPassword() {
        return password != null ? password : (user != null ? user.getPassword() : null);
    }

    @Override
    public String getUsername() {
        return email != null ? email : (user != null ? user.getEmail() : null);
    }

    @Override
    public boolean isEnabled() {
        return user != null ? user.isEnabled() : enabled;
    }

    @Override
    public UserId getUserId() {
        return userId != null ? userId : (user != null ? user.getId() : null);
    }
}
