package com.mycompany.saas.repository;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.saas.domain.Course;
import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.CourseStatus;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

public final class CourseSpecification {

    private CourseSpecification() {
    }

    public static Specification<Course> filter(
            String keyword,
            Long categoryId,
            CourseLevel level,
            String priceFilter,
            CourseStatus status
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            if (categoryId != null) {
                predicates.add(cb.equal(root.get("category").get("id"), categoryId));
            }

            if (level != null && level != CourseLevel.TAT_CA) {
                predicates.add(cb.equal(root.get("level"), level));
            }

            if (keyword != null && !keyword.isBlank()) {
                String pattern = "%" + keyword.toLowerCase().trim() + "%";
                Predicate titleLike = cb.like(cb.lower(root.get("title")), pattern);
                Predicate subLike = cb.like(cb.lower(root.get("subtitle")), pattern);
                predicates.add(cb.or(titleLike, subLike));
            }

            if ("free".equalsIgnoreCase(priceFilter)) {
                predicates.add(cb.or(
                        cb.equal(root.get("originalPrice"), BigDecimal.ZERO),
                        cb.equal(root.get("salePrice"), BigDecimal.ZERO)
                ));
            } else if ("paid".equalsIgnoreCase(priceFilter)) {
                predicates.add(cb.and(
                        cb.greaterThan(root.get("originalPrice"), BigDecimal.ZERO),
                        cb.or(
                                cb.isNull(root.get("salePrice")),
                                cb.greaterThan(root.get("salePrice"), BigDecimal.ZERO)
                        )
                ));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
