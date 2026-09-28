package com.mycompany.saas.domain.response;

import java.time.Instant;

import com.mycompany.saas.domain.Role;
import com.mycompany.saas.domain.User;

public record UserResponse(
        Long id,
        String name,
        String email,
        String avatarUrl,
        Role role,
        boolean active,
        Instant createdAt
) {
    public static UserResponse fromUser(User user) {
        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getAvatarUrl(),
                user.getRole(),
                user.isActive(),
                user.getCreatedAt()
        );
    }
}
