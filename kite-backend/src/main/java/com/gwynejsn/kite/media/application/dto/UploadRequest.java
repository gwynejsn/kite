package com.gwynejsn.kite.media.application.dto;

import com.gwynejsn.kite.media.domain.enums.MediaType;

public record UploadRequest(String fileName, MediaType mediaType, String uploaderId, String conversationId) {
}
