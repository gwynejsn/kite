package com.gwynejsn.kite.security.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-refresh-token-collection", author = "gwynejsn", transactional = false)
public class _0005__CreateRefreshTokenCollection {

    private static final String REFRESH_TOKEN_COLLECTION = "refresh_tokens";

    private static final String TOKEN_INDEX = "token_1";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(REFRESH_TOKEN_COLLECTION)
                .createIndex(new Index().on("token", Sort.Direction.ASC).unique().named(TOKEN_INDEX));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(REFRESH_TOKEN_COLLECTION).dropIndex(TOKEN_INDEX);
    }
}
