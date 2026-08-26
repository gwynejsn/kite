package com.gwynejsn.kite.media.application.dto;

import lombok.Builder;

import java.io.Serializable;

@Builder
public record PathResponse (String path) implements Serializable {
}
