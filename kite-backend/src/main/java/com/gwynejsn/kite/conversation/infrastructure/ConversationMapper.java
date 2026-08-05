package com.gwynejsn.kite.conversation.infrastructure;

import com.gwynejsn.kite.conversation.domain.Conversation;
import com.gwynejsn.kite.conversation.domain.ConversationId;
import com.gwynejsn.kite.conversation.application.dto.ConversationResponse;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
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

}
