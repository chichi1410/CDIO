package com.mycompany.saas.domain.response;

import java.math.BigDecimal;
import java.time.Instant;

import com.mycompany.saas.domain.Course;
import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.CourseStatus;

public record CourseSummaryResponse(
        Long id,
        String title,
        String slug,
        String subtitle,
        String thumbnailUrl,
        BigDecimal originalPrice,
        BigDecimal salePrice,
        CourseLevel level,
        String language,
        CourseStatus status,
        Integer totalDurationSeconds,
        Integer totalLessons,
        Long categoryId,
        String categoryName,
        String categorySlug,
        Long instructorId,
        String instructorName,
        String instructorAvatarUrl,
        Instant createdAt
) {
    public static CourseSummaryResponse fromEntity(Course course) {
        if (course == null) return null;
        return new CourseSummaryResponse(
                course.getId(),
                course.getTitle(),
                course.getSlug(),
                course.getSubtitle(),
                course.getThumbnailUrl(),
                course.getOriginalPrice(),
                course.getSalePrice(),
                course.getLevel(),
                course.getLanguage(),
                course.getStatus(),
                course.getTotalDurationSeconds(),
                course.getTotalLessons(),
                course.getCategory() != null ? course.getCategory().getId() : null,
                course.getCategory() != null ? course.getCategory().getName() : null,
                course.getCategory() != null ? course.getCategory().getSlug() : null,
                course.getInstructor() != null ? course.getInstructor().getId() : null,
                course.getInstructor() != null ? course.getInstructor().getName() : null,
                course.getInstructor() != null ? course.getInstructor().getAvatarUrl() : null,
                course.getCreatedAt()
        );
    }
}
