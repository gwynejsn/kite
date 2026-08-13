package com.gwynejsn.kite.social.infrastructure;

import com.gwynejsn.kite.social.application.dto.UserRelationResponse;
import com.gwynejsn.kite.social.domain.UserRelation;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface SocialMapper {
    SocialMapper INSTANCE = Mappers.getMapper(SocialMapper.class);

    UserRelationResponse toUserRelationResponse(UserRelation relation);
}
