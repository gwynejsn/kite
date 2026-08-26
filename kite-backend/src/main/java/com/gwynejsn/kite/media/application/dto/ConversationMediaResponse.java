package com.gwynejsn.kite.media.application.dto;

import lombok.Builder;

import java.util.List;

@Builder
public record ConversationMediaResponse(
        String conversationId,
        List<PathResponse> media
) { }
