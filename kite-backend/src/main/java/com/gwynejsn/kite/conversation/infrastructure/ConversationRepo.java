package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.shared.domain.UserId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConversationRepo extends MongoRepository<Conversation, UUID> {
    @Query("{ 'memberIds': { $all: [?0, ?1] }, 'type': 'DIRECT' }")
    Optional<Conversation> findByDirectMembers(UserId senderId, UserId recipientId);
    @Query("{ 'memberIds': ?0 }")
    Optional<List<Conversation>> findMyConversations(UserId senderId);

    Optional<Conversation> findConversationById(ConversationId id);
}
