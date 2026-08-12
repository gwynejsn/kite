package com.gwynejsn.kite.security.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.List;

/**
 * We are deleting demo users because we are implementing
 * E2EE which requires public/private key from the client
 * which we cannot do programmatically here.
 */
@TargetSystem(id = "mongodb-kite")
@Change(id = "delete-demo-users", author = "gwynejsn", transactional = true)
public class _0004__DeleteDemoUsers {
    private static final String USERS_COLLECTION = "users";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        List<String> userEmails = List.of(
                "john.doe@example.com",
                "jane.smith@example.com",
                "alex.morgan@example.com"
        );

        for (String userEmail : userEmails) {
            Query query = new Query(Criteria.where("email").is(userEmail));
            if (mongoTemplate.exists(query, USERS_COLLECTION)) {
                mongoTemplate.remove(query, USERS_COLLECTION);
            }
        }
    }
}
