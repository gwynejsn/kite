package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.shared.domain.ConversationId;
import com.gwynejsn.kite.conversation.domain.MessageId;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import com.gwynejsn.kite.shared.infrastructure.UserMapper;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE, uses = {UserMapper.class})
public interface ConversationMapper {
    ConversationMapper INSTANCE = Mappers.getMapper(ConversationMapper.class);

    ConversationResponse toConversationResponse(Conversation conversation);


    /**
     * refer to mapstruct docs: 3.3. Adding custom methods to mappers
     * @param conversationId
     * @return conversationId in string format
     */
    default String map(ConversationId conversationId) {
        return conversationId == null ? null : conversationId.id().toString();
    }

    default String map(MessageId messageId) {
        return messageId == null ? null : messageId.id().toString();
    }

}
