package com.mycompany.saas.domain.response;

public record TokenResponse(
        String accessToken,
        String tokenType,
        long expiresIn,
        UserResponse user
) {
}
