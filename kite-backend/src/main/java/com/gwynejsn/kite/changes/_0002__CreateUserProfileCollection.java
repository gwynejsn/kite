package com.gwynejsn.kite.changes;

import com.gwynejsn.kite.shared.enums.Gender;
import com.gwynejsn.kite.shared.enums.PreferredTheme;
import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.bson.Document;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.util.UUID;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-user-profile-collection", author = "gwynejsn")
public class _0002__CreateUserProfileCollection {

    private static final String PROFILES_COLLECTION = "user_profiles";
    private static final String ADMIN_USERNAME = "admin";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        Document adminProfileDoc = new Document()
                .append("_id", UUID.randomUUID().toString())
                .append("firstName", "System")
                .append("lastName", "Admin")
                .append("username", ADMIN_USERNAME)
                .append("profileImageLink", null)
                .append("bio", "System Administrator Account")
                .append("gender", Gender.MALE.name())
                .append("preferredTheme", PreferredTheme.DARK.name());

        mongoTemplate.save(adminProfileDoc, PROFILES_COLLECTION);
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.remove(
                Query.query(Criteria.where("username").is(ADMIN_USERNAME)),
                PROFILES_COLLECTION
        );
    }
}