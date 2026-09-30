package com.mycompany.saas.repository;

import java.util.List;
import java.util.Optional;

import com.mycompany.saas.domain.Course;
import com.mycompany.saas.domain.CourseStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long>, JpaSpecificationExecutor<Course> {

    Optional<Course> findBySlug(String slug);

    Optional<Course> findBySlugAndStatus(String slug, CourseStatus status);

    Optional<Course> findByIdAndStatus(Long id, CourseStatus status);

    boolean existsBySlug(String slug);

    boolean existsBySlugAndIdNot(String slug, Long id);

    List<Course> findByInstructorIdOrderByCreatedAtDesc(Long instructorId);

    Page<Course> findByStatus(CourseStatus status, Pageable pageable);

    @Query("SELECT c FROM Course c JOIN FETCH c.category JOIN FETCH c.instructor WHERE c.id = :id")
    Optional<Course> findDetailById(@Param("id") Long id);

    @Query("SELECT c FROM Course c JOIN FETCH c.category JOIN FETCH c.instructor WHERE c.slug = :slug")
    Optional<Course> findDetailBySlug(@Param("slug") String slug);
}
