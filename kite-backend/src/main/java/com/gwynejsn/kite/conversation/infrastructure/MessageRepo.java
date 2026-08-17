package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.Message;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MessageRepo extends MongoRepository<Message, UUID> {
    List<Message> findMessagesByConversationId(ConversationId conversationId);
}
