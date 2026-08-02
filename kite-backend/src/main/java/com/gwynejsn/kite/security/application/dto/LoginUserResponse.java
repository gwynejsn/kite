package com.gwynejsn.kite.security.application.dto;

import lombok.Builder;
import org.springframework.http.HttpStatusCode;

@Builder
public record LoginUserResponse(String jwtToken, HttpStatusCode statusCode) { }
