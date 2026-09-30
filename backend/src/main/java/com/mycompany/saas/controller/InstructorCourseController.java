package com.mycompany.saas.controller;

import java.util.List;

import com.mycompany.saas.domain.request.CourseCreateRequest;
import com.mycompany.saas.domain.request.CourseUpdateRequest;
import com.mycompany.saas.domain.response.CourseDetailResponse;
import com.mycompany.saas.domain.response.CourseSummaryResponse;
import com.mycompany.saas.service.CourseService;
import com.mycompany.saas.util.SecurityUtil;
import com.mycompany.saas.util.annotation.ApiMessage;
import com.mycompany.saas.util.error.ForbiddenException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/instructor/courses")
@RequiredArgsConstructor
public class InstructorCourseController {

    private final CourseService courseService;

    @GetMapping
    @ApiMessage("Lấy danh sách khóa học của giảng viên thành công")
    public ResponseEntity<List<CourseSummaryResponse>> getMyCourses() {
        String email = getCurrentUserEmail();
        return ResponseEntity.ok(courseService.getMyCourses(email));
    }

    @GetMapping("/{id}")
    @ApiMessage("Lấy thông tin khóa học để chỉnh sửa thành công")
    public ResponseEntity<CourseDetailResponse> getCourseForEdit(@PathVariable Long id) {
        String email = getCurrentUserEmail();
        return ResponseEntity.ok(courseService.getCourseForEdit(id, email));
    }

    @PostMapping
    @ApiMessage("Tạo khóa học mới thành công (Bản nháp)")
    public ResponseEntity<CourseDetailResponse> createCourse(@Valid @RequestBody CourseCreateRequest request) {
        String email = getCurrentUserEmail();
        return ResponseEntity.status(HttpStatus.CREATED).body(courseService.createCourse(request, email));
    }

    @PutMapping("/{id}")
    @ApiMessage("Cập nhật thông tin khóa học thành công")
    public ResponseEntity<CourseDetailResponse> updateCourse(
            @PathVariable Long id,
            @Valid @RequestBody CourseUpdateRequest request
    ) {
        String email = getCurrentUserEmail();
        return ResponseEntity.ok(courseService.updateCourse(id, request, email));
    }

    @PostMapping(value = "/{id}/thumbnail", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ApiMessage("Tải lên ảnh bìa khóa học thành công")
    public ResponseEntity<CourseDetailResponse> uploadThumbnail(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile file
    ) {
        String email = getCurrentUserEmail();
        return ResponseEntity.ok(courseService.uploadThumbnail(id, file, email));
    }

    @PatchMapping("/{id}/submit-approval")
    @ApiMessage("Gửi yêu cầu phê duyệt khóa học thành công")
    public ResponseEntity<CourseDetailResponse> submitForApproval(@PathVariable Long id) {
        String email = getCurrentUserEmail();
        return ResponseEntity.ok(courseService.submitForApproval(id, email));
    }

    @DeleteMapping("/{id}")
    @ApiMessage("Xóa khóa học thành công")
    public ResponseEntity<Void> deleteCourse(@PathVariable Long id) {
        String email = getCurrentUserEmail();
        courseService.deleteCourse(id, email);
        return ResponseEntity.noContent().build();
    }

    private String getCurrentUserEmail() {
        return SecurityUtil.getCurrentUserLogin()
                .orElseThrow(() -> new ForbiddenException("Yêu cầu xác thực tài khoản"));
    }
}
