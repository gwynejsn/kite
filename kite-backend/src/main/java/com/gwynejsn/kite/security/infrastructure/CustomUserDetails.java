package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.enums.Role;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.Builder;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.Set;

@Builder
public record CustomUserDetails(User user) implements AuthenticatedUser {
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        Set<Role> activeRoles = user.getRoles() != null ? user.getRoles() : (user != null ? user.getRoles() : Set.of());
        return activeRoles.stream()
                .map(Role::toString)
                .map(role -> role.startsWith("ROLE_") ? role : "ROLE_" + role)
                .map(SimpleGrantedAuthority::new)
                .toList();
    }

    @Override
    public @Nullable String getPassword() {
        return user.getPassword() != null ? user.getPassword() : (user != null ? user.getPassword() : null);
    }

    @Override
    public String getUsername() { // note email is the username here
        return user.getEmail() != null ? user.getEmail() : (user != null ? user.getEmail() : null);
    }

    @Override
    public boolean isEnabled() {
        return user != null ? user.isEnabled() : user.isEnabled();
    }

    @Override
    public UserId getUserId() {
        return user.getId() != null ? user.getId() : (user != null ? user.getId() : null);
    }
}
