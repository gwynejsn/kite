package com.gwynejsn.kite.presence.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.bson.Document;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.CompoundIndexDefinition;
import org.springframework.data.mongodb.core.index.Index;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-presences-collection", author = "gwynejsn", transactional = false)
public class _0001__CreatePresenceCollection {

    private static final String PRESENCES_COLLECTION = "user_presences";

    private static final String USER_ID_INDEX = "userId_1";
    private static final String STATUS_LAST_SEEN_AT_INDEX = "status_1_lastSeenAt_-1";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(PRESENCES_COLLECTION)
                .createIndex(new Index().on("userId", Direction.ASC).unique().named(USER_ID_INDEX));

        Document statusKeys = new Document();
        statusKeys.put("status", 1);
        statusKeys.put("lastSeenAt", -1);

        mongoTemplate.indexOps(PRESENCES_COLLECTION)
                .createIndex(new CompoundIndexDefinition(statusKeys)
                        .named(STATUS_LAST_SEEN_AT_INDEX));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(PRESENCES_COLLECTION).dropIndex(USER_ID_INDEX);
        mongoTemplate.indexOps(PRESENCES_COLLECTION).dropIndex(STATUS_LAST_SEEN_AT_INDEX);
    }
}
