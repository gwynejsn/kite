package com.gwynejsn.kite.profile.changes;

import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.PreferredTheme;
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
@Change(id = "seed-user-profile-collection", author = "gwynejsn", transactional = true)
public class _0002__SeedUserProfileCollection {

    private static final String PROFILES_COLLECTION = "user_profiles";
    private static final String ADMIN_USER_ID = "42a98f1b-5e4c-473d-9d10-8b1b827e8a93";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Query query = new Query(Criteria.where("userId").is(ADMIN_USER_ID));
        if (!mongoTemplate.exists(query, PROFILES_COLLECTION)) {
            Map<String, Object> profile = new HashMap<>();
            profile.put("_id", "2134a4e0-45f6-4014-8f50-ba28dfa019fe");
            profile.put("userId", ADMIN_USER_ID);
            profile.put("firstName", "System");
            profile.put("lastName", "Admin");
            profile.put("username", "admin");
            profile.put("bio", "System Administrator Account");
            profile.put("gender", Gender.MALE.toString());
            profile.put("preferredTheme", PreferredTheme.DARK.toString());
            profile.put("_class", "com.gwynejsn.kite.profile.domain.UserProfile");

            mongoTemplate.insert(profile, PROFILES_COLLECTION);
        }
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        Query query = new Query(Criteria.where("userId").is(ADMIN_USER_ID));
        mongoTemplate.remove(query, PROFILES_COLLECTION);
    }
}
