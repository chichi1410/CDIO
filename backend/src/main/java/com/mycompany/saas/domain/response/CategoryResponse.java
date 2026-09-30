package com.mycompany.saas.domain.response;

import com.mycompany.saas.domain.Category;

public record CategoryResponse(
        Long id,
        String name,
        String slug,
        String icon,
        String description,
        boolean active
) {
    public static CategoryResponse fromEntity(Category category) {
        if (category == null) return null;
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getSlug(),
                category.getIcon(),
                category.getDescription(),
                category.isActive()
        );
    }
}
