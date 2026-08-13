package com.gwynejsn.kite.profile.api;

import com.gwynejsn.kite.shared.domain.UserId;

import java.util.List;

public interface UserProfileServiceApi {
    public UserProfileResponse getUserProfile(UserId userId);
    public List<UserProfileResponse> getUserProfiles(UserId currentId);
}
