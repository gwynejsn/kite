package com.gwynejsn.kite.security.application;

import com.gwynejsn.kite.security.api.UserKeyServiceApi;
import com.gwynejsn.kite.security.domain.User;
import com.gwynejsn.kite.security.infrastructure.UserRepo;
import com.gwynejsn.kite.shared.domain.UserId;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserKeyService implements UserKeyServiceApi {
    private final UserRepo userRepo;

    @Override
    public Map<String, String> getPublicKeysByUserIds(Set<UserId> userIds) {
        return userRepo.findAllById(userIds).stream()
                .filter(u -> u.getPublicKey() != null)
                .collect(Collectors.toMap(
                        u -> u.getId().id().toString(),
                        User::getPublicKey
                ));
    }

    @Override
    public String getPublicKeyByUserId(UserId userId) {
        return userRepo.findUserById(userId)
                .map(User::getPublicKey)
                .orElse(null);
    }
}
