package com.gwynejsn.kite.shared.infrastructure;

import com.gwynejsn.kite.shared.domain.UserId;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper
public interface UserMapper {
    static UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);

    // use default to specify our custom mapping

    default Set<UserId> stringUserToUserIdSet(List<String> users) {
        return users == null ? null : users.stream().map(id -> new UserId(id)).collect(Collectors.toSet());
    }

    /**
     * refer to mapstruct docs: 3.3. Adding custom methods to mappers
     * @param userId
     * @return userId in string format
     */
    default String map(UserId userId) {
        return userId == null ? null : userId.id().toString();
    }

    default UserId map(String id) {
        return id == null ? null : new UserId(id);
    }
}
