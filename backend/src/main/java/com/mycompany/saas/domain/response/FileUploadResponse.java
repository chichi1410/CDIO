package com.mycompany.saas.domain.response;

public record FileUploadResponse(
        String publicId,
        String url,
        String format,
        String resourceType,
        long bytes,
        Double duration,
        String createdAt
) {
}
