package com.mycompany.saas.controller;

import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.response.CourseDetailResponse;
import com.mycompany.saas.domain.response.CourseSummaryResponse;
import com.mycompany.saas.domain.response.PageResponse;
import com.mycompany.saas.service.CourseService;
import com.mycompany.saas.util.annotation.ApiMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/courses")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;

    @GetMapping
    @ApiMessage("Lấy danh sách khóa học thành công")
    public ResponseEntity<PageResponse<CourseSummaryResponse>> searchCourses(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) CourseLevel level,
            @RequestParam(required = false) String priceFilter,
            @PageableDefault(size = 12, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ResponseEntity.ok(courseService.searchCourses(keyword, categoryId, level, priceFilter, pageable));
    }

    @GetMapping("/{slugOrId}")
    @ApiMessage("Lấy chi tiết khóa học thành công")
    public ResponseEntity<CourseDetailResponse> getCourseDetail(@PathVariable String slugOrId) {
        return ResponseEntity.ok(courseService.getCourseBySlugOrId(slugOrId));
    }
}
