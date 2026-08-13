package com.gwynejsn.kite.social.application.dto;

import com.gwynejsn.kite.shared.domain.UserId;
import com.gwynejsn.kite.social.domain.RelationId;
import com.gwynejsn.kite.social.domain.enums.RelationStatus;

import java.time.Instant;

public record UserRelationResponse(
        RelationId id,
        UserId requesterId,
        UserId addresseeId,
        RelationStatus status,
        Instant createdAt,
        Instant updatedAt
) {
}
