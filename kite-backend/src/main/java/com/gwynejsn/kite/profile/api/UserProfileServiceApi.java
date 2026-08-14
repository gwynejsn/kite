package com.gwynejsn.kite.profile.api;

import com.gwynejsn.kite.shared.domain.UserId;

import java.util.List;

public interface UserProfileServiceApi {
    UserProfileResponse getUserProfile(UserId userId);
    List<UserProfileResponse> getUserProfiles(UserId currentId);
}
