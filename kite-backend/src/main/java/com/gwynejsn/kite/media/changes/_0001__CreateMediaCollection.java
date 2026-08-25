package com.gwynejsn.kite.media.changes;

import io.flamingock.api.annotations.Apply;
import io.flamingock.api.annotations.Change;
import io.flamingock.api.annotations.Rollback;
import io.flamingock.api.annotations.TargetSystem;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;

@TargetSystem(id = "mongodb-kite")
@Change(id = "add-media-collection", author = "gwynejsn", transactional = false)
public class _0001__CreateMediaCollection {
    private static final String MEDIA_FS = "fs.files";

    private static final String UPLOADER_ID_INDEX = "metadata_uploaderId_1";
    private static final String CONVERSATION_ID_INDEX = "metadata_conversationId_1";

    @Apply
    public void apply(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(MEDIA_FS)
                .createIndex(new Index().on("metadata.uploaderId", Sort.Direction.ASC).named(UPLOADER_ID_INDEX));
        mongoTemplate.indexOps(MEDIA_FS)
                .createIndex(new Index().on("metadata.conversationId", Sort.Direction.ASC).named(CONVERSATION_ID_INDEX));
    }

    @Rollback
    public void rollback(MongoTemplate mongoTemplate) {
        mongoTemplate.indexOps(MEDIA_FS).dropIndex(UPLOADER_ID_INDEX);
        mongoTemplate.indexOps(MEDIA_FS).dropIndex(CONVERSATION_ID_INDEX);
    }
}
