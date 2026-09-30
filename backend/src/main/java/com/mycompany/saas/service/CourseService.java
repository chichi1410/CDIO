package com.mycompany.saas.service;

import java.util.List;

import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.CourseStatus;
import com.mycompany.saas.domain.request.CourseCreateRequest;
import com.mycompany.saas.domain.request.CourseRejectRequest;
import com.mycompany.saas.domain.request.CourseUpdateRequest;
import com.mycompany.saas.domain.response.CourseDetailResponse;
import com.mycompany.saas.domain.response.CourseSummaryResponse;
import com.mycompany.saas.domain.response.PageResponse;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

public interface CourseService {

    // Public
    PageResponse<CourseSummaryResponse> searchCourses(
            String keyword,
            Long categoryId,
            CourseLevel level,
            String priceFilter,
            Pageable pageable
    );

    CourseDetailResponse getCourseBySlugOrId(String slugOrId);

    // Instructor
    List<CourseSummaryResponse> getMyCourses(String userEmail);

    CourseDetailResponse getCourseForEdit(Long id, String userEmail);

    CourseDetailResponse createCourse(CourseCreateRequest request, String userEmail);

    CourseDetailResponse updateCourse(Long id, CourseUpdateRequest request, String userEmail);

    CourseDetailResponse uploadThumbnail(Long id, MultipartFile file, String userEmail);

    CourseDetailResponse submitForApproval(Long id, String userEmail);

    void deleteCourse(Long id, String userEmail);

    // Admin
    PageResponse<CourseSummaryResponse> getAdminCourses(
            CourseStatus status,
            String keyword,
            Pageable pageable
    );

    CourseDetailResponse approveCourse(Long id);

    CourseDetailResponse rejectCourse(Long id, CourseRejectRequest request);

    CourseDetailResponse archiveCourse(Long id);
}
