package com.gwynejsn.kite.conversation.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.CompoundIndexDefinition;
import org.springframework.data.mongodb.core.index.Index;
import org.bson.Document;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-chat-conversations-and-messages-collections", author = "gwynejsn", transactional = false)
public class _0001__CreateConversationCollection {

    private static final String CONVERSATIONS_COLLECTION = "conversations";
    private static final String MESSAGES_COLLECTION = "messages";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(CONVERSATIONS_COLLECTION)
                .createIndex(new Index().on("memberIds", Direction.ASC)
                        .on("updatedAt", Direction.DESC)
                        .named("memberIds_1_updatedAt_-1"));

        Document messageCompoundKeys = new Document();
        messageCompoundKeys.put("conversationId", 1);
        messageCompoundKeys.put("createdAt", -1);

        mongoTemplate.indexOps(MESSAGES_COLLECTION)
                .createIndex(new CompoundIndexDefinition(messageCompoundKeys)
                        .named("conversationId_1_createdAt_-1"));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(CONVERSATIONS_COLLECTION).dropIndex("memberIds_1_updatedAt_-1");
        mongoTemplate.indexOps(MESSAGES_COLLECTION).dropIndex("conversationId_1_createdAt_-1");
    }
}