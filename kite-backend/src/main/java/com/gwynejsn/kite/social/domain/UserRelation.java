package com.gwynejsn.kite.social.domain;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.social.domain.enums.RelationStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "user_relations")
public class UserRelation {

    @Id
    private RelationId id;
    private UserId requesterId;
    private UserId addresseeId;
    private RelationStatus status;
    private Instant createdAt;
    private Instant updatedAt;
}
