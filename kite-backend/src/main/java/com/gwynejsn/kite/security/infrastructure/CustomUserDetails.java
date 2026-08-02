package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.shared.enums.Role;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.security.AuthenticatedUser;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;

@Getter
@Builder
@AllArgsConstructor
public class CustomUserDetails implements AuthenticatedUser {

    private final User user;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return user.getRoles().stream()
                .map(Role::toString)
                .map(SimpleGrantedAuthority::new)
                .toList();
    }

    @Override
    public @Nullable String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    @Override
    public boolean isEnabled() {
        return user.isEnabled();
    }

    @Override
    public UserId getUserId() {
        return user.getId();
    }
}
