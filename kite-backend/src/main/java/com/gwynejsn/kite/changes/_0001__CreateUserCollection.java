package com.gwynejsn.kite.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.domain.Sort.Direction;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-collection", author = "gwynejsn", transactional = false)
public class _0001__CreateUserCollection {

    private static final String USERS_COLLECTION = "users";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(USERS_COLLECTION)
                .createIndex(new Index().on("email", Direction.ASC).unique());
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(USERS_COLLECTION).dropIndex("email_1");
    }
}
