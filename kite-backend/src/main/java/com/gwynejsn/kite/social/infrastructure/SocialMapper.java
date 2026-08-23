package com.gwynejsn.kite.social.infrastructure;

import com.gwynejsn.kite.shared.infrastructure.UserMapper;
import com.gwynejsn.kite.social.application.dto.UserRelationResponse;
import com.gwynejsn.kite.social.domain.RelationId;
import com.gwynejsn.kite.social.domain.UserRelation;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE, uses = {UserMapper.class})
public interface SocialMapper {
    SocialMapper INSTANCE = Mappers.getMapper(SocialMapper.class);

    UserRelationResponse toUserRelationResponse(UserRelation relation);

    default String map(RelationId relationId) {
        return relationId == null ? null : relationId.id().toString();
    }
}
