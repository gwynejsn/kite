package com.gwynejsn.kite.profile.infrastructure;

import com.gwynejsn.kite.profile.application.dto.UpdateUserProfileRequest;
import com.gwynejsn.kite.profile.api.UserProfileResponse;
import com.gwynejsn.kite.profile.domain.UserProfile;
import com.gwynejsn.kite.shared.domain.UserId;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.factory.Mappers;

@Mapper(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface UserProfileMapper {
    UserProfileMapper INSTANCE = Mappers.getMapper(UserProfileMapper.class);

    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "id", ignore = true)
    void updateProfileFromDto(UpdateUserProfileRequest request, @MappingTarget UserProfile existingProfile);
    UserProfileResponse toUserProfileResponse(UserProfile userProfile);

    /**
     * refer to mapstruct docs: 3.3. Adding custom methods to mappers
     * @param userId
     * @return userId in string format
     */
    default String map(UserId userId) {
        return userId == null ? null : userId.id().toString();
    }
}
