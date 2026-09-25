package com.mycompany.saas.domain.response;

import java.time.Instant;
import java.util.Map;

public record ApiErrorResponse(
    int status,
    String message,
    Map<String, String> errors,
    Instant timestamp
) {
    public ApiErrorResponse {
        errors = errors != null ? Map.copyOf(errors) : Map.of();
    }

    public static ApiErrorResponse of(int status, String message) {
        return new ApiErrorResponse(status, message, Map.of(), Instant.now());
    }

    public static ApiErrorResponse of(int status, String message, Map<String, String> errors) {
        return new ApiErrorResponse(status, message, errors, Instant.now());
    }
}
