package com.gwynejsn.kite.security.infrastructure;

import com.gwynejsn.kite.security.domain.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepo extends MongoRepository<User, UUID> {
    Optional<User> findUserByEmail(String email);
}
