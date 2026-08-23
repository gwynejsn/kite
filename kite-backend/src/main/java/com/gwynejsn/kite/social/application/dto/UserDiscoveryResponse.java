package com.gwynejsn.kite.social.application.dto;

import com.gwynejsn.kite.social.domain.enums.RelationStatus;

public record UserDiscoveryResponse(
        String userId,
        String firstName,
        String lastName,
        String username,
        String profileImageLink,
        String bio,
        RelationStatus relationStatus,
        Boolean isRequester,
        String relationId,
        String publicKey
) {
}
