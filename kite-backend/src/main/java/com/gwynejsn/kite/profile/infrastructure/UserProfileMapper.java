package com.gwynejsn.kite.profile.infrastructure;

import com.gwynejsn.kite.profile.application.dto.UpdateUserProfileRequest;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.shared.infrastructure.UserMapper;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE, uses = {UserMapper.class})
public interface UserProfileMapper {
    UserProfileMapper INSTANCE = Mappers.getMapper(UserProfileMapper.class);

    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "id", ignore = true)
    void updateProfileFromDto(UpdateUserProfileRequest request, @MappingTarget UserProfile existingProfile);
    UserProfileResponse toUserProfileResponse(UserProfile userProfile);
}
