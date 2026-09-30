package com.mycompany.saas.service.impl;

import java.math.BigDecimal;
import java.util.List;

import com.mycompany.saas.domain.Category;
import com.mycompany.saas.domain.Course;
import com.mycompany.saas.domain.CourseLevel;
import com.mycompany.saas.domain.CourseStatus;
import com.mycompany.saas.domain.Role;
import com.mycompany.saas.domain.User;
import com.mycompany.saas.domain.request.CourseCreateRequest;
import com.mycompany.saas.domain.request.CourseRejectRequest;
import com.mycompany.saas.domain.request.CourseUpdateRequest;
import com.mycompany.saas.domain.response.CourseDetailResponse;
import com.mycompany.saas.domain.response.CourseSummaryResponse;
import com.mycompany.saas.domain.response.FileUploadResponse;
import com.mycompany.saas.domain.response.PageResponse;
import com.mycompany.saas.repository.CategoryRepository;
import com.mycompany.saas.repository.CourseRepository;
import com.mycompany.saas.repository.CourseSpecification;
import com.mycompany.saas.repository.UserRepository;
import com.mycompany.saas.service.CloudinaryService;
import com.mycompany.saas.service.CourseService;
import com.mycompany.saas.util.SlugUtils;
import com.mycompany.saas.util.error.BadRequestException;
import com.mycompany.saas.util.error.ForbiddenException;
import com.mycompany.saas.util.error.NotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class CourseServiceImpl implements CourseService {

    private final CourseRepository courseRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;

    // =========================================================================
    // PUBLIC APIS
    // =========================================================================

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CourseSummaryResponse> searchCourses(
            String keyword,
            Long categoryId,
            CourseLevel level,
            String priceFilter,
            Pageable pageable
    ) {
        Specification<Course> spec = CourseSpecification.filter(
                keyword,
                categoryId,
                level,
                priceFilter,
                CourseStatus.DA_XUAT_BAN
        );

        Page<CourseSummaryResponse> page = courseRepository.findAll(spec, pageable)
                .map(CourseSummaryResponse::fromEntity);

        return PageResponse.fromPage(page);
    }

    @Override
    @Transactional(readOnly = true)
    public CourseDetailResponse getCourseBySlugOrId(String slugOrId) {
        Course course;
        try {
            Long id = Long.parseLong(slugOrId);
            course = courseRepository.findDetailById(id)
                    .orElseGet(() -> courseRepository.findDetailBySlug(slugOrId)
                            .orElseThrow(() -> new NotFoundException("Không tìm thấy khóa học: " + slugOrId)));
        } catch (NumberFormatException e) {
            course = courseRepository.findDetailBySlug(slugOrId)
                    .orElseThrow(() -> new NotFoundException("Không tìm thấy khóa học: " + slugOrId));
        }

        // Nếu khóa học chưa xuất bản thì chỉ cho phép nội bộ xem
        if (course.getStatus() != CourseStatus.DA_XUAT_BAN && course.getStatus() != CourseStatus.DA_PHE_DUYET) {
            // Cho phép xem chi tiết nhưng có trạng thái tương ứng
            log.info("Viewing unpublished course: id={}, status={}", course.getId(), course.getStatus());
        }

        return CourseDetailResponse.fromEntity(course);
    }

    // =========================================================================
    // INSTRUCTOR APIS
    // =========================================================================

    @Override
    @Transactional(readOnly = true)
    public List<CourseSummaryResponse> getMyCourses(String userEmail) {
        User instructor = getUserByEmail(userEmail);
        return courseRepository.findByInstructorIdOrderByCreatedAtDesc(instructor.getId())
                .stream()
                .map(CourseSummaryResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CourseDetailResponse getCourseForEdit(Long id, String userEmail) {
        User user = getUserByEmail(userEmail);
        Course course = getCourseById(id);
        validateOwnershipOrAdmin(course, user);
        return CourseDetailResponse.fromEntity(course);
    }

    @Override
    public CourseDetailResponse createCourse(CourseCreateRequest request, String userEmail) {
        User instructor = getUserByEmail(userEmail);
        validateInstructorRole(instructor);
        validatePrices(request.getOriginalPrice(), request.getSalePrice());

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new NotFoundException("Không tìm thấy danh mục với ID: " + request.getCategoryId()));

        String slug = generateUniqueSlug(request.getTitle(), null);

        Course course = new Course();
        course.setInstructor(instructor);
        course.setCategory(category);
        course.setTitle(request.getTitle().trim());
        course.setSlug(slug);
        course.setSubtitle(request.getSubtitle());
        course.setDescription(request.getDescription());
        course.setThumbnailUrl(request.getThumbnailUrl());
        course.setIntroVideoUrl(request.getIntroVideoUrl());
        course.setOriginalPrice(request.getOriginalPrice());
        course.setSalePrice(request.getSalePrice() != null ? request.getSalePrice() : BigDecimal.ZERO);
        course.setLevel(request.getLevel() != null ? request.getLevel() : CourseLevel.TAT_CA);
        course.setLanguage(request.getLanguage() != null && !request.getLanguage().isBlank() ? request.getLanguage() : "Tiếng Việt");
        course.setStatus(CourseStatus.BAN_NHAP);

        Course saved = courseRepository.save(course);
        log.info("Course created: id={}, title='{}', by={}", saved.getId(), saved.getTitle(), userEmail);
        return CourseDetailResponse.fromEntity(saved);
    }

    @Override
    public CourseDetailResponse updateCourse(Long id, CourseUpdateRequest request, String userEmail) {
        User user = getUserByEmail(userEmail);
        Course course = getCourseById(id);
        validateOwnershipOrAdmin(course, user);

        // Không cho phép sửa nếu đang trong hàng đợi phê duyệt
        if (course.getStatus() == CourseStatus.CHO_PHE_DUYET && user.getRole() != Role.ROLE_ADMIN) {
            throw new BadRequestException("Khóa học đang chờ Admin phê duyệt, không thể chỉnh sửa lúc này.");
        }

        validatePrices(request.getOriginalPrice(), request.getSalePrice());

        if (request.getCategoryId() != null && !request.getCategoryId().equals(course.getCategory().getId())) {
            Category category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new NotFoundException("Không tìm thấy danh mục với ID: " + request.getCategoryId()));
            course.setCategory(category);
        }

        // Cập nhật slug nếu tiêu đề thay đổi
        if (!course.getTitle().equalsIgnoreCase(request.getTitle().trim())) {
            course.setSlug(generateUniqueSlug(request.getTitle(), course.getId()));
        }

        course.setTitle(request.getTitle().trim());
        course.setSubtitle(request.getSubtitle());
        course.setDescription(request.getDescription());
        if (request.getOriginalPrice() != null) course.setOriginalPrice(request.getOriginalPrice());
        if (request.getSalePrice() != null) course.setSalePrice(request.getSalePrice());
        if (request.getLevel() != null) course.setLevel(request.getLevel());
        if (request.getLanguage() != null && !request.getLanguage().isBlank()) course.setLanguage(request.getLanguage());
        if (request.getThumbnailUrl() != null) course.setThumbnailUrl(request.getThumbnailUrl());
        if (request.getIntroVideoUrl() != null) course.setIntroVideoUrl(request.getIntroVideoUrl());

        // Nếu đang ở trạng thái bị từ chối, sau khi sửa thì quay lại bản nháp
        if (course.getStatus() == CourseStatus.TU_CHOI) {
            course.setStatus(CourseStatus.BAN_NHAP);
            course.setRejectReason(null);
        }

        Course updated = courseRepository.save(course);
        log.info("Course updated: id={}, by={}", updated.getId(), userEmail);
        return CourseDetailResponse.fromEntity(updated);
    }

    @Override
    public CourseDetailResponse uploadThumbnail(Long id, MultipartFile file, String userEmail) {
        User user = getUserByEmail(userEmail);
        Course course = getCourseById(id);
        validateOwnershipOrAdmin(course, user);

        if (file == null || file.isEmpty()) {
            throw new BadRequestException("File ảnh tải lên không được để trống");
        }

        // Xóa ảnh cũ trên Cloudinary nếu có (async/best-effort)
        String oldThumbnail = course.getThumbnailUrl();
        if (oldThumbnail != null && oldThumbnail.contains("cloudinary.com")) {
            String oldPublicId = extractPublicId(oldThumbnail);
            if (oldPublicId != null) {
                try {
                    cloudinaryService.deleteFile(oldPublicId, "image");
                } catch (Exception e) {
                    log.warn("Could not delete old course thumbnail {}: {}", oldPublicId, e.getMessage());
                }
            }
        }

        FileUploadResponse uploadResponse = cloudinaryService.uploadImage(file, "saas/courses/thumbnails");
        course.setThumbnailUrl(uploadResponse.url());
        Course updated = courseRepository.save(course);
        log.info("Course thumbnail uploaded: id={}, url={}", updated.getId(), uploadResponse.url());
        return CourseDetailResponse.fromEntity(updated);
    }

    @Override
    public CourseDetailResponse submitForApproval(Long id, String userEmail) {
        User user = getUserByEmail(userEmail);
        Course course = getCourseById(id);
        validateOwnershipOrAdmin(course, user);

        if (course.getStatus() != CourseStatus.BAN_NHAP && course.getStatus() != CourseStatus.TU_CHOI) {
            throw new BadRequestException("Chỉ khóa học ở trạng thái Bản Nháp hoặc Bị Từ Chối mới có thể nộp duyệt.");
        }

        course.setStatus(CourseStatus.CHO_PHE_DUYET);
        course.setRejectReason(null);
        Course updated = courseRepository.save(course);
        log.info("Course submitted for approval: id={}, by={}", id, userEmail);
        return CourseDetailResponse.fromEntity(updated);
    }

    @Override
    public void deleteCourse(Long id, String userEmail) {
        User user = getUserByEmail(userEmail);
        Course course = getCourseById(id);
        validateOwnershipOrAdmin(course, user);

        // Giảng viên chỉ được xóa khi là bản nháp hoặc bị từ chối
        if (user.getRole() != Role.ROLE_ADMIN &&
                course.getStatus() != CourseStatus.BAN_NHAP &&
                course.getStatus() != CourseStatus.TU_CHOI) {
            throw new BadRequestException("Bạn chỉ có thể xóa khóa học khi ở trạng thái Bản Nháp hoặc Bị Từ Chối.");
        }

        courseRepository.delete(course);
        log.info("Course deleted: id={}, by={}", id, userEmail);
    }

    // =========================================================================
    // ADMIN APIS
    // =========================================================================

    @Override
    @Transactional(readOnly = true)
    public PageResponse<CourseSummaryResponse> getAdminCourses(
            CourseStatus status,
            String keyword,
            Pageable pageable
    ) {
        Specification<Course> spec = CourseSpecification.filter(
                keyword,
                null,
                null,
                null,
                status
        );

        Page<CourseSummaryResponse> page = courseRepository.findAll(spec, pageable)
                .map(CourseSummaryResponse::fromEntity);

        return PageResponse.fromPage(page);
    }

    @Override
    public CourseDetailResponse approveCourse(Long id) {
        Course course = getCourseById(id);
        course.setStatus(CourseStatus.DA_XUAT_BAN);
        course.setRejectReason(null);
        Course updated = courseRepository.save(course);
        log.info("Course approved: id={}", id);
        return CourseDetailResponse.fromEntity(updated);
    }

    @Override
    public CourseDetailResponse rejectCourse(Long id, CourseRejectRequest request) {
        Course course = getCourseById(id);
        course.setStatus(CourseStatus.TU_CHOI);
        course.setRejectReason(request.getReason());
        Course updated = courseRepository.save(course);
        log.info("Course rejected: id={}, reason='{}'", id, request.getReason());
        return CourseDetailResponse.fromEntity(updated);
    }

    @Override
    public CourseDetailResponse archiveCourse(Long id) {
        Course course = getCourseById(id);
        course.setStatus(CourseStatus.LUU_TRU);
        Course updated = courseRepository.save(course);
        log.info("Course archived: id={}", id);
        return CourseDetailResponse.fromEntity(updated);
    }

    // =========================================================================
    // HELPER METHODS
    // =========================================================================

    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy người dùng với email: " + email));
    }

    private Course getCourseById(Long id) {
        return courseRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy khóa học với ID: " + id));
    }

    private void validateOwnershipOrAdmin(Course course, User user) {
        if (user.getRole() == Role.ROLE_ADMIN) {
            return;
        }
        if (!course.getInstructor().getId().equals(user.getId())) {
            throw new ForbiddenException("Bạn không có quyền thao tác trên khóa học của giảng viên khác.");
        }
    }

    private void validateInstructorRole(User user) {
        if (user.getRole() != Role.ROLE_INSTRUCTOR && user.getRole() != Role.ROLE_ADMIN) {
            throw new ForbiddenException("Chỉ người dùng có vai trò Giảng Viên hoặc Quản Trị Viên mới có quyền tạo khóa học.");
        }
    }

    private void validatePrices(BigDecimal originalPrice, BigDecimal salePrice) {
        if (originalPrice != null && originalPrice.compareTo(BigDecimal.ZERO) < 0) {
            throw new BadRequestException("Giá gốc không được âm.");
        }
        if (salePrice != null && originalPrice != null) {
            if (salePrice.compareTo(BigDecimal.ZERO) < 0) {
                throw new BadRequestException("Giá khuyến mãi không được âm.");
            }
            if (salePrice.compareTo(originalPrice) > 0) {
                throw new BadRequestException("Giá khuyến mãi (" + salePrice + ") không được lớn hơn giá gốc (" + originalPrice + ").");
            }
        }
    }

    private String generateUniqueSlug(String title, Long existingCourseId) {
        String baseSlug = SlugUtils.toSlug(title);
        if (baseSlug.isBlank()) {
            baseSlug = "khoa-hoc-" + System.currentTimeMillis();
        }

        String candidateSlug = baseSlug;
        int counter = 1;

        while (true) {
            boolean exists = (existingCourseId == null)
                    ? courseRepository.existsBySlug(candidateSlug)
                    : courseRepository.existsBySlugAndIdNot(candidateSlug, existingCourseId);

            if (!exists) {
                return candidateSlug;
            }
            candidateSlug = baseSlug + "-" + counter++;
        }
    }

    private String extractPublicId(String url) {
        try {
            int uploadIndex = url.indexOf("/upload/");
            if (uploadIndex == -1) return null;
            String pathAfterUpload = url.substring(uploadIndex + 8);
            if (pathAfterUpload.startsWith("v") && pathAfterUpload.indexOf('/') != -1) {
                pathAfterUpload = pathAfterUpload.substring(pathAfterUpload.indexOf('/') + 1);
            }
            int lastDot = pathAfterUpload.lastIndexOf('.');
            return lastDot != -1 ? pathAfterUpload.substring(0, lastDot) : pathAfterUpload;
        } catch (Exception e) {
            return null;
        }
    }
}
