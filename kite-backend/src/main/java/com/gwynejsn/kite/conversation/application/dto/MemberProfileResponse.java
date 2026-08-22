package com.gwynejsn.kite.conversation.application.dto;

public record MemberProfileResponse(
        String id,
        String firstName,
        String lastName,
        String username,
        String profilePhoto
) { }
