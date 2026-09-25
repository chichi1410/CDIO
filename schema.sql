-- =============================================================================
-- HỆ THỐNG QUẢN LÝ HỌC TRỰC TUYẾN (E-LEARNING / LMS SAAS PLATFORM)
-- CƠ SỞ DỮ LIỆU ĐƯỢC TINH GỌN CHUẨN XÁC THEO 20 USE CASES DỰ ÁN
-- Cơ sở dữ liệu: MySQL 8.0+ / MariaDB 10.5+
-- Bảng mã: utf8mb4 (Hỗ trợ tiếng Việt đầy đủ và Emoji)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `saas_new_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `saas_new_db`;

-- Tạm thời tắt ràng buộc khóa ngoại khi dọn dẹp và tạo bảng
SET FOREIGN_KEY_CHECKS = 0;

-- Dọn dẹp toàn bộ các bảng cũ và bảng thừa không nằm trong 20 Use Cases
DROP TABLE IF EXISTS `nhat_ky_email`;
DROP TABLE IF EXISTS `thong_bao`;
DROP TABLE IF EXISTS `tien_do_bai_hoc`;
DROP TABLE IF EXISTS `dang_ky_khoa_hoc`;
DROP TABLE IF EXISTS `giao_dich_thanh_toan`;
DROP TABLE IF EXISTS `chi_tiet_don_hang`;
DROP TABLE IF EXISTS `don_hang`;
DROP TABLE IF EXISTS `gio_hang`;
DROP TABLE IF EXISTS `tai_lieu_bai_hoc`;
DROP TABLE IF EXISTS `bai_hoc`;
DROP TABLE IF EXISTS `chuong_hoc`;
DROP TABLE IF EXISTS `khoa_hoc`;
DROP TABLE IF EXISTS `danh_muc`;
DROP TABLE IF EXISTS `banner`;
DROP TABLE IF EXISTS `ma_xac_thuc_otp`;
DROP TABLE IF EXISTS `token_nguoi_dung`;
DROP TABLE IF EXISTS `nguoi_dung`;

-- Xóa các bảng thừa bị loại bỏ (không có trong danh sách 20 Use Cases)
DROP TABLE IF EXISTS `chung_chi`;
DROP TABLE IF EXISTS `nguoi_tham_gia_phong_hoc`;
DROP TABLE IF EXISTS `phong_hoc_truc_tuyen`;
DROP TABLE IF EXISTS `cau_hoi_dap`;
DROP TABLE IF EXISTS `ghi_chu_video`;
DROP TABLE IF EXISTS `ma_giam_gia`;
DROP TABLE IF EXISTS `bai_nop_tu_luan`;
DROP TABLE IF EXISTS `bai_tap_tu_luan`;
DROP TABLE IF EXISTS `cau_tra_loi_trac_nghiem`;
DROP TABLE IF EXISTS `lan_lam_trac_nghiem`;
DROP TABLE IF EXISTS `lua_chon_dap_an`;
DROP TABLE IF EXISTS `cau_hoi`;
DROP TABLE IF EXISTS `bai_trac_nghiem`;
DROP TABLE IF EXISTS `danh_gia_khoa_hoc`;

-- Xóa các bảng tên tiếng Anh cũ (nếu có)
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
--   USR-002: Đăng nhập (Dùng JWT Token)
--   USR-003: Đăng xuất (Thu hồi JWT Token)
--   USR-004: Quên mật khẩu (Tích hợp gửi Email OTP)
--   USR-005: Cập nhật hồ sơ cá nhân
--   ADM-001: Quản trị danh sách người dùng & Phân quyền Role
-- =============================================================================

CREATE TABLE `nguoi_dung` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh người dùng',
    `email` VARCHAR(150) NOT NULL UNIQUE COMMENT 'Email đăng nhập duy nhất (USR-001, USR-002)',
    `mat_khau` VARCHAR(255) NOT NULL COMMENT 'Mật khẩu đã băm bằng BCrypt',
    `ho_ten` VARCHAR(100) NOT NULL COMMENT 'Họ và tên người dùng (USR-005)',
    `so_dien_thoai` VARCHAR(20) DEFAULT NULL COMMENT 'Số điện thoại liên hệ (USR-005)',
    `anh_dai_dien` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn ảnh đại diện',
    `tieu_su` TEXT DEFAULT NULL COMMENT 'Tiểu sử / giới thiệu bản thân / giảng viên',
    `vai_tro` VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER' COMMENT 'ROLE_USER (Học viên), ROLE_INSTRUCTOR (Giảng viên), ROLE_ADMIN (Quản trị) (ADM-001)',
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
    `ma_otp` VARCHAR(10) NOT NULL COMMENT 'Mã OTP 6 chữ số gửi qua email (USR-004, NOT-001)',
    `da_su_dung` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Trạng thái đã sử dụng mã OTP',
    `ngay_het_han` TIMESTAMP NOT NULL COMMENT 'Thời điểm mã OTP hết hạn',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm tạo mã OTP',
    FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_otp_nguoi_dung` (`ma_nguoi_dung`, `ma_otp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lưu mã OTP phục vụ tính năng quên mật khẩu (USR-004)';

-- =============================================================================
-- PHÂN HỆ 2: KHÁM PHÁ, KHÓA HỌC & TÀI LIỆU ĐÍNH KÈM (COURSES & CONTENT)
-- Use Cases:
--   CRS-001: Thêm khóa học mới (Giảng viên)
--   CRS-002: Tải lên video bài giảng (Giảng viên - Xử lý dung lượng file lớn)
--   CRS-003: Khám phá & Lọc khóa học theo danh mục (Học viên)
--   CRS-005: Upload file PDF/Zip đính kèm bài giảng lưu trên server (Giảng viên)
--   ADM-003: Phê duyệt khóa học trước khi public (Admin)
--   ADM-004: Quản lý banner trang chủ (Admin)
--   LRN-001: Trình phát video bài giảng (Học viên)
-- =============================================================================

CREATE TABLE `danh_muc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh danh mục',
    `ten_danh_muc` VARCHAR(100) NOT NULL COMMENT 'Tên danh mục khóa học (ví dụ: Lập trình web, Ngoại ngữ...)',
    `duong_dan` VARCHAR(120) NOT NULL UNIQUE COMMENT 'Đường dẫn slug thân thiện URL (CRS-003)',
    `bieu_tuong` VARCHAR(500) DEFAULT NULL COMMENT 'Icon hoặc ảnh đại diện danh mục',
    `mo_ta` TEXT DEFAULT NULL COMMENT 'Mô tả tóm tắt nội dung danh mục',
    `ma_danh_muc_cha` BIGINT DEFAULT NULL COMMENT 'Mã danh mục cha nếu phân cấp',
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
    `duong_dan` VARCHAR(300) NOT NULL UNIQUE COMMENT 'Đường dẫn slug thân thiện URL',
    `tieu_de_phu` VARCHAR(500) DEFAULT NULL COMMENT 'Mô tả ngắn gọn / phụ đề khóa học',
    `mo_ta_chi_tiet` LONGTEXT DEFAULT NULL COMMENT 'Nội dung chi tiết khóa học',
    `anh_dai_dien` VARCHAR(500) DEFAULT NULL COMMENT 'Ảnh thumbnail đại diện khóa học',
    `video_gioi_thieu` VARCHAR(500) DEFAULT NULL COMMENT 'Video trailer xem thử',
    `gia_goc` DECIMAL(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Giá gốc khóa học (VND)',
    `gia_khuyen_mai` DECIMAL(12, 2) DEFAULT 0.00 COMMENT 'Giá ưu đãi khuyến mãi',
    `trinh_do` ENUM('CO_BAN', 'TRUNG_CAP', 'NANG_CAO', 'TAT_CA') NOT NULL DEFAULT 'TAT_CA' COMMENT 'Cấp độ học viên phù hợp',
    `ngon_ngu` VARCHAR(50) NOT NULL DEFAULT 'Tiếng Việt' COMMENT 'Ngôn ngữ giảng dạy',
    `trang_thai` ENUM('BAN_NHAP', 'CHO_PHE_DUYET', 'DA_PHE_DUYET', 'TU_CHOI', 'DA_XUAT_BAN', 'LUU_TRU') NOT NULL DEFAULT 'BAN_NHAP' COMMENT 'Trạng thái kiểm duyệt (ADM-003)',
    `ly_do_tu_choi` TEXT DEFAULT NULL COMMENT 'Lý do admin từ chối phê duyệt khóa học (ADM-003)',
    `tong_thoi_luong_giay` INT NOT NULL DEFAULT 0 COMMENT 'Tổng thời lượng toàn bộ video (giây)',
    `tong_so_bai_hoc` INT NOT NULL DEFAULT 0 COMMENT 'Tổng số lượng bài giảng',
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
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tên chương / phần học (CRS-001)',
    `thu_tu_hien_thi` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự hiển thị các chương trong khóa học',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    INDEX `idx_chuong_hoc_khoa` (`ma_khoa_hoc`, `thu_tu_hien_thi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Các chương học của khóa học (CRS-001)';

CREATE TABLE `bai_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh bài học',
    `ma_chuong_hoc` BIGINT NOT NULL COMMENT 'Mã chương học chứa bài này',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tên bài giảng',
    `thu_tu_hien_thi` INT NOT NULL DEFAULT 1 COMMENT 'Thứ tự bài học trong chương',
    `duong_dan_video` VARCHAR(500) DEFAULT NULL COMMENT 'Đường dẫn file video bài giảng (CRS-002, LRN-001)',
    `thoi_luong_video_giay` INT NOT NULL DEFAULT 0 COMMENT 'Thời lượng video bài học tính bằng giây',
    `dung_luong_video_bytes` BIGINT DEFAULT NULL COMMENT 'Dung lượng file video xử lý file lớn (CRS-002)',
    `noi_dung_bai_viet` LONGTEXT DEFAULT NULL COMMENT 'Nội dung tóm tắt hoặc lý thuyết kèm theo bài giảng',
    `cho_phep_xem_thu` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Cho phép xem thử miễn phí',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_chuong_hoc`) REFERENCES `chuong_hoc`(`id`) ON DELETE CASCADE,
    INDEX `idx_bai_hoc_chuong` (`ma_chuong_hoc`, `thu_tu_hien_thi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chi tiết các bài học và video bài giảng (CRS-002, LRN-001)';

CREATE TABLE `tai_lieu_bai_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh tài liệu',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài học đính kèm tài liệu',
    `ten_tai_lieu` VARCHAR(255) NOT NULL COMMENT 'Tên hiển thị của tài liệu (CRS-005)',
    `duong_dan_tep` VARCHAR(500) NOT NULL COMMENT 'Đường dẫn lưu trữ file trên máy chủ (PDF/Zip) (CRS-005)',
    `dung_luong_bytes` BIGINT DEFAULT NULL COMMENT 'Kích thước file tính bằng byte',
    `dinh_dang_tep` VARCHAR(50) DEFAULT NULL COMMENT 'Định dạng file (pdf, zip, rar, docx...)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tài liệu học tập PDF/Zip đính kèm lưu trên server (CRS-005)';

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
-- PHÂN HỆ 3: GIỎ HÀNG, THANH TOÁN VNPAY & DOANH THU (PAYMENTS & ORDERS)
-- Use Cases:
--   PAY-001: Giỏ hàng - Thêm/Xóa khóa học (Học viên)
--   PAY-002: Checkout - Thanh toán qua VNPay Sandbox (Học viên)
--   PAY-003: Xem lịch sử giao dịch (Học viên)
--   ADM-002: Báo cáo doanh thu tháng & thống kê (Admin)
--   TST-001: Automation Test kịch bản Katalon Checkout
-- =============================================================================

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
    `ma_don_hang` VARCHAR(64) NOT NULL UNIQUE COMMENT 'Mã đơn hàng duy nhất (ví dụ: ORD-20260925-1029)',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên đặt mua khóa học (PAY-002)',
    `tong_tien` DECIMAL(12, 2) NOT NULL COMMENT 'Số tiền thanh toán đơn hàng (PAY-002, ADM-002)',
    `trang_thai_don_hang` ENUM('CHO_THANH_TOAN', 'DA_THANH_TOAN', 'DA_HUY', 'THAT_BAI') NOT NULL DEFAULT 'CHO_THANH_TOAN' COMMENT 'Trạng thái đơn hàng',
    `phuong_thuc_thanh_toan` ENUM('VNPAY', 'MIEN_PHI') NOT NULL DEFAULT 'VNPAY' COMMENT 'Cổng thanh toán (VNPay Sandbox PAY-002)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm tạo đơn hàng',
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời điểm cập nhật trạng thái',
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_don_hang_trang_thai` (`trang_thai_don_hang`),
    INDEX `idx_don_hang_hoc_vien` (`ma_hoc_vien`),
    INDEX `idx_don_hang_ngay_tao` (`ngay_tao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Đơn đặt hàng khóa học (PAY-002, ADM-002, TST-001)';

CREATE TABLE `chi_tiet_don_hang` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh chi tiết đơn hàng',
    `ma_don_hang` BIGINT NOT NULL COMMENT 'Mã đơn hàng liên kết',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học được mua',
    `gia_tai_thoi_diem_mua` DECIMAL(12, 2) NOT NULL COMMENT 'Giá bán tại thời điểm lập đơn',
    FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh sách các khóa học trong đơn hàng (PAY-002)';

CREATE TABLE `giao_dich_thanh_toan` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh giao dịch',
    `ma_don_hang` BIGINT NOT NULL COMMENT 'Mã đơn hàng cần thanh toán',
    `cong_thanh_toan` VARCHAR(50) NOT NULL DEFAULT 'VNPAY' COMMENT 'Cổng thanh toán (VNPay Sandbox PAY-002)',
    `ma_giao_dich_tham_chieu` VARCHAR(100) NOT NULL COMMENT 'Mã tham chiếu gửi VNPay (vnp_TxnRef)',
    `ma_giao_dich_gateway` VARCHAR(100) DEFAULT NULL COMMENT 'Mã số giao dịch do VNPay phản hồi (vnp_TransactionNo)',
    `ma_ngan_hang` VARCHAR(50) DEFAULT NULL COMMENT 'Mã ngân hàng học viên chọn thanh toán (NCB, VCB...)',
    `so_tien_giao_dich` DECIMAL(12, 2) NOT NULL COMMENT 'Số tiền thanh toán thực tế',
    `loai_tien_te` VARCHAR(10) NOT NULL DEFAULT 'VND' COMMENT 'Loại tiền tệ giao dịch',
    `trang_thai_giao_dich` ENUM('DANG_XU_LY', 'THANH_CONG', 'THAT_BAI') NOT NULL DEFAULT 'DANG_XU_LY' COMMENT 'Trạng thái kết quả giao dịch',
    `ma_phan_hoi_gateway` VARCHAR(50) DEFAULT NULL COMMENT 'Mã kết quả phản hồi từ VNPay (00 = Thành công)',
    `thoi_gian_thanh_toan` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm thanh toán thành công (PAY-003)',
    `du_lieu_phan_hoi` TEXT DEFAULT NULL COMMENT 'Toàn bộ dữ liệu callback/IPN webhook trả về',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang`(`id`) ON DELETE CASCADE,
    INDEX `idx_giao_dich_tham_chieu` (`ma_giao_dich_tham_chieu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử giao dịch thanh toán VNPay (PAY-002, PAY-003)';

CREATE TABLE `dang_ky_khoa_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh lượt đăng ký',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên sở hữu quyền học',
    `ma_khoa_hoc` BIGINT NOT NULL COMMENT 'Mã khóa học được cấp quyền truy cập',
    `ma_don_hang` BIGINT DEFAULT NULL COMMENT 'Mã đơn hàng kích hoạt (NULL nếu miễn phí)',
    `trang_thai_khoa_hoc` ENUM('DANG_HOC', 'HOAN_THANH', 'BI_KHOA') NOT NULL DEFAULT 'DANG_HOC' COMMENT 'Trạng thái quyền học tập',
    `phan_tram_tien_do` DECIMAL(5, 2) NOT NULL DEFAULT 0.00 COMMENT 'Tiến độ học hoàn thành tổng thể (0.00% - 100.00%)',
    `ngay_dang_ky` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm kích hoạt vào học',
    `ngay_hoan_thanh` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm hoàn thành khóa học',
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_khoa_hoc`) REFERENCES `khoa_hoc`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_don_hang`) REFERENCES `don_hang`(`id`) ON DELETE SET NULL,
    UNIQUE KEY `uk_dang_ky_hoc_vien_khoa` (`ma_hoc_vien`, `ma_khoa_hoc`),
    INDEX `idx_dang_ky_hoc_vien` (`ma_hoc_vien`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Danh sách khóa học học viên đã đăng ký sở hữu (PAY-003, LRN-001)';

-- =============================================================================
-- PHÂN HỆ 4: TIẾN ĐỘ HỌC TẬP (LEARNING PROGRESS)
-- Use Cases:
--   LRN-001: Xem video bài giảng & theo dõi tiến độ học tập (Học viên)
-- =============================================================================

CREATE TABLE `tien_do_bai_hoc` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh tiến độ',
    `ma_hoc_vien` BIGINT NOT NULL COMMENT 'Mã học viên đang học (LRN-001)',
    `ma_bai_hoc` BIGINT NOT NULL COMMENT 'Mã bài học đang theo dõi',
    `da_hoan_thanh` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đã hoàn thành bài học này chưa (LRN-001)',
    `giay_dung_lai_cuoi_cung` INT NOT NULL DEFAULT 0 COMMENT 'Thời điểm giây dừng lại khi xem video (LRN-001)',
    `ngay_hoan_thanh` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm hoàn thành bài học',
    `ngay_cap_nhat` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`ma_hoc_vien`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`ma_bai_hoc`) REFERENCES `bai_hoc`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_tien_do_hoc_vien_bai_hoc` (`ma_hoc_vien`, `ma_bai_hoc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Theo dõi tiến độ xem video bài giảng của học viên (LRN-001)';

-- =============================================================================
-- PHÂN HỆ 5: THÔNG BÁO & NHẬT KÝ EMAIL HỆ THỐNG (NOTIFICATIONS & EMAILS)
-- Use Cases:
--   NOT-001: Gửi email nhắc lịch học / thanh toán / OTP qua SMTP (Hệ thống)
--   NOT-002: In-app Notification - Hiển thị thông báo trên chuông (Hệ thống)
-- =============================================================================

CREATE TABLE `thong_bao` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh thông báo',
    `ma_nguoi_dung` BIGINT NOT NULL COMMENT 'Mã người dùng nhận thông báo (NOT-002)',
    `tieu_de` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề ngắn gọn của thông báo',
    `noi_dung` TEXT NOT NULL COMMENT 'Nội dung chi tiết thông báo hiển thị trên chuông (NOT-002)',
    `loai_thong_bao` VARCHAR(50) NOT NULL DEFAULT 'HE_THONG' COMMENT 'Phân loại: HE_THONG, THANH_TOAN, KHOA_HOC',
    `duong_dan_dieu_huong` VARCHAR(500) DEFAULT NULL COMMENT 'Đường link điều hướng khi click vào thông báo',
    `da_doc` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Đánh dấu đã đọc thông báo hay chưa (NOT-002)',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm phát sinh thông báo',
    FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung`(`id`) ON DELETE CASCADE,
    INDEX `idx_thong_bao_nguoi_dung_da_doc` (`ma_nguoi_dung`, `da_doc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Thông báo in-app hiển thị trên chuông thông báo (NOT-002)';

CREATE TABLE `nhat_ky_email` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Mã định danh nhật ký email',
    `email_nguoi_nhan` VARCHAR(150) NOT NULL COMMENT 'Địa chỉ email người nhận (NOT-001, USR-004)',
    `tieu_de_email` VARCHAR(255) NOT NULL COMMENT 'Tiêu đề email đã gửi',
    `ten_mau_email` VARCHAR(100) DEFAULT NULL COMMENT 'Tên template: nhac_lich_hoc, hoa_don_thanh_toan, quen_mat_khau_otp (NOT-001)',
    `trang_thai_gui` ENUM('CHO_GUI', 'DA_GUI', 'THAT_BAI') NOT NULL DEFAULT 'CHO_GUI' COMMENT 'Trạng thái gửi email qua SMTP',
    `thong_bao_loi` TEXT DEFAULT NULL COMMENT 'Chi tiết lỗi nếu gửi thất bại qua SMTP',
    `thoi_gian_gui` TIMESTAMP NULL DEFAULT NULL COMMENT 'Thời điểm email được gửi thành công',
    `ngay_tao` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_nhat_ky_email_trang_thai` (`trang_thai_gui`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Nhật ký gửi email hệ thống qua SMTP (NOT-001)';

-- =============================================================================
-- DỮ LIỆU KHỞI TẠO MẪU (SEED DATA TIẾNG VIỆT KHỚP 20 USE CASES)
-- Mật khẩu mặc định của các tài khoản mẫu: 123456
-- (Đã băm BCrypt: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi)
-- =============================================================================

-- 1. Tài khoản mẫu: Admin, Giảng viên, Học viên (ADM-001, USR-001, USR-002)
INSERT INTO `nguoi_dung` (`id`, `email`, `mat_khau`, `ho_ten`, `so_dien_thoai`, `vai_tro`, `trang_thai_hoat_dong`, `da_xac_thuc_email`) VALUES
(1, 'admin@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Quản Trị Viên (Admin)', '0901234567', 'ROLE_ADMIN', TRUE, TRUE),
(2, 'giangvien@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Thầy Nguyễn Văn A (Giảng Viên)', '0912345678', 'ROLE_INSTRUCTOR', TRUE, TRUE),
(3, 'hocvien@saas.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Trần Thị B (Học Viên)', '0987654321', 'ROLE_USER', TRUE, TRUE);

-- 2. Danh mục khóa học (CRS-003)
INSERT INTO `danh_muc` (`id`, `ten_danh_muc`, `duong_dan`, `bieu_tuong`, `mo_ta`) VALUES
(1, 'Lập Trình Web Fullstack', 'lap-trinh-web-fullstack', 'https://cdn.iconscout.com/icon/free/png-256/react-1-282599.png', 'Các khóa học phát triển ứng dụng từ Frontend đến Backend'),
(2, 'Trí Tuệ Nhân Tạo & Dữ Liệu', 'tri-tue-nhan-tao-du-lieu', 'https://cdn.iconscout.com/icon/free/png-256/python-3521655-2945099.png', 'Học Python, Machine Learning và phân tích dữ liệu'),
(3, 'Thiết Kế Đồ Họa & UI/UX', 'thiet-ke-do-hoa-ui-ux', 'https://cdn.iconscout.com/icon/free/png-256/figma-3521426-2944870.png', 'Kỹ năng thiết kế giao diện Figma và trải nghiệm người dùng');

-- 3. Khóa học mẫu (CRS-001, ADM-003)
INSERT INTO `khoa_hoc` (`id`, `ma_giang_vien`, `ma_danh_muc`, `tieu_de`, `duong_dan`, `tieu_de_phu`, `mo_ta_chi_tiet`, `anh_dai_dien`, `gia_goc`, `gia_khuyen_mai`, `trinh_do`, `trang_thai`, `tong_thoi_luong_giay`, `tong_so_bai_hoc`) VALUES
(1, 2, 1, 'Lập Trình Spring Boot 4 & Next.js 16 Fullstack Toàn Diện', 'lap-trinh-spring-boot-4-nextjs-16-fullstack', 'Xây dựng ứng dụng E-learning SaaS hoàn chỉnh từ con số 0', '<p>Khóa học thực chiến toàn diện giúp bạn làm chủ kiến trúc Spring Boot và Next.js hiện đại.</p>', 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600', 1200000.00, 799000.00, 'TRUNG_CAP', 'DA_XUAT_BAN', 36000, 3);

-- 4. Chương & Bài học (CRS-001, CRS-002, LRN-001)
INSERT INTO `chuong_hoc` (`id`, `ma_khoa_hoc`, `tieu_de`, `thu_tu_hien_thi`) VALUES
(1, 1, 'Chương 1: Giới thiệu kiến trúc hệ thống và cài đặt môi trường', 1),
(2, 1, 'Chương 2: Xây dựng RESTful API với Spring Boot 4', 2);

INSERT INTO `bai_hoc` (`id`, `ma_chuong_hoc`, `tieu_de`, `thu_tu_hien_thi`, `duong_dan_video`, `thoi_luong_video_giay`, `dung_luong_video_bytes`, `cho_phep_xem_thu`) VALUES
(1, 1, 'Bài 1: Tổng quan dự án E-learning SaaS CDIO', 1, 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 600, 52428800, TRUE),
(2, 1, 'Bài 2: Hướng dẫn cài đặt JDK 17, MySQL và Docker', 2, 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 900, 83886080, FALSE),
(3, 2, 'Bài 3: Xây dựng Entity JPA và Cấu hình Spring Security JWT', 1, 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4', 1200, 104857600, FALSE);

-- 5. Tài liệu đính kèm bài học (CRS-005)
INSERT INTO `tai_lieu_bai_hoc` (`id`, `ma_bai_hoc`, `ten_tai_lieu`, `duong_dan_tep`, `dung_luong_bytes`, `dinh_dang_tep`) VALUES
(1, 1, 'So-do-kien-truc-he-thong.pdf', 'https://storage.example.com/docs/kien-truc.pdf', 2048000, 'pdf'),
(2, 2, 'Source-code-starter-template.zip', 'https://storage.example.com/docs/starter.zip', 15400000, 'zip');

-- 6. Banner trang chủ (ADM-004)
INSERT INTO `banner` (`id`, `tieu_de`, `duong_dan_anh`, `duong_dan_chuyen_huong`, `thu_tu_hien_thi`, `trang_thai_hien_thi`) VALUES
(1, 'Đại tiệc Back to School - Giảm giá Khóa học Fullstack', 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200', '/courses', 1, TRUE),
(2, 'Làm chủ Công Nghệ & Dữ Liệu cùng Chuyên Gia', 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=1200', '/category/tri-tue-nhan-tao-du-lieu', 2, TRUE);

-- 7. Thông báo mẫu (NOT-002)
INSERT INTO `thong_bao` (`id`, `ma_nguoi_dung`, `tieu_de`, `noi_dung`, `loai_thong_bao`, `duong_dan_dieu_huong`, `da_doc`) VALUES
(1, 3, 'Chào mừng đến với hệ thống E-Learning!', 'Cảm ơn bạn đã tham gia nền tảng. Hãy bắt đầu hành trình học tập ngay hôm nay!', 'HE_THONG', '/courses', FALSE);
