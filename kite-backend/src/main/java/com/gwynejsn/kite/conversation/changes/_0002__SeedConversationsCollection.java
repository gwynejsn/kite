package com.gwynejsn.kite.conversation.changes;

import com.gwynejsn.kite.conversation.domain.enums.ConversationType;
import com.gwynejsn.kite.conversation.domain.enums.MessageStatus;
import com.gwynejsn.kite.conversation.domain.enums.MessageType;
import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@TargetSystem(id = "mongodb-kite")
@Change(id = "seed-conversations-collection", author = "gwynejsn", transactional = true)
public class _0002__SeedConversationsCollection {

    private static final String CONVERSATIONS_COLLECTION = "conversations";
    private static final String MESSAGES_COLLECTION = "messages";

    private static final String ADMIN_ID = "42a98f1b-5e4c-473d-9d10-8b1b827e8a93";
    private static final String JOHN_ID = "11111111-1111-1111-1111-111111111111";
    private static final String JANE_ID = "22222222-2222-2222-2222-222222222222";
    private static final String ALEX_ID = "33333333-3333-3333-3333-333333333333";

    private static final String DIRECT_CONVERSATION_ID = "c1111111-1111-1111-1111-111111111111";
    private static final String GROUP_CONVERSATION_ID = "c2222222-2222-2222-2222-222222222222";

    private static final String DIRECT_MSG_ID = "m1111111-1111-1111-1111-111111111111";
    private static final String GROUP_MSG_ID = "m2222222-2222-2222-2222-222222222222";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Instant now = Instant.now();

        // 1. Direct Conversation (John & Jane)
        Query directQuery = new Query(Criteria.where("_id").is(DIRECT_CONVERSATION_ID));
        if (!mongoTemplate.exists(directQuery, CONVERSATIONS_COLLECTION)) {
            Map<String, Object> lastMsgDoc = new HashMap<>();
            lastMsgDoc.put("messageId", DIRECT_MSG_ID);
            lastMsgDoc.put("senderId", JOHN_ID);
            lastMsgDoc.put("content", "Hey Jane, how are you doing?");
            lastMsgDoc.put("messageType", MessageType.TEXT.toString());
            lastMsgDoc.put("timestamp", now);

            Map<String, Object> directConv = new HashMap<>();
            directConv.put("_id", DIRECT_CONVERSATION_ID);
            directConv.put("type", ConversationType.DIRECT.toString());
            directConv.put("memberIds", List.of(JOHN_ID, JANE_ID));
            directConv.put("adminIds", List.of());
            directConv.put("lastMessage", lastMsgDoc);
            directConv.put("createdAt", now);
            directConv.put("updatedAt", now);
            directConv.put("_class", "com.gwynejsn.kite.conversation.domain.Conversation");

            mongoTemplate.insert(directConv, CONVERSATIONS_COLLECTION);
        }

        // Direct Message Document
        Query directMsgQuery = new Query(Criteria.where("_id").is(DIRECT_MSG_ID));
        if (!mongoTemplate.exists(directMsgQuery, MESSAGES_COLLECTION)) {
            Map<String, Object> directMsg = new HashMap<>();
            directMsg.put("_id", DIRECT_MSG_ID);
            directMsg.put("conversationId", DIRECT_CONVERSATION_ID);
            directMsg.put("senderId", JOHN_ID);
            directMsg.put("content", "Hey Jane, how are you doing?");
            directMsg.put("messageType", MessageType.TEXT.toString());
            directMsg.put("status", MessageStatus.DELIVERED.toString());
            directMsg.put("createdAt", now);
            directMsg.put("updatedAt", now);
            directMsg.put("_class", "com.gwynejsn.kite.conversation.domain.Message");

            mongoTemplate.insert(directMsg, MESSAGES_COLLECTION);
        }

        // 2. Group Conversation (Kite Engineering Team)
        Query groupQuery = new Query(Criteria.where("_id").is(GROUP_CONVERSATION_ID));
        if (!mongoTemplate.exists(groupQuery, CONVERSATIONS_COLLECTION)) {
            Map<String, Object> lastMsgDoc = new HashMap<>();
            lastMsgDoc.put("messageId", GROUP_MSG_ID);
            lastMsgDoc.put("senderId", ADMIN_ID);
            lastMsgDoc.put("content", "Welcome everyone to the Kite Engineering team group!");
            lastMsgDoc.put("messageType", MessageType.TEXT.toString());
            lastMsgDoc.put("timestamp", now);

            Map<String, Object> groupConv = new HashMap<>();
            groupConv.put("_id", GROUP_CONVERSATION_ID);
            groupConv.put("type", ConversationType.GROUP.toString());
            groupConv.put("name", "Kite Engineering Team");
            groupConv.put("conversationPhoto", "https://api.dicebear.com/7.x/identicon/svg?seed=KiteEngineering");
            groupConv.put("memberIds", List.of(ADMIN_ID, JOHN_ID, JANE_ID, ALEX_ID));
            groupConv.put("adminIds", List.of(ADMIN_ID));
            groupConv.put("lastMessage", lastMsgDoc);
            groupConv.put("createdAt", now);
            groupConv.put("updatedAt", now);
            groupConv.put("_class", "com.gwynejsn.kite.conversation.domain.Conversation");

            mongoTemplate.insert(groupConv, CONVERSATIONS_COLLECTION);
        }

        // Group Message Document
        Query groupMsgQuery = new Query(Criteria.where("_id").is(GROUP_MSG_ID));
        if (!mongoTemplate.exists(groupMsgQuery, MESSAGES_COLLECTION)) {
            Map<String, Object> groupMsg = new HashMap<>();
            groupMsg.put("_id", GROUP_MSG_ID);
            groupMsg.put("conversationId", GROUP_CONVERSATION_ID);
            groupMsg.put("senderId", ADMIN_ID);
            groupMsg.put("content", "Welcome everyone to the Kite Engineering team group!");
            groupMsg.put("messageType", MessageType.TEXT.toString());
            groupMsg.put("status", MessageStatus.READ.toString());
            groupMsg.put("createdAt", now);
            groupMsg.put("updatedAt", now);
            groupMsg.put("_class", "com.gwynejsn.kite.conversation.domain.Message");

            mongoTemplate.insert(groupMsg, MESSAGES_COLLECTION);
        }
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        Query convQuery = new Query(Criteria.where("_id").in(List.of(DIRECT_CONVERSATION_ID, GROUP_CONVERSATION_ID)));
        mongoTemplate.remove(convQuery, CONVERSATIONS_COLLECTION);

        Query msgQuery = new Query(Criteria.where("_id").in(List.of(DIRECT_MSG_ID, GROUP_MSG_ID)));
        mongoTemplate.remove(msgQuery, MESSAGES_COLLECTION);
    }
}