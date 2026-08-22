package com.gwynejsn.kite.presence.infrastructure;

import com.gwynejsn.kite.presence.application.dto.UserPresenceResponse;
import com.gwynejsn.kite.presence.domain.PresenceId;
import com.gwynejsn.kite.presence.domain.UserPresence;
import com.gwynejsn.kite.shared.infrastructure.UserMapper;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE, uses = {UserMapper.class})
public interface UserPresenceMapper {
    static UserPresenceMapper INSTANCE = Mappers.getMapper(UserPresenceMapper.class);

    UserPresenceResponse toResponse(UserPresence userPresence);

    default String map(PresenceId presenceId) {
        return presenceId == null ? null : presenceId.id().toString();
    }
}
