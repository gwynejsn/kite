package com.gwynejsn.kite.social.application.dto;

import com.gwynejsn.kite.social.domain.enums.RelationStatus;

import java.time.Instant;

public record UserRelationResponse(
        String id,
        String requesterId,
        String addresseeId,
        RelationStatus status,
        Instant createdAt,
        Instant updatedAt
) {
}
