package com.gwynejsn.kite.profile.api;

import com.gwynejsn.kite.shared.domain.UserId;

public interface UserProfileServiceApi {
    public UserProfileResponse getUserProfile(UserId userId);
}
