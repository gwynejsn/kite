package com.gwynejsn.kite.shared.security;

import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.security.core.userdetails.UserDetails;

// Does not expose getUser and the builder methods we defined in our CustomUserDetails
public interface AuthenticatedUser extends UserDetails {
    UserId getUserId();
}
