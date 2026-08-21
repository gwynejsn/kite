package com.gwynejsn.kite.conversation.infrastructure;


import com.gwynejsn.kite.conversation.application.dto.MessageResponse;
import com.gwynejsn.kite.conversation.domain.Message;
import com.gwynejsn.kite.conversation.domain.MessageId;
import com.gwynejsn.kite.shared.infrastructure.UserMapper;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE, uses = {ConversationMapper.class, UserMapper.class})
public interface MessageMapper {
    MessageMapper INSTANCE = Mappers.getMapper(MessageMapper.class);

    MessageResponse toMessageResponse(Message message);

    // refer to mapstruct docs: 3.3. Adding custom methods to mappers
    default String map(MessageId messageId) {
        return messageId == null ? null : messageId.id().toString();
    }
}
