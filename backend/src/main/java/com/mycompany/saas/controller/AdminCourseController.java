package com.mycompany.saas.controller;

import com.mycompany.saas.domain.CourseStatus;
import com.mycompany.saas.domain.request.CourseRejectRequest;
import com.mycompany.saas.domain.response.CourseDetailResponse;
import com.mycompany.saas.domain.response.CourseSummaryResponse;
import com.mycompany.saas.domain.response.PageResponse;
import com.mycompany.saas.service.CourseService;
import com.mycompany.saas.util.annotation.ApiMessage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/admin/courses")
@RequiredArgsConstructor
public class AdminCourseController {

    private final CourseService courseService;

    @GetMapping
    @ApiMessage("Lấy danh sách khóa học cho quản trị viên thành công")
    public ResponseEntity<PageResponse<CourseSummaryResponse>> getAdminCourses(
            @RequestParam(required = false) CourseStatus status,
            @RequestParam(required = false) String keyword,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ResponseEntity.ok(courseService.getAdminCourses(status, keyword, pageable));
    }

    @PatchMapping("/{id}/approve")
    @ApiMessage("Phê duyệt và xuất bản khóa học thành công")
    public ResponseEntity<CourseDetailResponse> approveCourse(@PathVariable Long id) {
        return ResponseEntity.ok(courseService.approveCourse(id));
    }

    @PatchMapping("/{id}/reject")
    @ApiMessage("Từ chối khóa học thành công")
    public ResponseEntity<CourseDetailResponse> rejectCourse(
            @PathVariable Long id,
            @Valid @RequestBody CourseRejectRequest request
    ) {
        return ResponseEntity.ok(courseService.rejectCourse(id, request));
    }

    @PatchMapping("/{id}/archive")
    @ApiMessage("Chuyển khóa học vào diện lưu trữ thành công")
    public ResponseEntity<CourseDetailResponse> archiveCourse(@PathVariable Long id) {
        return ResponseEntity.ok(courseService.archiveCourse(id));
    }
}
