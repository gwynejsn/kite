package com.gwynejsn.kite.notification.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.bson.Document;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.CompoundIndexDefinition;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-notifications-collection", author = "gwynejsn", transactional = false)
public class _0001__CreateNotificationCollection {

    private static final String NOTIFICATIONS_COLLECTION = "notifications";

    private static final String RECIPIENT_READ_CREATED_AT_INDEX = "recipientId_1_read_1_createdAt_-1";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Document compoundKeys = new Document();
        compoundKeys.put("recipientId", 1);
        compoundKeys.put("read", 1);
        compoundKeys.put("createdAt", -1);

        mongoTemplate.indexOps(NOTIFICATIONS_COLLECTION)
                .createIndex(new CompoundIndexDefinition(compoundKeys)
                        .named(RECIPIENT_READ_CREATED_AT_INDEX));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(NOTIFICATIONS_COLLECTION).dropIndex(RECIPIENT_READ_CREATED_AT_INDEX);
    }
}
