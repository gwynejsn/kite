package com.gwynejsn.kite.profile.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.domain.Sort.Direction;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-profile-collection", author = "gwynejsn", transactional = false)
public class _0001__CreateUserProfileCollection {

    private static final String PROFILES_COLLECTION = "user_profiles";

    private static final String USER_ID_INDEX = "userId_1";
    private static final String USERNAME_INDEX = "username_1";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(PROFILES_COLLECTION)
                .createIndex(new Index().on("userId", Direction.ASC).unique().named(USER_ID_INDEX));
        mongoTemplate.indexOps(PROFILES_COLLECTION)
                .createIndex(new Index().on("username", Direction.ASC).unique().named(USERNAME_INDEX));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(PROFILES_COLLECTION).dropIndex(USER_ID_INDEX);
        mongoTemplate.indexOps(PROFILES_COLLECTION).dropIndex(USERNAME_INDEX);
    }
}