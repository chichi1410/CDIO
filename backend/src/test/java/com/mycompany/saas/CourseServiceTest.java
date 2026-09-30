package com.mycompany.saas;

import java.math.BigDecimal;
import java.util.List;

import com.mycompany.saas.domain.Category;
import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.CourseStatus;
import com.mycompany.saas.domain.Role;
import com.mycompany.saas.domain.User;
import com.mycompany.saas.domain.request.CourseCreateRequest;
import com.mycompany.saas.domain.request.CourseRejectRequest;
import com.mycompany.saas.domain.request.CourseUpdateRequest;
import com.mycompany.saas.domain.response.CourseDetailResponse;
import com.mycompany.saas.domain.response.CourseSummaryResponse;
import com.mycompany.saas.domain.response.PageResponse;
import com.mycompany.saas.repository.CategoryRepository;
import com.mycompany.saas.repository.CourseRepository;
import com.mycompany.saas.repository.UserRepository;
import com.mycompany.saas.service.CourseService;
import com.mycompany.saas.util.error.BadRequestException;
import com.mycompany.saas.util.error.ForbiddenException;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class CourseServiceTest {

    @Autowired
    private CourseService courseService;

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private UserRepository userRepository;

    private User instructorA;
    private User instructorB;
    private Category testCategory;

    @BeforeEach
    void setUp() {
        instructorA = new User();
        instructorA.setEmail("instructorA@test.com");
        instructorA.setName("Thầy A");
        instructorA.setPassword("secret123");
        instructorA.setRole(Role.ROLE_INSTRUCTOR);
        instructorA = userRepository.save(instructorA);

        instructorB = new User();
        instructorB.setEmail("instructorB@test.com");
        instructorB.setName("Thầy B");
        instructorB.setPassword("secret123");
        instructorB.setRole(Role.ROLE_INSTRUCTOR);
        instructorB = userRepository.save(instructorB);

        testCategory = new Category();
        testCategory.setName("Tiếng Anh Giao Tiếp");
        testCategory.setSlug("tieng-anh-giao-tiep-" + System.currentTimeMillis());
        testCategory = categoryRepository.save(testCategory);
    }

    @Test
    void testCreateCourse_Success() {
        CourseCreateRequest request = new CourseCreateRequest();
        request.setTitle("Luyện Phản Xạ Tiếng Anh Cơ Bản");
        request.setSubtitle("Dành cho người mới bắt đầu");
        request.setCategoryId(testCategory.getId());
        request.setOriginalPrice(BigDecimal.valueOf(500000));
        request.setSalePrice(BigDecimal.valueOf(299000));
        request.setLevel(CourseLevel.CO_BAN);
        request.setLanguage("Tiếng Anh");

        CourseDetailResponse response = courseService.createCourse(request, instructorA.getEmail());

        Assertions.assertNotNull(response);
        Assertions.assertNotNull(response.id());
        Assertions.assertEquals(CourseStatus.BAN_NHAP, response.status());
        Assertions.assertEquals("luyen-phan-xa-tieng-anh-co-ban", response.slug());
        Assertions.assertEquals(instructorA.getId(), response.instructorId());
        Assertions.assertEquals(testCategory.getId(), response.categoryId());
    }

    @Test
    void testCreateCourse_InvalidSalePrice_ThrowsBadRequestException() {
        CourseCreateRequest request = new CourseCreateRequest();
        request.setTitle("Khóa học giá sai");
        request.setCategoryId(testCategory.getId());
        request.setOriginalPrice(BigDecimal.valueOf(200000));
        request.setSalePrice(BigDecimal.valueOf(300000)); // Giá sale cao hơn giá gốc!

        Assertions.assertThrows(BadRequestException.class, () ->
                courseService.createCourse(request, instructorA.getEmail()));
    }

    @Test
    void testUpdateCourse_IDOR_ThrowsForbiddenException() {
        // Instructor A tạo khóa học
        CourseCreateRequest createReq = new CourseCreateRequest();
        createReq.setTitle("Khóa học độc quyền của Thầy A");
        createReq.setCategoryId(testCategory.getId());
        createReq.setOriginalPrice(BigDecimal.valueOf(400000));
        CourseDetailResponse created = courseService.createCourse(createReq, instructorA.getEmail());

        // Instructor B cố tình chỉnh sửa khóa học của Thầy A
        CourseUpdateRequest updateReq = new CourseUpdateRequest();
        updateReq.setTitle("Thầy B hack khóa học");
        updateReq.setCategoryId(testCategory.getId());
        updateReq.setOriginalPrice(BigDecimal.valueOf(100000));

        Assertions.assertThrows(ForbiddenException.class, () ->
                courseService.updateCourse(created.id(), updateReq, instructorB.getEmail()));
    }

    @Test
    void testCourseLifecycle_SubmitApproveReject() {
        // 1. Tạo khóa học bản nháp
        CourseCreateRequest createReq = new CourseCreateRequest();
        createReq.setTitle("Khóa học kiểm duyệt vòng đời");
        createReq.setCategoryId(testCategory.getId());
        createReq.setOriginalPrice(BigDecimal.valueOf(350000));
        CourseDetailResponse created = courseService.createCourse(createReq, instructorA.getEmail());
        Assertions.assertEquals(CourseStatus.BAN_NHAP, created.status());

        // 2. Nộp duyệt
        CourseDetailResponse submitted = courseService.submitForApproval(created.id(), instructorA.getEmail());
        Assertions.assertEquals(CourseStatus.CHO_PHE_DUYET, submitted.status());

        // 3. Admin từ chối kèm lý do
        CourseRejectRequest rejectReq = new CourseRejectRequest();
        rejectReq.setReason("Nội dung video giới thiệu chưa rõ ràng, vui lòng bổ sung đề cương.");
        CourseDetailResponse rejected = courseService.rejectCourse(created.id(), rejectReq);
        Assertions.assertEquals(CourseStatus.TU_CHOI, rejected.status());
        Assertions.assertEquals(rejectReq.getReason(), rejected.rejectReason());

        // 4. Giảng viên sửa lại và nộp duyệt lần 2
        CourseUpdateRequest updateReq = new CourseUpdateRequest();
        updateReq.setTitle("Khóa học kiểm duyệt vòng đời đã bổ sung đề cương");
        updateReq.setCategoryId(testCategory.getId());
        updateReq.setOriginalPrice(BigDecimal.valueOf(350000));
        courseService.updateCourse(created.id(), updateReq, instructorA.getEmail());

        courseService.submitForApproval(created.id(), instructorA.getEmail());

        // 5. Admin duyệt xuất bản
        CourseDetailResponse approved = courseService.approveCourse(created.id());
        Assertions.assertEquals(CourseStatus.DA_XUAT_BAN, approved.status());
        Assertions.assertNull(approved.rejectReason());

        // 6. Kiểm tra khóa học xuất hiện trong kết quả tìm kiếm Public
        PageResponse<CourseSummaryResponse> searchResult = courseService.searchCourses(
                "vòng đời",
                testCategory.getId(),
                null,
                null,
                PageRequest.of(0, 10)
        );
        Assertions.assertTrue(searchResult.totalElements() >= 1);
    }
}
