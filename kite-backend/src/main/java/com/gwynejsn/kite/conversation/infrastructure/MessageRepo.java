package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.domain.Message;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.UUID;

public interface MessageRepo extends MongoRepository<Message, UUID> {
}
