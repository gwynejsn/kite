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
import java.util.List;
import java.util.Map;

@TargetSystem(id = "mongodb-kite")
@Change(id = "seed-demo-users", author = "gwynejsn", transactional = true)
public class _0003__SeedDemoUsers {

    private static final String USERS_COLLECTION = "users";
    // password
    private static final String BCRYPT_PASSWORD = "$2a$10$utLE8T6MuUho7c14zEtnL.w19nKGU9X5RvllDNjxcDCB8es.r.o/y";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        List<Map<String, Object>> users = List.of(
                createUserDoc("11111111-1111-1111-1111-111111111111", "john.doe@example.com"),
                createUserDoc("22222222-2222-2222-2222-222222222222", "jane.smith@example.com"),
                createUserDoc("33333333-3333-3333-3333-333333333333", "alex.morgan@example.com")
        );

        for (Map<String, Object> userDoc : users) {
            Query query = new Query(Criteria.where("email").is(userDoc.get("email")));
            if (!mongoTemplate.exists(query, USERS_COLLECTION)) {
                mongoTemplate.insert(userDoc, USERS_COLLECTION);
            }
        }
    }

    private Map<String, Object> createUserDoc(String id, String email) {
        Map<String, Object> user = new HashMap<>();
        user.put("_id", id);
        user.put("email", email);
        user.put("password", BCRYPT_PASSWORD);
        user.put("roles", List.of(Role.USER.toString()));
        user.put("enabled", true);
        user.put("_class", "com.gwynejsn.kite.security.domain.User");
        return user;
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        List<String> emails = List.of(
                "john.doe@example.com",
                "jane.smith@example.com",
                "alex.morgan@example.com"
        );
        Query query = new Query(Criteria.where("email").in(emails));
        mongoTemplate.remove(query, USERS_COLLECTION);
    }
}
