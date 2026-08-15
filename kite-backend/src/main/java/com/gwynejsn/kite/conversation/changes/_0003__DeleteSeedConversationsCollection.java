package com.gwynejsn.kite.conversation.changes;


import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.List;

/**
 * Since we transitioned to e2ee, we need to change the message payload as encrypted payload
 * therefore, remove these seeds that contains the old version
 */
@TargetSystem(id = "mongodb-kite")
@Change(id = "delete-seed-conversations-collection", author = "gwynejsn", transactional = true)
public class _0003__DeleteSeedConversationsCollection {

    private static final String CONVERSATIONS_COLLECTION = "conversations";
    private static final String MESSAGES_COLLECTION = "messages";

    private static final String DIRECT_CONVERSATION_ID = "c1111111-1111-1111-1111-111111111111";
    private static final String GROUP_CONVERSATION_ID = "c2222222-2222-2222-2222-222222222222";

    private static final String DIRECT_MSG_ID = "m1111111-1111-1111-1111-111111111111";
    private static final String GROUP_MSG_ID = "m2222222-2222-2222-2222-222222222222";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Query convQuery = new Query(Criteria.where("_id").in(List.of(DIRECT_CONVERSATION_ID, GROUP_CONVERSATION_ID)));
        mongoTemplate.remove(convQuery, CONVERSATIONS_COLLECTION);

        Query msgQuery = new Query(Criteria.where("_id").in(List.of(DIRECT_MSG_ID, GROUP_MSG_ID)));
        mongoTemplate.remove(msgQuery, MESSAGES_COLLECTION);
    }
}