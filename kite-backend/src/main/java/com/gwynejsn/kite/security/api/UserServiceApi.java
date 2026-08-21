package com.gwynejsn.kite.security.api;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.exceptions.UserNotFoundException;

import java.util.Set;

public interface UserServiceApi {
    void usersExist(Set<UserId> members) throws UserNotFoundException;
}
