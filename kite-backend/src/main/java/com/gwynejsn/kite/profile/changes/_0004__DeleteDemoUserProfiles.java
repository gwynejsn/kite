package com.gwynejsn.kite.profile.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.List;

/**
 * We are deleting demo user profiles because we are implementing
 * E2EE which requires public/private key from the client
 * which we cannot do programmatically here.
 */
@TargetSystem(id = "mongodb-kite")
@Change(id = "delete-demo-users-profiles", author = "gwynejsn", transactional = true)
public class _0004__DeleteDemoUserProfiles {
    private static final String PROFILES_COLLECTION = "user_profiles";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        List<String> userIds = List.of(
                "11111111-1111-1111-1111-111111111111",
                "22222222-2222-2222-2222-222222222222",
                "33333333-3333-3333-3333-333333333333"
        );

        for (String userId : userIds) {
            Query query = new Query(Criteria.where("userId").is(userId));
            if (mongoTemplate.exists(query, PROFILES_COLLECTION)) {
                mongoTemplate.remove(query, PROFILES_COLLECTION);
            }
        }
    }
}

