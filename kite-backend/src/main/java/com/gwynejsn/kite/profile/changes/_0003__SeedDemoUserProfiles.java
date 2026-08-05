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
import java.util.List;
import java.util.Map;

@TargetSystem(id = "mongodb-kite")
@Change(id = "seed-demo-user-profiles", author = "gwynejsn", transactional = true)
public class _0003__SeedDemoUserProfiles {

    private static final String PROFILES_COLLECTION = "user_profiles";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        List<Map<String, Object>> profiles = List.of(
                createProfileDoc(
                        "11111111-1111-1111-1111-111111111112",
                        "11111111-1111-1111-1111-111111111111",
                        "John", "Doe", "johndoe",
                        "Software engineer passionate about building mobile and web apps.",
                        Gender.MALE
                ),
                createProfileDoc(
                        "22222222-2222-2222-2222-222222222223",
                        "22222222-2222-2222-2222-222222222222",
                        "Jane", "Smith", "janesmith",
                        "UI/UX designer crafting clean and intuitive user interfaces.",
                        Gender.FEMALE
                ),
                createProfileDoc(
                        "33333333-3333-3333-3333-333333333334",
                        "33333333-3333-3333-3333-333333333333",
                        "Alex", "Morgan", "alexmorgan",
                        "Product manager focused on scalable backend architectures.",
                        Gender.FEMALE
                )
        );

        for (Map<String, Object> profileDoc : profiles) {
            Query query = new Query(Criteria.where("userId").is(profileDoc.get("userId")));
            if (!mongoTemplate.exists(query, PROFILES_COLLECTION)) {
                mongoTemplate.insert(profileDoc, PROFILES_COLLECTION);
            }
        }
    }

    private Map<String, Object> createProfileDoc(
            String id,
            String userId,
            String firstName,
            String lastName,
            String username,
            String bio,
            Gender gender
    ) {
        Map<String, Object> profile = new HashMap<>();
        profile.put("_id", id);
        profile.put("userId", userId);
        profile.put("firstName", firstName);
        profile.put("lastName", lastName);
        profile.put("username", username);
        profile.put("bio", bio);
        profile.put("gender", gender.toString());
        profile.put("preferredTheme", PreferredTheme.DARK.toString());
        profile.put("_class", "com.gwynejsn.kite.profile.domain.UserProfile");
        return profile;
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        List<String> userIds = List.of(
                "11111111-1111-1111-1111-111111111111",
                "22222222-2222-2222-2222-222222222222",
                "33333333-3333-3333-3333-333333333333"
        );
        Query query = new Query(Criteria.where("userId").in(userIds));
        mongoTemplate.remove(query, PROFILES_COLLECTION);
    }
}
