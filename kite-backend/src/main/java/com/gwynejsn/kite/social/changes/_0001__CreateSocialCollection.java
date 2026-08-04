package com.gwynejsn.kite.social.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.bson.Document;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.CompoundIndexDefinition;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-relations-collection", author = "gwynejsn", transactional = false)
public class _0001__CreateSocialCollection {

    private static final String RELATIONS_COLLECTION = "user_relations";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Document compoundKeys = new Document();
        compoundKeys.put("requesterId", 1);
        compoundKeys.put("addresseeId", 1);

        mongoTemplate.indexOps(RELATIONS_COLLECTION)
                .createIndex(new CompoundIndexDefinition(compoundKeys)
                        .unique()
                        .named("requesterId_1_addresseeId_1"));

        Document statusKeys = new Document();
        statusKeys.put("addresseeId", 1);
        statusKeys.put("status", 1);

        mongoTemplate.indexOps(RELATIONS_COLLECTION)
                .createIndex(new CompoundIndexDefinition(statusKeys)
                        .named("addresseeId_1_status_1"));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(RELATIONS_COLLECTION).dropIndex("requesterId_1_addresseeId_1");
        mongoTemplate.indexOps(RELATIONS_COLLECTION).dropIndex("addresseeId_1_status_1");
    }
}
