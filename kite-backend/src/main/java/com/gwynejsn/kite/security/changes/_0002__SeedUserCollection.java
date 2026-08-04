package com.gwynejsn.kite.security.changes;

import com.gwynejsn.kite.shared.enums.Role;
import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.HashMap;
import java.util.Map;

@TargetSystem(id = "mongodb-kite")
@Change(id = "seed-user-collection", author = "gwynejsn", transactional = true)
public class _0002__SeedUserCollection {

    private static final String USERS_COLLECTION = "users";
    private static final String ADMIN_EMAIL = "admin@kite.com";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Query query = new Query(Criteria.where("email").is(ADMIN_EMAIL));
        if (!mongoTemplate.exists(query, USERS_COLLECTION)) {
            Map<String, Object> user = new HashMap<>();
            user.put("_id", "42a98f1b-5e4c-473d-9d10-8b1b827e8a93");
            user.put("email", ADMIN_EMAIL);
            user.put("password", "$2a$10$utLE8T6MuUho7c14zEtnL.w19nKGU9X5RvllDNjxcDCB8es.r.o/y");
            user.put("roles", java.util.List.of(Role.USER.toString(), Role.ADMIN.toString()));
            user.put("enabled", true);
            user.put("_class", "com.gwynejsn.kite.security.domain.User");

            mongoTemplate.insert(user, USERS_COLLECTION);
        }
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        Query query = new Query(Criteria.where("email").is(ADMIN_EMAIL));
        mongoTemplate.remove(query, USERS_COLLECTION);
    }
}
