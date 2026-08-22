package com.gwynejsn.kite.conversation.application.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record AddGroupMembersRequest(
        @NotEmpty List<String> memberIds
) {
}
