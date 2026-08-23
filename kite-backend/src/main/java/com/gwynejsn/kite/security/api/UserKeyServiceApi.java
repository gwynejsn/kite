package com.gwynejsn.kite.security.api;

import com.gwynejsn.kite.shared.domain.UserId;

import java.util.List;
import java.util.Map;
import java.util.Set;

public interface UserKeyServiceApi {
    /**
     * @param userIds
     * @return Map<userId, publicKey>
     */
    Map<String, String> getPublicKeysByUserIds(Set<UserId> userIds);
    String getPublicKeyByUserId(UserId userId);
}
