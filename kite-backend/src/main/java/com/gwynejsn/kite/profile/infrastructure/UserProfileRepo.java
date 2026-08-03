package com.gwynejsn.kite.profile.infrastructure;

import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserProfileRepo extends MongoRepository<UserProfile, UUID> {
    Optional<UserProfile> findUserProfileByUserId(UserId userId);
    void deleteUserProfileByUserId(UserId userId);
}
