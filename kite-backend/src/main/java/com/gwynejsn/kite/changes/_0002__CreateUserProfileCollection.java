package com.gwynejsn.kite.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.domain.Sort.Direction;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-profile-collection", author = "gwynejsn", transactional = false)
public class _0002__CreateUserProfileCollection {

    private static final String PROFILES_COLLECTION = "user_profiles";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(PROFILES_COLLECTION)
                .createIndex(new Index().on("userId", Direction.ASC).unique());
        mongoTemplate.indexOps(PROFILES_COLLECTION)
                .createIndex(new Index().on("username", Direction.ASC).unique());
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(PROFILES_COLLECTION).dropIndex("userId_1");
        mongoTemplate.indexOps(PROFILES_COLLECTION).dropIndex("username_1");
    }
}