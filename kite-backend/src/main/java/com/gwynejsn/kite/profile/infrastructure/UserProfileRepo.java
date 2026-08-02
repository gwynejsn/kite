package com.gwynejsn.kite.profile.infrastructure;

import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.UUID;

public interface UserProfileRepo extends MongoRepository<UserProfile, UUID> {
    UserProfile findUserProfileByUserId(UserId userId);
}
