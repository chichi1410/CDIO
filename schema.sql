-- =============================================================================
-- HỆ THỐNG QUẢN LÝ HỌC TRỰC TUYẾN (E-LEARNING / LMS SAAS PLATFORM)
-- DỰA TRÊN ĐẶC TẢ USE CASES TRONG usercase.md
-- Cơ sở dữ liệu: MySQL 8.0+ / MariaDB 10.5+
-- Bảng mã: utf8mb4 (Hỗ trợ tiếng Việt đầy đủ và Emoji)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `saas_new_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `saas_new_db`;

-- Vô hiệu hóa kiểm tra khóa ngoại tạm thời khi tạo / cấu trúc lại bảng
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa các bảng cũ nếu đã tồn tại để tránh xung đột
DROP TABLE IF EXISTS `email_logs`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `certificates`;
DROP TABLE IF EXISTS `live_room_participants`;
DROP TABLE IF EXISTS `live_rooms`;
DROP TABLE IF EXISTS `questions_and_answers`;
DROP TABLE IF EXISTS `video_notes`;
DROP TABLE IF EXISTS `lesson_progress`;
DROP TABLE IF EXISTS `enrollments`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `cart_items`;
DROP TABLE IF EXISTS `vouchers`;
DROP TABLE IF EXISTS `assignment_submissions`;
DROP TABLE IF EXISTS `assignments`;
DROP TABLE IF EXISTS `quiz_answers`;
DROP TABLE IF EXISTS `quiz_submissions`;
DROP TABLE IF EXISTS `question_options`;
DROP TABLE IF EXISTS `questions`;
DROP TABLE IF EXISTS `quizzes`;
DROP TABLE IF EXISTS `banners`;
DROP TABLE IF EXISTS `course_reviews`;
DROP TABLE IF EXISTS `lesson_resources`;
DROP TABLE IF EXISTS `lessons`;
DROP TABLE IF EXISTS `sections`;
DROP TABLE IF EXISTS `courses`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `password_resets`;
DROP TABLE IF EXISTS `user_tokens`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- PHÂN HỆ 1: XÁC THỰC, PHÂN QUYỀN & NGƯỜI DÙNG (AUTHENTICATION & USER MANAGEMENT)
-- Use Cases:
--   USR-001: Đăng ký tài khoản (Học viên / Giảng viên)
--   USR-002: Đăng nhập (JWT Token)
--   USR-003: Đăng xuất (Thu hồi token)
--   USR-004: Quên mật khẩu (OTP / Token qua Email)
--   USR-005: Cập nhật hồ sơ cá nhân
--   ADM-001: Quản trị danh sách người dùng & phân quyền Role
-- =============================================================================

CREATE TABLE `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(150) NOT NULL UNIQUE COMMENT 'Email đăng nhập duy nhất',
    `password` VARCHAR(255) NOT NULL COMMENT 'Mật khẩu đã băm bằng BCrypt',
    `name` VARCHAR(100) NOT NULL COMMENT 'Họ và tên hiển thị',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT 'Số điện thoại liên hệ',
    `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn ảnh đại diện',
    `bio` TEXT DEFAULT NULL COMMENT 'Tiểu sử / giới thiệu giảng viên',
    `role` VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER' COMMENT 'ROLE_USER (Học viên), ROLE_INSTRUCTOR (Giảng viên), ROLE_ADMIN (Quản trị)',
    `active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Trạng thái kích hoạt tài khoản',
    `email_verified` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã xác thực email hay chưa',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_users_email` (`email`),
    INDEX `idx_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng người dùng và phân quyền';

CREATE TABLE `user_tokens` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL COMMENT 'Khóa ngoại tới users',
    `token` VARCHAR(500) NOT NULL UNIQUE COMMENT 'Refresh Token hoặc Access Token',
    `token_type` ENUM('REFRESH_TOKEN', 'ACCESS_TOKEN') NOT NULL DEFAULT 'REFRESH_TOKEN',
    `revoked` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đánh dấu thu hồi khi logout USR-003',
    `expired_at` TIMESTAMP NOT NULL COMMENT 'Thời hạn hết hạn của token',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_user_tokens_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Quản lý phiên đăng nhập và thu hồi token';

CREATE TABLE `password_resets` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `otp_code` VARCHAR(10) NOT NULL COMMENT 'Mã OTP 6 số gửi qua email',
    `token` VARCHAR(255) DEFAULT NULL COMMENT 'Reset Token nếu dùng URL',
    `is_used` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Trạng thái đã sử dụng OTP',
    `expired_at` TIMESTAMP NOT NULL COMMENT 'Hạn sử dụng của OTP (thường 5-15 phút)',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_pw_reset_user` (`user_id`, `otp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lưu mã OTP quên mật khẩu USR-004';

-- =============================================================================
-- PHÂN HỆ 2: KHÓA HỌC, NỘI DUNG & TÀI NGUYÊN (COURSES, SECTIONS, LESSONS)
-- Use Cases:
--   CRS-001: Thêm khóa học mới (Giảng viên)
--   CRS-002: Tải lên video bài giảng (Giảng viên)
--   CRS-003: Lọc khóa học theo danh mục & tìm kiếm (Học viên)
--   CRS-004: Chấm điểm và bình luận / Review (Học viên)
--   CRS-005: Upload file PDF/Zip đính kèm bài giảng (Giảng viên)
--   ADM-003: Phê duyệt khóa học trước khi public (Admin)
--   ADM-004: Quản lý banner trang chủ (Admin)
-- =============================================================================

CREATE TABLE `categories` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT 'Tên danh mục (ví dụ: Lập trình, Ngoại ngữ...)',
    `slug` VARCHAR(120) NOT NULL UNIQUE COMMENT 'Slug thân thiện URL',
    `icon_url` VARCHAR(500) DEFAULT NULL,
    `description` TEXT DEFAULT NULL,
    `parent_id` BIGINT DEFAULT NULL COMMENT 'Hỗ trợ danh mục cha - con',
    `active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`parent_id`) REFERENCES `categories`(`id`) ON DELETE SET NULL,
    INDEX `idx_categories_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục khóa học';

CREATE TABLE `courses` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `instructor_id` BIGINT NOT NULL COMMENT 'Giảng viên tạo khóa học',
    `category_id` BIGINT NOT NULL COMMENT 'Danh mục thuộc về',
    `title` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề khóa học',
    `slug` VARCHAR(300) NOT NULL UNIQUE COMMENT 'Đường dẫn URL duy nhất',
    `sub_title` VARCHAR(500) DEFAULT NULL COMMENT 'Mô tả ngắn gọn',
    `description` LONGTEXT DEFAULT NULL COMMENT 'Nội dung chi tiết khóa học định dạng HTML/Markdown',
    `thumbnail_url` VARCHAR(500) DEFAULT NULL COMMENT 'Ảnh đại diện khóa học',
    `trailer_video_url` VARCHAR(500) DEFAULT NULL COMMENT 'Video xem thử / giới thiệu',
    `price` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Giá gốc (VND)',
    `discount_price` DECIMAL(12, 2) DEFAULT 0.00 COMMENT 'Giá khuyến mãi (nếu có)',
    `level` ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'ALL_LEVELS') NOT NULL DEFAULT 'ALL_LEVELS',
    `language` VARCHAR(50) NOT NULL DEFAULT 'Vietnamese',
    `status` ENUM('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'PUBLISHED', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT' COMMENT 'Quy trình duyệt ADM-003',
    `rejection_reason` TEXT DEFAULT NULL COMMENT 'Lý do từ chối phê duyệt từ Admin',
    `total_duration` INT NOT NULL DEFAULT 0 COMMENT 'Tổng thời lượng các video (giây)',
    `total_lessons` INT NOT NULL DEFAULT 0 COMMENT 'Tổng số bài học',
    `average_rating` DECIMAL(3, 2) NOT NULL DEFAULT 0.00 COMMENT 'Điểm đánh giá trung bình (1.00 - 5.00)',
    `total_reviews` INT NOT NULL DEFAULT 0 COMMENT 'Số lượt đánh giá',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`instructor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE RESTRICT,
    INDEX `idx_courses_status` (`status`),
    INDEX `idx_courses_category` (`category_id`),
    INDEX `idx_courses_instructor` (`instructor_id`),
    FULLTEXT KEY `ft_course_search` (`title`, `sub_title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin khóa học';

CREATE TABLE `sections` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `course_id` BIGINT NOT NULL,
    `title` VARCHAR(255) NOT NULL COMMENT 'Tên chương / phần học (ví dụ: Chương 1: Căn bản...)',
    `order_index` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự hiển thị',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    INDEX `idx_sections_course` (`course_id`, `order_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Các chương/phần của khóa học';

CREATE TABLE `lessons` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `section_id` BIGINT NOT NULL,
    `title` VARCHAR(255) NOT NULL COMMENT 'Tên bài học',
    `order_index` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự trong chương',
    `type` ENUM('VIDEO', 'ARTICLE', 'QUIZ', 'ASSIGNMENT') NOT NULL DEFAULT 'VIDEO' COMMENT 'Loại bài học',
    `video_url` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn video bài giảng (CRS-002, LRN-001)',
    `video_duration` INT NOT NULL DEFAULT 0 COMMENT 'Thời lượng video (giây)',
    `content` LONGTEXT DEFAULT NULL COMMENT 'Nội dung bài viết nếu là dạng ARTICLE',
    `is_free_preview` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Cho phép xem thử miễn phí không',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`section_id`) REFERENCES `sections`(`id`) ON DELETE CASCADE,
    INDEX `idx_lessons_section` (`section_id`, `order_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết các bài học';

CREATE TABLE `lesson_resources` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `lesson_id` BIGINT NOT NULL,
    `file_name` VARCHAR(255) NOT NULL COMMENT 'Tên tài liệu hiển thị',
    `file_url` VARCHAR(500) NOT NULL COMMENT 'Đường dẫn tải file PDF/Zip trên server (CRS-005)',
    `file_size` BIGINT DEFAULT NULL COMMENT 'Dung lượng file tính bằng bytes',
    `file_type` VARCHAR(50) DEFAULT NULL COMMENT 'Định dạng file: pdf, zip, docx, v.v.',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tài liệu học tập đính kèm bài giảng';

CREATE TABLE `course_reviews` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `course_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `rating` TINYINT NOT NULL COMMENT 'Chấm điểm 1 đến 5 sao',
    `comment` TEXT DEFAULT NULL COMMENT 'Bình luận nhận xét của học viên (CRS-004)',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_course_user_review` (`course_id`, `user_id`),
    CONSTRAINT `chk_rating_range` CHECK (`rating` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đánh giá và phản hồi khóa học';

CREATE TABLE `banners` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(200) DEFAULT NULL COMMENT 'Tiêu đề banner quảng cáo',
    `image_url` VARCHAR(500) NOT NULL COMMENT 'Ảnh banner',
    `target_url` VARCHAR(500) DEFAULT NULL COMMENT 'Đường link chuyển hướng khi click',
    `order_index` INT NOT NULL DEFAULT 1,
    `active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Bật/tắt hiển thị (ADM-004)',
    `start_date` TIMESTAMP NULL DEFAULT NULL,
    `end_date` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Banner quản trị trang chủ';

-- =============================================================================
-- PHÂN HỆ 3: NGÂN HÀNG CÂU HỎI, TRẮC NGHIỆM & BÀI TẬP TỰ LUẬN
-- Use Cases:
--   CRS-006: Thêm/sửa câu trắc nghiệm trong ngân hàng câu hỏi (Giảng viên)
--   CRS-007: Chấm điểm bài tự luận (Giảng viên)
--   LRN-002: Làm bài quiz cuối chương & tự động chấm điểm (Học viên)
-- =============================================================================

CREATE TABLE `quizzes` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `course_id` BIGINT NOT NULL,
    `lesson_id` BIGINT DEFAULT NULL COMMENT 'Liên kết bài học nếu quiz là một bài học',
    `title` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề bài trắc nghiệm',
    `description` TEXT DEFAULT NULL,
    `time_limit_minutes` INT NOT NULL DEFAULT 15 COMMENT 'Thời gian làm bài tính theo phút',
    `passing_score` INT NOT NULL DEFAULT 80 COMMENT 'Tỉ lệ phần trăm đạt điểm (vd: 80%)',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bài kiểm tra trắc nghiệm';

CREATE TABLE `questions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `quiz_id` BIGINT DEFAULT NULL COMMENT 'Quiz cụ thể hoặc trong ngân hàng câu hỏi',
    `instructor_id` BIGINT NOT NULL COMMENT 'Giảng viên sở hữu câu hỏi (CRS-006)',
    `content` TEXT NOT NULL COMMENT 'Nội dung câu hỏi',
    `explanation` TEXT DEFAULT NULL COMMENT 'Giải thích đáp án sau khi làm bài',
    `question_type` ENUM('SINGLE_CHOICE', 'MULTIPLE_CHOICE', 'TRUE_FALSE') NOT NULL DEFAULT 'SINGLE_CHOICE',
    `points` INT NOT NULL DEFAULT 1 COMMENT 'Điểm của câu hỏi',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`instructor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ngân hàng câu hỏi trắc nghiệm';

CREATE TABLE `question_options` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `question_id` BIGINT NOT NULL,
    `option_text` TEXT NOT NULL COMMENT 'Nội dung lựa chọn đáp án',
    `is_correct` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đáp án đúng',
    `order_index` INT NOT NULL DEFAULT 1,
    FOREIGN KEY (`question_id`) REFERENCES `questions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Các phương án trả lời câu trắc nghiệm';

CREATE TABLE `quiz_submissions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `quiz_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL COMMENT 'Học viên làm bài (LRN-002)',
    `score` DECIMAL(5, 2) NOT NULL COMMENT 'Điểm số đạt được (thang 100)',
    `total_questions` INT NOT NULL,
    `correct_answers` INT NOT NULL,
    `is_passed` BOOLEAN NOT NULL DEFAULT FALSE,
    `started_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`quiz_id`) REFERENCES `quizzes`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử nộp bài trắc nghiệm';

CREATE TABLE `quiz_answers` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `submission_id` BIGINT NOT NULL,
    `question_id` BIGINT NOT NULL,
    `selected_option_id` BIGINT DEFAULT NULL,
    `is_correct` BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (`submission_id`) REFERENCES `quiz_submissions`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`question_id`) REFERENCES `questions`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`selected_option_id`) REFERENCES `question_options`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết từng câu trả lời của học viên';

CREATE TABLE `assignments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `lesson_id` BIGINT NOT NULL,
    `title` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề bài tập tự luận (CRS-007)',
    `instruction` LONGTEXT NOT NULL COMMENT 'Đề bài / hướng dẫn thực hiện',
    `attachment_url` VARCHAR(500) DEFAULT NULL COMMENT 'Tài liệu hướng dẫn mẫu đính kèm',
    `due_date` TIMESTAMP NULL DEFAULT NULL COMMENT 'Hạn nộp bài',
    `max_score` INT NOT NULL DEFAULT 100,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bài tập tự luận';

CREATE TABLE `assignment_submissions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `assignment_id` BIGINT NOT NULL,
    `student_id` BIGINT NOT NULL COMMENT 'Học viên nộp bài',
    `submission_text` TEXT DEFAULT NULL COMMENT 'Nội dung bài viết nộp',
    `attachment_url` VARCHAR(500) DEFAULT NULL COMMENT 'File nộp bài (zip, code, pdf)',
    `status` ENUM('SUBMITTED', 'GRADED', 'REJECTED') NOT NULL DEFAULT 'SUBMITTED',
    `score` DECIMAL(5, 2) DEFAULT NULL COMMENT 'Điểm giảng viên chấm',
    `feedback` TEXT DEFAULT NULL COMMENT 'Nhận xét từ giảng viên (CRS-007)',
    `graded_by` BIGINT DEFAULT NULL COMMENT 'Giảng viên chấm bài',
    `submitted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `graded_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`assignment_id`) REFERENCES `assignments`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`graded_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bài làm tự luận của học viên';

-- =============================================================================
-- PHÂN HỆ 4: GIỎ HÀNG, THANH TOÁN, KHUYẾN MÃI & DOANH THU (PAYMENTS & ORDERS)
-- Use Cases:
--   PAY-001: Giỏ hàng - Thêm/Xóa khóa học (Học viên)
--   PAY-002: Checkout - Thanh toán qua VNPay (Học viên)
--   PAY-003: Xem lịch sử giao dịch (Học viên)
--   MKT-001: Tạo mã Voucher giảm giá (Admin / Giảng viên)
--   ADM-002: Báo cáo doanh thu & thống kê tháng (Admin)
-- =============================================================================

CREATE TABLE `vouchers` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã voucher (ví dụ: GIAM20, CHAOMUNG) MKT-001',
    `description` VARCHAR(255) DEFAULT NULL,
    `discount_type` ENUM('PERCENTAGE', 'FIXED_AMOUNT') NOT NULL DEFAULT 'PERCENTAGE',
    `discount_value` DECIMAL(12, 2) NOT NULL COMMENT 'Giá trị giảm (vd: 20% hoặc 50000 VND)',
    `min_order_amount` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Đơn hàng tối thiểu để áp dụng',
    `max_discount_amount` DECIMAL(12, 2) DEFAULT NULL COMMENT 'Giới hạn số tiền giảm tối đa',
    `usage_limit` INT NOT NULL DEFAULT 100 COMMENT 'Tổng số lần có thể sử dụng',
    `used_count` INT NOT NULL DEFAULT 0 COMMENT 'Số lần đã dùng',
    `start_date` TIMESTAMP NOT NULL,
    `end_date` TIMESTAMP NOT NULL,
    `active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_by` BIGINT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_vouchers_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Mã voucher khuyến mãi';

CREATE TABLE `cart_items` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL COMMENT 'Học viên (PAY-001)',
    `course_id` BIGINT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_user_cart_course` (`user_id`, `course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Giỏ hàng học viên';

CREATE TABLE `orders` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_code` VARCHAR(64) NOT NULL UNIQUE COMMENT 'Mã hóa đơn duy nhất (vd: ORD-20260925-1029)',
    `user_id` BIGINT NOT NULL COMMENT 'Người mua hàng',
    `voucher_id` BIGINT DEFAULT NULL COMMENT 'Mã giảm giá áp dụng nếu có',
    `total_original_amount` DECIMAL(12, 2) NOT NULL COMMENT 'Tổng tiền gốc ban đầu',
    `discount_amount` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Số tiền được giảm',
    `final_amount` DECIMAL(12, 2) NOT NULL COMMENT 'Số tiền thực tế phải thanh toán',
    `status` ENUM('PENDING', 'PAID', 'CANCELLED', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
    `payment_method` ENUM('VNPAY', 'MOMO', 'STRIPE', 'BANK_TRANSFER', 'FREE') NOT NULL DEFAULT 'VNPAY',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`voucher_id`) REFERENCES `vouchers`(`id`) ON DELETE SET NULL,
    INDEX `idx_orders_status` (`status`),
    INDEX `idx_orders_user` (`user_id`),
    INDEX `idx_orders_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn đặt hàng khóa học';

CREATE TABLE `order_items` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `course_id` BIGINT NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL COMMENT 'Giá tại thời điểm mua',
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết các khóa học trong đơn hàng';

CREATE TABLE `payments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `payment_gateway` VARCHAR(50) NOT NULL DEFAULT 'VNPAY' COMMENT 'Cổng thanh toán (PAY-002)',
    `transaction_code` VARCHAR(100) NOT NULL COMMENT 'Mã giao dịch gửi sang gateway (vnp_TxnRef)',
    `gateway_transaction_no` VARCHAR(100) DEFAULT NULL COMMENT 'Mã phản hồi từ ngân hàng/VNPay (vnp_TransactionNo)',
    `bank_code` VARCHAR(50) DEFAULT NULL COMMENT 'Ngân hàng giao dịch (NCB, VCB, v.v.)',
    `amount` DECIMAL(12, 2) NOT NULL,
    `currency` VARCHAR(10) NOT NULL DEFAULT 'VND',
    `status` ENUM('PENDING', 'SUCCESS', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `response_code` VARCHAR(50) DEFAULT NULL COMMENT 'Mã phản hồi kết quả giao dịch (00 = thành công)',
    `pay_date` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm thanh toán hoàn tất (PAY-003)',
    `raw_response` TEXT DEFAULT NULL COMMENT 'Dữ liệu webhook callback lưu vết',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
    INDEX `idx_payments_txn` (`transaction_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử chi tiết giao dịch cổng thanh toán';

CREATE TABLE `enrollments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL COMMENT 'Học viên sở hữu khóa học',
    `course_id` BIGINT NOT NULL,
    `order_id` BIGINT DEFAULT NULL COMMENT 'Hóa đơn kích hoạt sở hữu',
    `status` ENUM('ACTIVE', 'EXPIRED', 'REVOKED') NOT NULL DEFAULT 'ACTIVE',
    `progress_percent` DECIMAL(5, 2) NOT NULL DEFAULT 0.00 COMMENT 'Tiến độ học tổng thể (0.00% - 100.00%)',
    `enrolled_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm học xong 100%',
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE SET NULL,
    UNIQUE KEY `unique_user_course_enrollment` (`user_id`, `course_id`),
    INDEX `idx_enrollments_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh sách khóa học đã đăng ký học';

-- =============================================================================
-- PHÂN HỆ 5: HỖ TRỢ HỌC TẬP, PHÒNG LIVE, TIẾN ĐỘ, Q&A, CHỨNG CHỈ
-- Use Cases:
--   LRN-001: Trình phát video bài giảng & theo dõi tiến độ (Học viên)
--   LRN-003: Tạo phòng học ảo Live / Google Meet (Giảng viên)
--   LRN-004: Tham gia phòng học ảo (Học viên)
--   LRN-005: Cấp chứng chỉ tự động & xuất PDF (Hệ thống)
--   LRN-006: Ghi chú theo timestamp video (Học viên)
--   LRN-007: Hỏi đáp (Q&A) dưới bài giảng qua SignalR/WebSocket (Học viên/GV)
-- =============================================================================

CREATE TABLE `lesson_progress` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `lesson_id` BIGINT NOT NULL,
    `is_completed` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã hoàn thành bài học chưa (LRN-001)',
    `last_watch_second` INT NOT NULL DEFAULT 0 COMMENT 'Giây dừng lại cuối cùng trên video',
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_user_lesson_progress` (`user_id`, `lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tiến trình xem từng bài giảng';

CREATE TABLE `video_notes` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `lesson_id` BIGINT NOT NULL,
    `timestamp_seconds` INT NOT NULL COMMENT 'Vị trí giây trong video (LRN-006)',
    `content` TEXT NOT NULL COMMENT 'Nội dung ghi chú cá nhân',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
    INDEX `idx_video_notes_user_lesson` (`user_id`, `lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ghi chú bài giảng theo timestamp';

CREATE TABLE `questions_and_answers` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `lesson_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL COMMENT 'Người đặt câu hỏi hoặc trả lời (LRN-007)',
    `parent_id` BIGINT DEFAULT NULL COMMENT 'Khóa ngoại trả lời lồng nhau (Thread)',
    `content` TEXT NOT NULL COMMENT 'Nội dung câu hỏi/bình luận',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`lesson_id`) REFERENCES `lessons`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`parent_id`) REFERENCES `questions_and_answers`(`id`) ON DELETE CASCADE,
    INDEX `idx_qa_lesson` (`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hỏi đáp thảo luận dưới bài học';

CREATE TABLE `live_rooms` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `course_id` BIGINT NOT NULL,
    `instructor_id` BIGINT NOT NULL COMMENT 'Giảng viên tổ chức phòng học (LRN-003)',
    `title` VARCHAR(255) NOT NULL COMMENT 'Tên buổi học trực tuyến',
    `description` TEXT DEFAULT NULL,
    `meeting_link` VARCHAR(500) NOT NULL COMMENT 'Link phòng học Google Meet / Jitsi / Zoom',
    `meeting_password` VARCHAR(50) DEFAULT NULL,
    `start_time` TIMESTAMP NOT NULL COMMENT 'Thời gian bắt đầu',
    `end_time` TIMESTAMP NOT NULL COMMENT 'Thời gian kết thúc',
    `status` ENUM('SCHEDULED', 'LIVE', 'ENDED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`instructor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_live_rooms_status` (`status`, `start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Phòng học trực tuyến ảo';

CREATE TABLE `live_room_participants` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `room_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL COMMENT 'Học viên tham gia (LRN-004)',
    `joined_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `left_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`room_id`) REFERENCES `live_rooms`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nhật ký tham gia phòng học trực tuyến';

CREATE TABLE `certificates` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `certificate_code` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Mã chứng chỉ duy nhất tra cứu (vd: CERT-2026-JAVA01) LRN-005',
    `user_id` BIGINT NOT NULL,
    `course_id` BIGINT NOT NULL,
    `pdf_url` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn file PDF chứng chỉ đã sinh',
    `issue_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày cấp chứng chỉ',
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_user_course_cert` (`user_id`, `course_id`),
    INDEX `idx_cert_code` (`certificate_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chứng chỉ tốt nghiệp khóa học';

-- =============================================================================
-- PHÂN HỆ 6: THÔNG BÁO & NHẬT KÝ EMAIL HỆ THỐNG (NOTIFICATIONS & EMAILS)
-- Use Cases:
--   NOT-001: Gửi email nhắc lịch học / thanh toán (Hệ thống SMTP)
--   NOT-002: In-app Notification - Thông báo quả chuông (Hệ thống)
-- =============================================================================

CREATE TABLE `notifications` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL COMMENT 'Người nhận thông báo (NOT-002)',
    `title` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề thông báo',
    `message` TEXT NOT NULL COMMENT 'Nội dung thông báo',
    `type` VARCHAR(50) NOT NULL DEFAULT 'SYSTEM' COMMENT 'SYSTEM, PAYMENT, COURSE, LIVE_ROOM',
    `reference_url` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn liên kết khi nhấn vào thông báo',
    `is_read` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã đọc thông báo chưa',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_notifications_user` (`user_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông báo trong ứng dụng';

CREATE TABLE `email_logs` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `recipient_email` VARCHAR(150) NOT NULL COMMENT 'Email người nhận (NOT-001)',
    `subject` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề email',
    `template_name` VARCHAR(100) DEFAULT NULL COMMENT 'Tên mẫu email (vd: reminder_live, payment_success)',
    `status` ENUM('PENDING', 'SENT', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `error_message` TEXT DEFAULT NULL COMMENT 'Lỗi nếu gửi thất bại',
    `sent_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_email_logs_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nhật ký gửi email hệ thống';

-- =============================================================================
-- DỮ LIỆU KHỞI TẠO MẪU (SEED DATA)
-- Mật khẩu mặc định của tất cả tài khoản mẫu bên dưới là: 123456
-- (Đã băm BCrypt: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi)
-- =============================================================================

-- 1. Tài khoản mẫu: Admin, Giảng viên, Học viên
INSERT INTO `users` (`id`, `email`, `password`, `name`, `phone`, `role`, `active`, `email_verified`) VALUES
(1, 'admin@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Hệ Thống Quản Trị (Admin)', '0901234567', 'ROLE_ADMIN', TRUE, TRUE),
(2, 'giangvien@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Thầy Nguyễn Văn A (Giảng Viên)', '0912345678', 'ROLE_INSTRUCTOR', TRUE, TRUE),
(3, 'hocvien@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Trần Thị B (Học Viên)', '0987654321', 'ROLE_USER', TRUE, TRUE);

-- 2. Danh mục khóa học
INSERT INTO `categories` (`id`, `name`, `slug`, `icon_url`, `description`) VALUES
(1, 'Lập Trình Web Fullstack', 'lap-trinh-web-fullstack', 'https://cdn.iconscout.com/icon/free/png-256/react-1-282599.png', 'Các khóa học từ Frontend tới Backend hiện đại'),
(2, 'Trí Tuệ Nhân Tạo & Data', 'tri-tue-nhan-tao-data', 'https://cdn.iconscout.com/icon/free/png-256/python-3521655-2945099.png', 'Học Python, Machine Learning và xử lý dữ liệu lớn'),
(3, 'Thiết Kế UI/UX', 'thiet-ke-ui-ux', 'https://cdn.iconscout.com/icon/free/png-256/figma-3521426-2944870.png', 'Kỹ năng thiết kế giao diện và trải nghiệm người dùng');

-- 3. Khóa học mẫu
INSERT INTO `courses` (`id`, `instructor_id`, `category_id`, `title`, `slug`, `sub_title`, `description`, `thumbnail_url`, `price`, `discount_price`, `level`, `status`, `total_duration`, `total_lessons`, `average_rating`, `total_reviews`) VALUES
(1, 2, 1, 'Lập Trình Spring Boot 3 & Next.js 15 Fullstack Toàn Diện', 'lap-trinh-spring-boot-3-nextjs-15-fullstack', 'Xây dựng ứng dụng E-learning SaaS hoàn chỉnh từ con số 0', '<p>Khóa học thực chiến toàn diện giúp bạn làm chủ Spring Boot và Next.js hiện đại.</p>', 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600', 1200000.00, 799000.00, 'INTERMEDIATE', 'PUBLISHED', 36000, 15, 5.00, 1);

-- 4. Chương & Bài học
INSERT INTO `sections` (`id`, `course_id`, `title`, `order_index`) VALUES
(1, 1, 'Chương 1: Giới thiệu kiến trúc hệ thống và cài đặt môi trường', 1),
(2, 1, 'Chương 2: Thiết kế Database và RESTful API với Spring Boot', 2);

INSERT INTO `lessons` (`id`, `section_id`, `title`, `order_index`, `type`, `video_url`, `video_duration`, `is_free_preview`) VALUES
(1, 1, 'Bài 1: Tổng quan dự án E-learning SaaS', 1, 'VIDEO', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 600, TRUE),
(2, 1, 'Bài 2: Hướng dẫn cài đặt JDK 17, MySQL và Docker', 2, 'VIDEO', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 900, FALSE),
(3, 2, 'Bài 3: Xây dựng Entity JPA và Cấu hình Spring Security JWT', 1, 'VIDEO', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 1200, FALSE);

-- 5. Tài liệu đính kèm bài học (CRS-005)
INSERT INTO `lesson_resources` (`id`, `lesson_id`, `file_name`, `file_url`, `file_size`, `file_type`) VALUES
(1, 1, 'So-do-kien-truc-he-thong.pdf', 'https://storage.example.com/docs/kien-truc.pdf', 2048000, 'pdf'),
(2, 2, 'Source-code-starter-template.zip', 'https://storage.example.com/docs/starter.zip', 15400000, 'zip');

-- 6. Mã Voucher khuyến mãi (MKT-001)
INSERT INTO `vouchers` (`id`, `code`, `description`, `discount_type`, `discount_value`, `min_order_amount`, `max_discount_amount`, `usage_limit`, `used_count`, `start_date`, `end_date`, `active`, `created_by`) VALUES
(1, 'CHAOMUNG2026', 'Giảm 20% cho đơn hàng đầu tiên', 'PERCENTAGE', 20.00, 500000.00, 200000.00, 500, 1, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, 1),
(2, 'GIAM50K', 'Giảm trực tiếp 50.000 VND mọi khóa học', 'FIXED_AMOUNT', 50000.00, 100000.00, 50000.00, 1000, 0, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, 1);

-- 7. Banner trang chủ (ADM-004)
INSERT INTO `banners` (`id`, `title`, `image_url`, `target_url`, `order_index`, `active`) VALUES
(1, 'Đại tiệc Back to School - Giảm 50% Khóa học Fullstack', 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200', '/courses', 1, TRUE),
(2, 'Làm chủ Trí Tuệ Nhân Tạo cùng Chuyên Gia', 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=1200', '/category/tri-tue-nhan-tao-data', 2, TRUE);

-- 8. Bài trắc nghiệm & Ngân hàng câu hỏi mẫu (CRS-006, LRN-002)
INSERT INTO `quizzes` (`id`, `course_id`, `lesson_id`, `title`, `description`, `time_limit_minutes`, `passing_score`) VALUES
(1, 1, NULL, 'Bài kiểm tra trắc nghiệm cuối Chương 1', 'Kiểm tra kiến thức cơ bản về HTTP, REST và Spring Boot', 15, 80);

INSERT INTO `questions` (`id`, `quiz_id`, `instructor_id`, `content`, `explanation`, `question_type`, `points`) VALUES
(1, 1, 2, 'Phương thức HTTP nào sau đây thường được sử dụng để tạo mới một tài nguyên trong RESTful API?', 'POST là phương thức chuẩn dùng để tạo mới tài nguyên trên Server.', 'SINGLE_CHOICE', 1),
(2, 1, 2, 'Annotation nào trong Spring Boot đánh dấu một lớp là Controller trả về JSON?', '@RestController là sự kết hợp giữa @Controller và @ResponseBody.', 'SINGLE_CHOICE', 1);

INSERT INTO `question_options` (`id`, `question_id`, `option_text`, `is_correct`, `order_index`) VALUES
(1, 1, 'GET', FALSE, 1),
(2, 1, 'POST', TRUE, 2),
(3, 1, 'PUT', FALSE, 3),
(4, 1, 'DELETE', FALSE, 4),
(5, 2, '@Controller', FALSE, 1),
(6, 2, '@Service', FALSE, 2),
(7, 2, '@RestController', TRUE, 3),
(8, 2, '@Component', FALSE, 4);

-- 9. Đánh giá khóa học mẫu (CRS-004)
INSERT INTO `course_reviews` (`id`, `course_id`, `user_id`, `rating`, `comment`) VALUES
(1, 1, 3, 5, 'Khóa học rất hay, giảng viên giảng giải chi tiết, dễ hiểu và thực chiến cao!');

-- 10. Thông báo mẫu (NOT-002)
INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `reference_url`, `is_read`) VALUES
(1, 3, 'Chào mừng đến với hệ thống E-Learning!', 'Cảm ơn bạn đã tham gia nền tảng. Hãy bắt đầu hành trình học tập ngay hôm nay!', 'SYSTEM', '/courses', FALSE);
