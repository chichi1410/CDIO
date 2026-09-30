package com.mycompany.saas.domain.response;

import java.math.BigDecimal;
import java.time.Instant;

import com.mycompany.saas.domain.Course;
import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.CourseStatus;

public record CourseDetailResponse(
        Long id,
        String title,
        String slug,
        String subtitle,
        String description,
        String thumbnailUrl,
        String introVideoUrl,
        BigDecimal originalPrice,
        BigDecimal salePrice,
        CourseLevel level,
        String language,
        CourseStatus status,
        String rejectReason,
        Integer totalDurationSeconds,
        Integer totalLessons,
        Long categoryId,
        String categoryName,
        String categorySlug,
        Long instructorId,
        String instructorName,
        String instructorAvatarUrl,
        String instructorBio,
        Instant createdAt,
        Instant updatedAt
) {
    public static CourseDetailResponse fromEntity(Course course) {
        if (course == null) return null;
        return new CourseDetailResponse(
                course.getId(),
                course.getTitle(),
                course.getSlug(),
                course.getSubtitle(),
                course.getDescription(),
                course.getThumbnailUrl(),
                course.getIntroVideoUrl(),
                course.getOriginalPrice(),
                course.getSalePrice(),
                course.getLevel(),
                course.getLanguage(),
                course.getStatus(),
                course.getRejectReason(),
                course.getTotalDurationSeconds(),
                course.getTotalLessons(),
                course.getCategory() != null ? course.getCategory().getId() : null,
                course.getCategory() != null ? course.getCategory().getName() : null,
                course.getCategory() != null ? course.getCategory().getSlug() : null,
                course.getInstructor() != null ? course.getInstructor().getId() : null,
                course.getInstructor() != null ? course.getInstructor().getName() : null,
                course.getInstructor() != null ? course.getInstructor().getAvatarUrl() : null,
                course.getInstructor() != null ? course.getInstructor().getBio() : null,
                course.getCreatedAt(),
                course.getUpdatedAt()
        );
    }
}
