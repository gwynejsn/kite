package com.gwynejsn.kite.media.application.dto;

import lombok.Builder;

@Builder
public record UploadResponse(
        String path
) {
}
