package com.gwynejsn.kite.conversation.application.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;
import java.util.Map;

public record AddGroupMembersRequest(
        @NotEmpty List<String> memberIds,
        Map<String, String> groupKeyMap
) {
}
