package com.gwynejsn.kite.changes;

import com.gwynejsn.kite.shared.enums.Role;
import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.bson.Document;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.security.crypto.password.PasswordEncoder;


import java.util.List;
import java.util.UUID;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-collection", author = "gwynejsn")
public class _0001__CreateUserCollection {

    private static final String USERS_COLLECTION = "users"; // collection name
    private static final String ADMIN_EMAIL = "admin@kite.com";

    @Apply
    public void apply(MongoTemplate mongoTemplate, PasswordEncoder passwordEncoder) {
        Document adminDoc = new Document()
                .append("_id", UUID.randomUUID().toString())
                .append("email", ADMIN_EMAIL)
                .append("password", passwordEncoder.encode("password"))
                .append("roles", List.of(Role.ADMIN, Role.USER))
                .append("enabled", true);

        mongoTemplate.save(adminDoc, USERS_COLLECTION);
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.remove(Query.query(Criteria.where("email").is(ADMIN_EMAIL)), USERS_COLLECTION);
    }
}
