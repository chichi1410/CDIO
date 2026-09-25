-- =============================================================================
-- HỆ THỐNG QUẢN LÝ HỌC TRỰC TUYẾN (E-LEARNING / LMS SAAS PLATFORM)
-- DỰA TRÊN ĐẶC TẢ USE CASES TRONG usercase.md
-- CÁC THỰC THỂ VÀ THUỘC TÍNH SỬ DỤNG TIẾNG VIỆT CHUẨN HÓA
-- Cơ sở dữ liệu: MySQL 8.0+ / MariaDB 10.5+
-- Bảng mã: utf8mb4 (Hỗ trợ tiếng Việt đầy đủ và Emoji)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `saas_new_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `saas_new_db`;

-- Vô hiệu hóa kiểm tra khóa ngoại tạm thời khi tạo / cấu trúc lại bảng
SET FOREIGN_KEY_CHECKS = 0;

-- Xóa các bảng tiếng Việt nếu đã tồn tại để tránh xung đột
DROP TABLE IF EXISTS `nhat_ky_email`;
DROP TABLE IF EXISTS `thong_bao`;
DROP TABLE IF EXISTS `chung_chi`;
DROP TABLE IF EXISTS `nguoi_tham_gia_phong_hoc`;
DROP TABLE IF EXISTS `phong_hoc_truc_tuyen`;
DROP TABLE IF EXISTS `cau_hoi_dap`;
DROP TABLE IF EXISTS `ghi_chu_video`;
DROP TABLE IF EXISTS `tien_do_bai_hoc`;
DROP TABLE IF EXISTS `dang_ky_khoa_hoc`;
DROP TABLE IF EXISTS `giao_dich_thanh_toan`;
DROP TABLE IF EXISTS `chi_tiet_don_hang`;
DROP TABLE IF EXISTS `don_hang`;
DROP TABLE IF EXISTS `gio_hang`;
DROP TABLE IF EXISTS `ma_giam_gia`;
DROP TABLE IF EXISTS `bai_nop_tu_luan`;
DROP TABLE IF EXISTS `bai_tap_tu_luan`;
DROP TABLE IF EXISTS `cau_tra_loi_trac_nghiem`;
DROP TABLE IF EXISTS `lan_lam_trac_nghiem`;
DROP TABLE IF EXISTS `lua_chon_dap_an`;
DROP TABLE IF EXISTS `cau_hoi`;
DROP TABLE IF EXISTS `bai_trac_nghiem`;
DROP TABLE IF EXISTS `banner`;
DROP TABLE IF EXISTS `danh_gia_khoa_hoc`;
DROP TABLE IF EXISTS `tai_lieu_bai_hoc`;
DROP TABLE IF EXISTS `bai_hoc`;
DROP TABLE IF EXISTS `chuong_hoc`;
DROP TABLE IF EXISTS `khoa_hoc`;
DROP TABLE IF EXISTS `danh_muc`;
DROP TABLE IF EXISTS `ma_xac_thuc_otp`;
DROP TABLE IF EXISTS `token_nguoi_dung`;
DROP TABLE IF EXISTS `nguoi_dung`;

-- Dọn dẹp các bảng tiếng Anh cũ (nếu có từ phiên bản trước)
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
--   USR-004: Quên mật khẩu (OTP qua Email)
--   USR-005: Cập nhật hồ sơ cá nhân
--   ADM-001: Quản trị danh sách người dùng & phân quyền Role
-- =============================================================================

CREATE TABLE `nguoi_dung` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh người dùng',
    `email` VARCHAR(150) NOT NULL UNIQUE COMMENT 'Email đăng nhập duy nhất (USR-001, USR-002)',
    `mat_khau` VARCHAR(255) NOT NULL COMMENT 'Mật khẩu đã băm bằng BCrypt',
    `ho_ten` VARCHAR(100) NOT NULL COMMENT 'Họ và tên người dùng (USR-005)',
    `so_dien_thoai` VARCHAR(20) DEFAULT NULL COMMENT 'Số điện thoại liên hệ (USR-005)',
    `anh_dai_dien` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn ảnh đại diện',
    `tieu_su` TEXT DEFAULT NULL COMMENT 'Tiểu sử / giới thiệu bản thân / giảng viên',
    `vai_tro` VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER' COMMENT 'ROLE_USER (Học viên), ROLE_INSTRUCTOR (Giảng viên), ROLE_ADMIN (Quản trị)',
    `trang_thai_hoat_dong` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Trạng thái hoạt động tài khoản (ADM-001)',
    `da_xac_thuc_email` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã kích hoạt / xác thực email chưa',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm đăng ký tài khoản (USR-001)',
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm cập nhật hồ sơ gần nhất (USR-005)',
    INDEX `idx_nguoi_dung_email` (`email`),
    INDEX `idx_nguoi_dung_vai_tro` (`vai_tro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng người dùng và phân quyền hệ thống (USR-001, USR-005, ADM-001)';

CREATE TABLE `token_nguoi_dung` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh token',
    `ma_nguoi_dung` BIGINT NOT NULL COMMENT 'Mã người dùng liên kết',
    `chuoi_token` VARCHAR(500) NOT NULL UNIQUE COMMENT 'Chuỗi JWT Token / Refresh Token (USR-002)',
    `loai_token` ENUM('REFRESH_TOKEN', 'ACCESS_TOKEN') NOT NULL DEFAULT 'REFRESH_TOKEN' COMMENT 'Phân loại token',
    `da_thu_hoi` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã thu hồi khi đăng xuất hay chưa (USR-003)',
    `ngay_het_han` TIMESTAMP NOT NULL COMMENT 'Thời hạn hết hạn của token',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm phát hành token',
    FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_token_chuoi` (`chuoi_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Quản lý phiên đăng nhập và thu hồi token (USR-002, USR-003)';

CREATE TABLE `ma_xac_thuc_otp` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh OTP',
    `ma_nguoi_dung` BIGINT NOT NULL COMMENT 'Mã người dùng yêu cầu cấp lại mật khẩu',
    `ma_otp` VARCHAR(10) NOT NULL COMMENT 'Mã OTP số (ví dụ 6 chữ số) gửi qua email (USR-004, NOT-001)',
    `chuoi_xac_thuc` VARCHAR(255) DEFAULT NULL COMMENT 'Mã bí mật xác thực nếu sử dụng liên kết reset',
    `da_su_dung` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Trạng thái đã sử dụng mã OTP',
    `ngay_het_han` TIMESTAMP NOT NULL COMMENT 'Thời điểm mã OTP hết hạn',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm tạo mã OTP',
    FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_otp_nguoi_dung` (`ma_nguoi_dung`, `ma_otp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lưu mã OTP phục vụ tính năng quên mật khẩu (USR-004)';

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

CREATE TABLE `danh_muc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh danh mục',
    `ten_danh_muc` VARCHAR(100) NOT NULL COMMENT 'Tên danh mục khóa học (ví dụ: Lập trình web, Ngoại ngữ...)',
    `duong_dan` VARCHAR(120) NOT NULL UNIQUE COMMENT 'Đường dẫn slug thân thiện URL (CRS-003)',
    `bieu_tuong` VARCHAR(500) DEFAULT NULL COMMENT 'Icon hoặc ảnh đại diện danh mục',
    `mo_ta` TEXT DEFAULT NULL COMMENT 'Mô tả tóm tắt nội dung danh mục',
    `ma_danh_muc_cha` BIGINT DEFAULT NULL COMMENT 'Mã danh mục cha nếu là danh mục đa cấp',
    `trang_thai_hoat_dong` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Trạng thái hiển thị danh mục',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_danh_muc_cha`) REFERENCES `danh_muc`(`id`) ON DELETE SET NULL,
    INDEX `idx_danh_muc_duong_dan` (`duong_dan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh mục phân loại khóa học (CRS-003)';

CREATE TABLE `khoa_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh khóa học',
    `ma_giang_vien` BIGINT NOT NULL COMMENT 'Mã giảng viên tạo và phụ trách khóa học (CRS-001)',
    `ma_danh_muc` BIGINT NOT NULL COMMENT 'Mã danh mục thuộc về (CRS-003)',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề khóa học',
    `duong_dan` VARCHAR(300) NOT NULL UNIQUE COMMENT 'Đường dẫn tĩnh thân thiện URL (slug)',
    `tieu_de_phu` VARCHAR(500) DEFAULT NULL COMMENT 'Mô tả ngắn gọn / phụ đề khóa học',
    `mo_ta_chi_tiet` LONGTEXT DEFAULT NULL COMMENT 'Nội dung chi tiết khóa học (định dạng HTML/Markdown)',
    `anh_dai_dien` VARCHAR(500) DEFAULT NULL COMMENT 'Ảnh thumbnail đại diện khóa học',
    `video_gioi_thieu` VARCHAR(500) DEFAULT NULL COMMENT 'Video trailer / xem thử khóa học',
    `gia_goc` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Giá gốc khóa học (VND)',
    `gia_khuyen_mai` DECIMAL(12, 2) DEFAULT 0.00 COMMENT 'Giá ưu đãi khuyến mãi',
    `trinh_do` ENUM('CO_BAN', 'TRUNG_CAP', 'NANG_CAO', 'TAT_CA') NOT NULL DEFAULT 'TAT_CA' COMMENT 'Cấp độ học viên phù hợp',
    `ngon_ngu` VARCHAR(50) NOT NULL DEFAULT 'Tiếng Việt' COMMENT 'Ngôn ngữ giảng dạy',
    `trang_thai` ENUM('BAN_NHAP', 'CHO_PHE_DUYET', 'DA_PHE_DUYET', 'TU_CHOI', 'DA_XUAT_BAN', 'LUU_TRU') NOT NULL DEFAULT 'BAN_NHAP' COMMENT 'Trạng thái kiểm duyệt (ADM-003)',
    `ly_do_tu_choi` TEXT DEFAULT NULL COMMENT 'Lý do admin từ chối phê duyệt khóa học (ADM-003)',
    `tong_thoi_luong_giay` INT NOT NULL DEFAULT 0 COMMENT 'Tổng thời lượng toàn bộ video (tính theo giây)',
    `tong_so_bai_hoc` INT NOT NULL DEFAULT 0 COMMENT 'Tổng số lượng bài học',
    `diem_danh_gia_trung_binh` DECIMAL(3, 2) NOT NULL DEFAULT 0.00 COMMENT 'Điểm đánh giá sao trung bình (1.00 - 5.00) (CRS-004)',
    `tong_so_danh_gia` INT NOT NULL DEFAULT 0 COMMENT 'Tổng số lượt học viên đã đánh giá (CRS-004)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm tạo khóa học',
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm chỉnh sửa gần nhất',
    FOREIGN KEY (`ma_giang_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_danh_muc`) REFERENCES `danh_muc`(`id`) ON DELETE RESTRICT,
    INDEX `idx_khoa_hoc_trang_thai` (`trang_thai`),
    INDEX `idx_khoa_hoc_danh_muc` (`ma_danh_muc`),
    INDEX `idx_khoa_hoc_giang_vien` (`ma_giang_vien`),
    FULLTEXT KEY `ft_khoa_hoc_tim_kiem` (`tieu_de`, `tieu_de_phu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông tin khóa học (CRS-001, CRS-003, ADM-003)';

CREATE TABLE `chuong_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh chương học',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học sở hữu chương này',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tên chương / phần học (ví dụ: Chương 1: Tổng quan)',
    `thu_tu_hien_thi` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự hiển thị các chương trong khóa học',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    INDEX `idx_chuong_hoc_khoa` (`ma_khoa_hoc`, `thu_tu_hien_thi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Các chương/phần học của khóa học (CRS-001)';

CREATE TABLE `bai_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh bài học',
    `ma_chuong_hoc` BIGINT NOT NULL COMMENT 'Mã chương học chứa bài này',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tên bài giảng',
    `thu_tu_hien_thi` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự bài học trong chương',
    `loai_bai_hoc` ENUM('VIDEO', 'BAI_VIET', 'TRAC_NGHIEM', 'BAI_TAP') NOT NULL DEFAULT 'VIDEO' COMMENT 'Phân loại bài giảng',
    `duong_dan_video` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn file video bài giảng (CRS-002, LRN-001)',
    `thoi_luong_video_giay` INT NOT NULL DEFAULT 0 COMMENT 'Thời lượng video bài học tính bằng giây',
    `dung_luong_video_bytes` BIGINT DEFAULT NULL COMMENT 'Dung lượng file video (hỗ trợ xử lý file lớn CRS-002)',
    `noi_dung_bai_viet` LONGTEXT DEFAULT NULL COMMENT 'Nội dung bài viết chi tiết nếu bài học dạng lý thuyết',
    `cho_phep_xem_thu` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Cờ cho phép học thử miễn phí trước khi mua',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_chuong_hoc`) REFERENCES `chuong_hoc`(`id`) ON DELETE CASCADE,
    INDEX `idx_bai_hoc_chuong` (`ma_chuong_hoc`, `thu_tu_hien_thi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết các bài học trong từng chương (CRS-002, LRN-001)';

CREATE TABLE `tai_lieu_bai_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh tài liệu',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài học đính kèm tài liệu',
    `ten_tai_lieu` VARCHAR(255) NOT NULL COMMENT 'Tên hiển thị của tài liệu (CRS-005)',
    `duong_dan_tep` VARCHAR(500) NOT NULL COMMENT 'Đường dẫn lưu trữ file trên máy chủ (PDF/Zip)',
    `dung_luong_bytes` BIGINT DEFAULT NULL COMMENT 'Kích thước file tính bằng byte',
    `dinh_dang_tep` VARCHAR(50) DEFAULT NULL COMMENT 'Định dạng file (pdf, zip, rar, docx...)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tài liệu học tập đính kèm bài giảng lưu trên server (CRS-005)';

CREATE TABLE `danh_gia_khoa_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh đánh giá',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học được đánh giá',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên viết đánh giá (CRS-004)',
    `so_sao` TINYINT NOT NULL COMMENT 'Số sao chấm điểm từ 1 đến 5 sao',
    `noi_dung_binh_luan` TEXT DEFAULT NULL COMMENT 'Nội dung nhận xét phản hồi',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_danh_gia_hoc_vien_khoa` (`ma_khoa_hoc`, `ma_hoc_vien`),
    CONSTRAINT `chk_danh_gia_so_sao` CHECK (`so_sao` BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đánh giá và nhận xét khóa học của học viên (CRS-004)';

CREATE TABLE `banner` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh banner',
    `tieu_de` VARCHAR(200) DEFAULT NULL COMMENT 'Tiêu đề banner quảng cáo (ADM-004)',
    `duong_dan_anh` VARCHAR(500) NOT NULL COMMENT 'Đường link ảnh banner',
    `duong_dan_chuyen_huong` VARCHAR(500) DEFAULT NULL COMMENT 'Link điều hướng khi học viên click vào banner',
    `thu_tu_hien_thi` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự ưu tiên hiển thị banner',
    `trang_thai_hien_thi` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Bật/tắt hiển thị trên trang chủ (ADM-004)',
    `ngay_bat_dau` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm bắt đầu chạy banner',
    `ngay_ket_thuc` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm kết thúc chiến dịch banner',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Quản lý banner quảng cáo trang chủ (ADM-004)';

-- =============================================================================
-- PHÂN HỆ 3: NGÂN HÀNG CÂU HỎI, TRẮC NGHIỆM & BÀI TẬP TỰ LUẬN
-- Use Cases:
--   CRS-006: Thêm/sửa câu trắc nghiệm trong ngân hàng câu hỏi (Giảng viên)
--   CRS-007: Chấm điểm bài tự luận (Giảng viên)
--   LRN-002: Làm bài quiz cuối chương & tự động chấm điểm (Học viên)
-- =============================================================================

CREATE TABLE `bai_trac_nghiem` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh bài trắc nghiệm',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học chứa bài quiz',
    `ma_bai_hoc` BIGINT DEFAULT NULL COMMENT 'Mã bài học nếu bài trắc nghiệm là một bài giảng',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề bài trắc nghiệm (LRN-002)',
    `mo_ta` TEXT DEFAULT NULL COMMENT 'Hướng dẫn và yêu cầu bài làm',
    `thoi_gian_lam_bai_phut` INT NOT NULL DEFAULT 15 COMMENT 'Thời gian giới hạn tính theo phút',
    `diem_qua_mon` INT NOT NULL DEFAULT 80 COMMENT 'Tỉ lệ phần trăm cần đạt để vượt qua (ví dụ 80%)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bài kiểm tra trắc nghiệm cuối chương / khóa học (LRN-002)';

CREATE TABLE `cau_hoi` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh câu hỏi',
    `ma_bai_trac_nghiem` BIGINT DEFAULT NULL COMMENT 'Mã quiz gắn liền (hoặc NULL nếu nằm trong ngân hàng câu hỏi dùng chung)',
    `ma_giang_vien` BIGINT NOT NULL COMMENT 'Mã giảng viên sở hữu câu hỏi (CRS-006)',
    `noi_dung_cau_hoi` TEXT NOT NULL COMMENT 'Nội dung câu hỏi trắc nghiệm',
    `giai_thich_dap_an` TEXT DEFAULT NULL COMMENT 'Lời giải thích đáp án hiển thị sau khi nộp bài',
    `loai_cau_hoi` ENUM('MOT_DAP_AN', 'NHIEU_DAP_AN', 'DUNG_SAI') NOT NULL DEFAULT 'MOT_DAP_AN' COMMENT 'Dạng câu trắc nghiệm (CRS-006)',
    `diem_so` INT NOT NULL DEFAULT 1 COMMENT 'Số điểm của câu hỏi',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_bai_trac_nghiem`) REFERENCES `bai_trac_nghiem`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_giang_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ngân hàng câu hỏi trắc nghiệm của giảng viên (CRS-006)';

CREATE TABLE `lua_chon_dap_an` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh lựa chọn',
    `ma_cau_hoi` BIGINT NOT NULL COMMENT 'Mã câu hỏi cha',
    `noi_dung_lua_chon` TEXT NOT NULL COMMENT 'Nội dung phương án trả lời (A, B, C, D...)',
    `la_dap_an_dung` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đánh dấu đây có phải là đáp án chính xác không',
    `thu_tu_hien_thi` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự lựa chọn trong câu hỏi',
    FOREIGN KEY (`ma_cau_hoi`) REFERENCES `cau_hoi`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Các lựa chọn đáp án cho câu hỏi trắc nghiệm (CRS-006)';

CREATE TABLE `lan_lam_trac_nghiem` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh lượt làm bài',
    `ma_bai_trac_nghiem` BIGINT NOT NULL COMMENT 'Mã bài trắc nghiệm đã làm',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên thực hiện bài làm (LRN-002)',
    `diem_so` DECIMAL(5, 2) NOT NULL COMMENT 'Điểm số đạt được (tính trên thang 100)',
    `tong_so_cau` INT NOT NULL COMMENT 'Tổng số lượng câu hỏi trong đề',
    `so_cau_dung` INT NOT NULL COMMENT 'Số lượng câu trả lời chính xác',
    `ket_qua_dat` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã vượt qua ngưỡng điểm yêu cầu hay chưa (Tự động chấm LRN-002)',
    `thoi_gian_bat_dau` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm bắt đầu tính giờ',
    `thoi_gian_nop_bai` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm nộp bài hoàn tất',
    FOREIGN KEY (`ma_bai_trac_nghiem`) REFERENCES `bai_trac_nghiem`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử và kết quả bài làm trắc nghiệm của học viên (LRN-002)';

CREATE TABLE `cau_tra_loi_trac_nghiem` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh chi tiết trả lời',
    `ma_lan_lam_bai` BIGINT NOT NULL COMMENT 'Mã lượt làm bài tương ứng',
    `ma_cau_hoi` BIGINT NOT NULL COMMENT 'Mã câu hỏi đã trả lời',
    `ma_lua_chon_da_chon` BIGINT DEFAULT NULL COMMENT 'Mã phương án mà học viên đã chọn',
    `la_cau_tra_loi_dung` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Kết quả câu này đúng hay sai',
    FOREIGN KEY (`ma_lan_lam_bai`) REFERENCES `lan_lam_trac_nghiem`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_cau_hoi`) REFERENCES `cau_hoi`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_lua_chon_da_chon`) REFERENCES `lua_chon_dap_an`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết các câu trả lời trong từng lần thi trắc nghiệm (LRN-002)';

CREATE TABLE `bai_tap_tu_luan` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh bài tập tự luận',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài học chứa bài tập này',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề bài tập tự luận (CRS-007)',
    `de_bai_huong_dan` LONGTEXT NOT NULL COMMENT 'Đề bài và hướng dẫn chi tiết thực hiện',
    `tep_dinh_kem_huong_dan` VARCHAR(500) DEFAULT NULL COMMENT 'File tài liệu hướng dẫn hoặc mã nguồn mẫu kèm theo',
    `han_nop_bai` TIMESTAMP NULL DEFAULT NULL COMMENT 'Hạn chót để học viên nộp bài',
    `diem_toi_da` INT NOT NULL DEFAULT 100 COMMENT 'Thang điểm tối đa của bài tập',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bài tập tự luận do giảng viên giao (CRS-007)';

CREATE TABLE `bai_nop_tu_luan` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh bài nộp',
    `ma_bai_tap` BIGINT NOT NULL COMMENT 'Mã bài tập tự luận tương ứng',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên nộp bài làm',
    `noi_dung_bai_nop` TEXT DEFAULT NULL COMMENT 'Nội dung văn bản học viên trình bày',
    `duong_dan_tep_nop` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn file nộp đính kèm (Zip, PDF, mã nguồn)',
    `trang_thai_cham` ENUM('DA_NOP', 'DA_CHAM', 'YEU_CAU_LAM_LAI') NOT NULL DEFAULT 'DA_NOP' COMMENT 'Trạng thái chấm điểm (CRS-007)',
    `diem_so` DECIMAL(5, 2) DEFAULT NULL COMMENT 'Điểm số do giảng viên đánh giá (CRS-007)',
    `nhan_xet_giang_vien` TEXT DEFAULT NULL COMMENT 'Lời nhận xét góp ý của giảng viên',
    `ma_giang_vien_cham` BIGINT DEFAULT NULL COMMENT 'Mã giảng viên trực tiếp chấm bài',
    `thoi_gian_nop` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm học viên nộp bài',
    `thoi_gian_cham` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm hoàn thành chấm điểm',
    FOREIGN KEY (`ma_bai_tap`) REFERENCES `bai_tap_tu_luan`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_giang_vien_cham`) REFERENCES `nguoi_dung`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bài làm tự luận của học viên và kết quả chấm điểm của giảng viên (CRS-007)';

-- =============================================================================
-- PHÂN HỆ 4: GIỎ HÀNG, THANH TOÁN, KHUYẾN MÃI & DOANH THU (PAYMENTS & ORDERS)
-- Use Cases:
--   PAY-001: Giỏ hàng - Thêm/Xóa khóa học (Học viên)
--   PAY-002: Checkout - Thanh toán qua VNPay (Học viên)
--   PAY-003: Xem lịch sử giao dịch (Học viên)
--   MKT-001: Tạo mã Voucher giảm giá (Admin / Giảng viên)
--   ADM-002: Báo cáo doanh thu & thống kê tháng (Admin)
-- =============================================================================

CREATE TABLE `ma_giam_gia` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh voucher',
    `ma_code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Chuỗi mã khuyến mãi nhập vào (ví dụ: GIAM20, CHAOMUNG) - MKT-001',
    `mo_ta` VARCHAR(255) DEFAULT NULL COMMENT 'Mô tả chương trình khuyến mãi',
    `loai_giam_gia` ENUM('PHAN_TRAM', 'SO_TIEN_CO_DINH') NOT NULL DEFAULT 'PHAN_TRAM' COMMENT 'Hình thức giảm theo % hoặc số tiền cố định',
    `gia_tri_giam` DECIMAL(12, 2) NOT NULL COMMENT 'Giá trị giảm (ví dụ: 20% hoặc 50.000 VND)',
    `gia_tri_don_hang_toi_thieu` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng mã',
    `so_tien_giam_toi_da` DECIMAL(12, 2) DEFAULT NULL COMMENT 'Số tiền giảm tối đa (nếu là loại phần trăm)',
    `so_luong_gioi_han` INT NOT NULL DEFAULT 100 COMMENT 'Tổng số lượt sử dụng tối đa của mã',
    `so_luong_da_dung` INT NOT NULL DEFAULT 0 COMMENT 'Số lượt đã được người dùng sử dụng',
    `ngay_bat_dau` TIMESTAMP NOT NULL COMMENT 'Thời điểm mã bắt đầu có hiệu lực',
    `ngay_ket_thuc` TIMESTAMP NOT NULL COMMENT 'Thời điểm mã hết hạn',
    `trang_thai_kich_hoat` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Bật/tắt sử dụng mã voucher',
    `ma_nguoi_tao` BIGINT NOT NULL COMMENT 'Mã Admin hoặc Giảng viên tạo mã (MKT-001)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_nguoi_tao`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_ma_giam_gia_code` (`ma_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Mã voucher khuyến mãi giảm giá (MKT-001)';

CREATE TABLE `gio_hang` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh mục giỏ hàng',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên sở hữu giỏ hàng (PAY-001)',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học được thêm vào giỏ',
    `ngay_them` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm thêm khóa học vào giỏ',
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_gio_hang_hoc_vien_khoa` (`ma_hoc_vien`, `ma_khoa_hoc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Giỏ hàng học viên lưu trữ trên hệ thống (PAY-001)';

CREATE TABLE `don_hang` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh đơn hàng',
    `ma_don_hang` VARCHAR(64) NOT NULL UNIQUE COMMENT 'Mã đơn hàng duy nhất phục vụ tra cứu (ví dụ: ORD-20260925-1029)',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên thanh toán mua khóa học (PAY-002)',
    `ma_giam_gia_id` BIGINT DEFAULT NULL COMMENT 'Mã voucher đã áp dụng (nếu có)',
    `tong_tien_goc` DECIMAL(12, 2) NOT NULL COMMENT 'Tổng số tiền gốc ban đầu trước khi giảm',
    `so_tien_giam` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Số tiền được giảm giá',
    `so_tien_thanh_toan` DECIMAL(12, 2) NOT NULL COMMENT 'Số tiền thực tế học viên phải trả (PAY-002, ADM-002)',
    `trang_thai_don_hang` ENUM('CHO_THANH_TOAN', 'DA_THANH_TOAN', 'DA_HUY', 'THAT_BAI', 'HOAN_TIEN') NOT NULL DEFAULT 'CHO_THANH_TOAN' COMMENT 'Trạng thái xử lý đơn hàng',
    `phuong_thuc_thanh_toan` ENUM('VNPAY', 'MOMO', 'STRIPE', 'CHUYEN_KHOAN', 'MIEN_PHI') NOT NULL DEFAULT 'VNPAY' COMMENT 'Cổng thanh toán lựa chọn (PAY-002)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm tạo đơn hàng',
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm cập nhật trạng thái',
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_giam_gia_id`) REFERENCES `ma_giam_gia`(`id`) ON DELETE SET NULL,
    INDEX `idx_don_hang_trang_thai` (`trang_thai_don_hang`),
    INDEX `idx_don_hang_hoc_vien` (`ma_hoc_vien`),
    INDEX `idx_don_hang_ngay_tao` (`ngay_tao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn đặt hàng khóa học của học viên (PAY-002, ADM-002)';

CREATE TABLE `chi_tiet_don_hang` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh chi tiết đơn hàng',
    `ma_don_hang` BIGINT NOT NULL COMMENT 'Mã đơn hàng liên kết',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học được mua',
    `gia_tai_thoi_diem_mua` DECIMAL(12, 2) NOT NULL COMMENT 'Giá bán khóa học tại thời điểm lập đơn',
    FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh sách các khóa học trong đơn hàng (PAY-002)';

CREATE TABLE `giao_dich_thanh_toan` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh giao dịch',
    `ma_don_hang` BIGINT NOT NULL COMMENT 'Mã đơn hàng cần thanh toán',
    `cong_thanh_toan` VARCHAR(50) NOT NULL DEFAULT 'VNPAY' COMMENT 'Cổng thanh toán thực hiện (VNPay Sandbox PAY-002)',
    `ma_giao_dich_tham_chieu` VARCHAR(100) NOT NULL COMMENT 'Mã gửi sang cổng thanh toán (vnp_TxnRef)',
    `ma_giao_dich_gateway` VARCHAR(100) DEFAULT NULL COMMENT 'Mã số giao dịch do cổng thanh toán/ngân hàng phản hồi (vnp_TransactionNo)',
    `ma_ngan_hang` VARCHAR(50) DEFAULT NULL COMMENT 'Mã ngân hàng học viên chọn thanh toán (NCB, VCB...)',
    `so_tien_giao_dich` DECIMAL(12, 2) NOT NULL COMMENT 'Số tiền thanh toán thực tế',
    `loai_tien_te` VARCHAR(10) NOT NULL DEFAULT 'VND' COMMENT 'Loại tiền tệ giao dịch',
    `trang_thai_giao_dich` ENUM('DANG_XU_LY', 'THANH_CONG', 'THAT_BAI') NOT NULL DEFAULT 'DANG_XU_LY' COMMENT 'Trạng thái kết quả giao dịch',
    `ma_phan_hoi_gateway` VARCHAR(50) DEFAULT NULL COMMENT 'Mã kết quả phản hồi từ cổng thanh toán (00 = Thành công)',
    `thoi_gian_thanh_toan` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm thanh toán thành công (PAY-003)',
    `du_lieu_phan_hoi` TEXT DEFAULT NULL COMMENT 'Toàn bộ dữ liệu callback/IPN webhook trả về',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang`(`id`) ON DELETE CASCADE,
    INDEX `idx_giao_dich_tham_chieu` (`ma_giao_dich_tham_chieu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử chi tiết giao dịch cổng thanh toán VNPay (PAY-002, PAY-003)';

CREATE TABLE `dang_ky_khoa_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh lượt đăng ký',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên sở hữu quyền học',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học được cấp quyền truy cập',
    `ma_don_hang` BIGINT DEFAULT NULL COMMENT 'Mã đơn hàng kích hoạt (NULL nếu được tặng/miễn phí)',
    `trang_thai_khoa_hoc` ENUM('DANG_HOC', 'HET_HAN', 'BI_KHOA') NOT NULL DEFAULT 'DANG_HOC' COMMENT 'Trạng thái quyền học tập',
    `phan_tram_tien_do` DECIMAL(5, 2) NOT NULL DEFAULT 0.00 COMMENT 'Tiến độ học hoàn thành tổng thể (0.00% - 100.00%)',
    `ngay_dang_ky` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm kích hoạt vào học',
    `ngay_hoan_thanh` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm học viên hoàn thành 100% khóa học',
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang`(`id`) ON DELETE SET NULL,
    UNIQUE KEY `uk_dang_ky_hoc_vien_khoa` (`ma_hoc_vien`, `ma_khoa_hoc`),
    INDEX `idx_dang_ky_hoc_vien` (`ma_hoc_vien`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh sách khóa học học viên đã đăng ký sở hữu (PAY-003, LRN-001)';

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

CREATE TABLE `tien_do_bai_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh tiến độ',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên đang học (LRN-001)',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài học đang theo dõi',
    `da_hoan_thanh` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã hoàn thành bài học này chưa (LRN-001)',
    `giay_dung_lai_cuoi_cung` INT NOT NULL DEFAULT 0 COMMENT 'Thời điểm giây dừng lại lần xem video gần nhất',
    `ngay_hoan_thanh` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm đánh dấu hoàn thành bài học',
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_tien_do_hoc_vien_bai_hoc` (`ma_hoc_vien`, `ma_bai_hoc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Theo dõi tiến độ xem video bài giảng của học viên (LRN-001)';

CREATE TABLE `ghi_chu_video` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh ghi chú',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên ghi chú (LRN-006)',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài giảng đang xem',
    `thoi_diem_giay` INT NOT NULL COMMENT 'Mốc thời gian giây trong video bài giảng (LRN-006)',
    `noi_dung_ghi_chu` TEXT NOT NULL COMMENT 'Nội dung ghi chú cá nhân của học viên',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE,
    INDEX `idx_ghi_chu_hoc_vien_bai_hoc` (`ma_hoc_vien`, `ma_bai_hoc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ghi chú cá nhân theo timestamp video bài giảng (LRN-006)';

CREATE TABLE `cau_hoi_dap` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh thảo luận',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài học diễn ra thảo luận',
    `ma_nguoi_dung` BIGINT NOT NULL COMMENT 'Người gửi câu hỏi hoặc câu trả lời (LRN-007)',
    `ma_cau_hoi_cha` BIGINT DEFAULT NULL COMMENT 'Mã câu hỏi gốc nếu là phản hồi theo luồng (Thread)',
    `noi_dung_thao_luan` TEXT NOT NULL COMMENT 'Nội dung câu hỏi / trao đổi (SignalR LRN-007)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_cau_hoi_cha`) REFERENCES `cau_hoi_dap`(`id`) ON DELETE CASCADE,
    INDEX `idx_cau_hoi_dap_bai_hoc` (`ma_bai_hoc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Hỏi đáp (Q&A) tương tác dưới bài giảng (LRN-007)';

CREATE TABLE `phong_hoc_truc_tuyen` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh phòng học',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học tổ chức buổi Live',
    `ma_giang_vien` BIGINT NOT NULL COMMENT 'Mã giảng viên chủ trì phòng học (LRN-003)',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề buổi học trực tuyến',
    `mo_ta` TEXT DEFAULT NULL COMMENT 'Mô tả nội dung buổi thảo luận trực tiếp',
    `duong_dan_phong_hoc` VARCHAR(500) NOT NULL COMMENT 'Đường dẫn liên kết phòng Google Meet / Jitsi (LRN-003)',
    `mat_khau_phong_hoc` VARCHAR(50) DEFAULT NULL COMMENT 'Mật khẩu tham gia phòng học (nếu có)',
    `thoi_gian_bat_dau` TIMESTAMP NOT NULL COMMENT 'Thời điểm bắt đầu buổi Live',
    `thoi_gian_ket_thuc` TIMESTAMP NOT NULL COMMENT 'Thời điểm kết thúc buổi Live',
    `trang_thai_phong_hoc` ENUM('CHUA_BAT_DAU', 'DANG_DIEN_RA', 'DA_KET_THUC', 'DA_HUY') NOT NULL DEFAULT 'CHUA_BAT_DAU' COMMENT 'Trạng thái phòng học',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_giang_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_phong_hoc_trang_thai_thoi_gian` (`trang_thai_phong_hoc`, `thoi_gian_bat_dau`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Phòng học trực tuyến ảo qua Google Meet / Live (LRN-003)';

CREATE TABLE `nguoi_tham_gia_phong_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh lượt tham gia',
    `ma_phong_hoc` BIGINT NOT NULL COMMENT 'Mã phòng học trực tuyến',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên tham gia phòng học (LRN-004)',
    `thoi_gian_vao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm vào phòng',
    `thoi_gian_roi` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm rời khỏi phòng',
    FOREIGN KEY (`ma_phong_hoc`) REFERENCES `phong_hoc_truc_tuyen`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nhật ký học viên tham gia phòng học trực tuyến (LRN-004)';

CREATE TABLE `chung_chi` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh chứng chỉ',
    `ma_chung_chi` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Mã tra cứu chứng chỉ duy nhất (ví dụ: CERT-2026-JAVA01) LRN-005',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên được cấp chứng chỉ',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học đã hoàn thành',
    `duong_dan_tep_pdf` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn file PDF chứng chỉ xuất tự động (LRN-005)',
    `ngay_cap` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm hệ thống cấp chứng chỉ',
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_chung_chi_hoc_vien_khoa` (`ma_hoc_vien`, `ma_khoa_hoc`),
    INDEX `idx_chung_chi_ma` (`ma_chung_chi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chứng chỉ tốt nghiệp khóa học xuất file PDF tự động (LRN-005)';

-- =============================================================================
-- PHÂN HỆ 6: THÔNG BÁO & NHẬT KÝ EMAIL HỆ THỐNG (NOTIFICATIONS & EMAILS)
-- Use Cases:
--   NOT-001: Gửi email nhắc lịch học / thanh toán (Hệ thống SMTP)
--   NOT-002: In-app Notification - Thông báo quả chuông (Hệ thống)
-- =============================================================================

CREATE TABLE `thong_bao` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh thông báo',
    `ma_nguoi_dung` BIGINT NOT NULL COMMENT 'Mã người dùng nhận thông báo (NOT-002)',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề ngắn gọn của thông báo',
    `noi_dung` TEXT NOT NULL COMMENT 'Nội dung chi tiết thông báo trên quả chuông',
    `loai_thong_bao` VARCHAR(50) NOT NULL DEFAULT 'HE_THONG' COMMENT 'Phân loại: HE_THONG, THANH_TOAN, KHOA_HOC, PHONG_LIVE',
    `duong_dan_dieu_huong` VARCHAR(500) DEFAULT NULL COMMENT 'Đường link chuyển đến khi người dùng click vào thông báo',
    `da_doc` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đánh dấu đã đọc thông báo hay chưa (NOT-002)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm phát sinh thông báo',
    FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_thong_bao_nguoi_dung_da_doc` (`ma_nguoi_dung`, `da_doc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông báo in-app hiển thị trên chuông thông báo (NOT-002)';

CREATE TABLE `nhat_ky_email` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh nhật ký email',
    `email_nguoi_nhan` VARCHAR(150) NOT NULL COMMENT 'Địa chỉ email người nhận (NOT-001)',
    `tieu_de_email` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề email đã gửi',
    `ten_mau_email` VARCHAR(100) DEFAULT NULL COMMENT 'Tên template email sử dụng (nhac_lich_hoc, hoa_don_thanh_toan, quen_mat_khau)',
    `trang_thai_gui` ENUM('CHO_GUI', 'DA_GUI', 'THAT_BAI') NOT NULL DEFAULT 'CHO_GUI' COMMENT 'Trạng thái gửi email qua SMTP',
    `thong_bao_loi` TEXT DEFAULT NULL COMMENT 'Chi tiết lỗi nếu gửi thất bại qua SMTP',
    `thoi_gian_gui` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm email được gửi thành công',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_nhat_ky_email_trang_thai` (`trang_thai_gui`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nhật ký gửi email hệ thống qua SMTP (NOT-001)';

-- =============================================================================
-- DỮ LIỆU KHỞI TẠO MẪU (SEED DATA TIẾNG VIỆT)
-- Mật khẩu mặc định của tất cả tài khoản mẫu bên dưới là: 123456
-- (Đã băm BCrypt: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi)
-- =============================================================================

-- 1. Tài khoản mẫu: Admin, Giảng viên, Học viên
INSERT INTO `nguoi_dung` (`id`, `email`, `mat_khau`, `ho_ten`, `so_dien_thoai`, `vai_tro`, `trang_thai_hoat_dong`, `da_xac_thuc_email`) VALUES
(1, 'admin@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Hệ Thống Quản Trị (Admin)', '0901234567', 'ROLE_ADMIN', TRUE, TRUE),
(2, 'giangvien@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Thầy Nguyễn Văn A (Giảng Viên)', '0912345678', 'ROLE_INSTRUCTOR', TRUE, TRUE),
(3, 'hocvien@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Trần Thị B (Học Viên)', '0987654321', 'ROLE_USER', TRUE, TRUE);

-- 2. Danh mục khóa học (CRS-003)
INSERT INTO `danh_muc` (`id`, `ten_danh_muc`, `duong_dan`, `bieu_tuong`, `mo_ta`) VALUES
(1, 'Lập Trình Web Fullstack', 'lap-trinh-web-fullstack', 'https://cdn.iconscout.com/icon/free/png-256/react-1-282599.png', 'Các khóa học từ Frontend tới Backend hiện đại'),
(2, 'Trí Tuệ Nhân Tạo & Dữ Liệu', 'tri-tue-nhan-tao-du-lieu', 'https://cdn.iconscout.com/icon/free/png-256/python-3521655-2945099.png', 'Học Python, Machine Learning và xử lý dữ liệu lớn'),
(3, 'Thiết Kế Đồ Họa & UI/UX', 'thiet-ke-do-hoa-ui-ux', 'https://cdn.iconscout.com/icon/free/png-256/figma-3521426-2944870.png', 'Kỹ năng thiết kế giao diện và trải nghiệm người dùng');

-- 3. Khóa học mẫu (CRS-001, ADM-003)
INSERT INTO `khoa_hoc` (`id`, `ma_giang_vien`, `ma_danh_muc`, `tieu_de`, `duong_dan`, `tieu_de_phu`, `mo_ta_chi_tiet`, `anh_dai_dien`, `gia_goc`, `gia_khuyen_mai`, `trinh_do`, `trang_thai`, `tong_thoi_luong_giay`, `tong_so_bai_hoc`, `diem_danh_gia_trung_binh`, `tong_so_danh_gia`) VALUES
(1, 2, 1, 'Lập Trình Spring Boot 4 & Next.js 16 Fullstack Toàn Diện', 'lap-trinh-spring-boot-4-nextjs-16-fullstack', 'Xây dựng ứng dụng E-learning SaaS hoàn chỉnh từ con số 0', '<p>Khóa học thực chiến toàn diện giúp bạn làm chủ kiến trúc Spring Boot và Next.js hiện đại.</p>', 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600', 1200000.00, 799000.00, 'TRUNG_CAP', 'DA_XUAT_BAN', 36000, 15, 5.00, 1);

-- 4. Chương & Bài học (CRS-001, CRS-002, LRN-001)
INSERT INTO `chuong_hoc` (`id`, `ma_khoa_hoc`, `tieu_de`, `thu_tu_hien_thi`) VALUES
(1, 1, 'Chương 1: Giới thiệu kiến trúc hệ thống và cài đặt môi trường', 1),
(2, 1, 'Chương 2: Thiết kế Database tiếng Việt và RESTful API với Spring Boot', 2);

INSERT INTO `bai_hoc` (`id`, `ma_chuong_hoc`, `tieu_de`, `thu_tu_hien_thi`, `loai_bai_hoc`, `duong_dan_video`, `thoi_luong_video_giay`, `dung_luong_video_bytes`, `cho_phep_xem_thu`) VALUES
(1, 1, 'Bài 1: Tổng quan dự án E-learning SaaS CDIO', 1, 'VIDEO', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 600, 52428800, TRUE),
(2, 1, 'Bài 2: Hướng dẫn cài đặt JDK 17, MySQL và Docker', 2, 'VIDEO', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 900, 83886080, FALSE),
(3, 2, 'Bài 3: Xây dựng Entity JPA và Cấu hình Spring Security JWT', 1, 'VIDEO', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 1200, 104857600, FALSE);

-- 5. Tài liệu đính kèm bài học (CRS-005)
INSERT INTO `tai_lieu_bai_hoc` (`id`, `ma_bai_hoc`, `ten_tai_lieu`, `duong_dan_tep`, `dung_luong_bytes`, `dinh_dang_tep`) VALUES
(1, 1, 'So-do-kien-truc-he-thong.pdf', 'https://storage.example.com/docs/kien-truc.pdf', 2048000, 'pdf'),
(2, 2, 'Source-code-starter-template.zip', 'https://storage.example.com/docs/starter.zip', 15400000, 'zip');

-- 6. Mã Voucher khuyến mãi (MKT-001)
INSERT INTO `ma_giam_gia` (`id`, `ma_code`, `mo_ta`, `loai_giam_gia`, `gia_tri_giam`, `gia_tri_don_hang_toi_thieu`, `so_tien_giam_toi_da`, `so_luong_gioi_han`, `so_luong_da_dung`, `ngay_bat_dau`, `ngay_ket_thuc`, `trang_thai_kich_hoat`, `ma_nguoi_tao`) VALUES
(1, 'CHAOMUNG2026', 'Giảm 20% cho đơn hàng đầu tiên', 'PHAN_TRAM', 20.00, 500000.00, 200000.00, 500, 1, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, 1),
(2, 'GIAM50K', 'Giảm trực tiếp 50.000 VND mọi khóa học', 'SO_TIEN_CO_DINH', 50000.00, 100000.00, 50000.00, 1000, 0, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, 1);

-- 7. Banner trang chủ (ADM-004)
INSERT INTO `banner` (`id`, `tieu_de`, `duong_dan_anh`, `duong_dan_chuyen_huong`, `thu_tu_hien_thi`, `trang_thai_hien_thi`) VALUES
(1, 'Đại tiệc Back to School - Giảm 50% Khóa học Fullstack', 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200', '/courses', 1, TRUE),
(2, 'Làm chủ Trí Tuệ Nhân Tạo cùng Chuyên Gia', 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=1200', '/category/tri-tue-nhan-tao-du-lieu', 2, TRUE);

-- 8. Bài trắc nghiệm & Ngân hàng câu hỏi mẫu (CRS-006, LRN-002)
INSERT INTO `bai_trac_nghiem` (`id`, `ma_khoa_hoc`, `ma_bai_hoc`, `tieu_de`, `mo_ta`, `thoi_gian_lam_bai_phut`, `diem_qua_mon`) VALUES
(1, 1, NULL, 'Bài kiểm tra trắc nghiệm cuối Chương 1', 'Kiểm tra kiến thức cơ bản về HTTP, REST và Spring Boot', 15, 80);

INSERT INTO `cau_hoi` (`id`, `ma_bai_trac_nghiem`, `ma_giang_vien`, `noi_dung_cau_hoi`, `giai_thich_dap_an`, `loai_cau_hoi`, `diem_so`) VALUES
(1, 1, 2, 'Phương thức HTTP nào sau đây thường được sử dụng để tạo mới một tài nguyên trong RESTful API?', 'POST là phương thức chuẩn dùng để tạo mới tài nguyên trên Server.', 'MOT_DAP_AN', 1),
(2, 1, 2, 'Annotation nào trong Spring Boot đánh dấu một lớp là Controller trả về JSON?', '@RestController là sự kết hợp giữa @Controller và @ResponseBody.', 'MOT_DAP_AN', 1);

INSERT INTO `lua_chon_dap_an` (`id`, `ma_cau_hoi`, `noi_dung_lua_chon`, `la_dap_an_dung`, `thu_tu_hien_thi`) VALUES
(1, 1, 'GET', FALSE, 1),
(2, 1, 'POST', TRUE, 2),
(3, 1, 'PUT', FALSE, 3),
(4, 1, 'DELETE', FALSE, 4),
(5, 2, '@Controller', FALSE, 1),
(6, 2, '@Service', FALSE, 2),
(7, 2, '@RestController', TRUE, 3),
(8, 2, '@Component', FALSE, 4);

-- 9. Đánh giá khóa học mẫu (CRS-004)
INSERT INTO `danh_gia_khoa_hoc` (`id`, `ma_khoa_hoc`, `ma_hoc_vien`, `so_sao`, `noi_dung_binh_luan`) VALUES
(1, 1, 3, 5, 'Khóa học rất hay, giảng viên giảng giải chi tiết, dễ hiểu và thực chiến cao!');

-- 10. Thông báo mẫu (NOT-002)
INSERT INTO `thong_bao` (`id`, `ma_nguoi_dung`, `tieu_de`, `noi_dung`, `loai_thong_bao`, `duong_dan_dieu_huong`, `da_doc`) VALUES
(1, 3, 'Chào mừng đến với hệ thống E-Learning!', 'Cảm ơn bạn đã tham gia nền tảng. Hãy bắt đầu hành trình học tập ngay hôm nay!', 'HE_THONG', '/courses', FALSE);
