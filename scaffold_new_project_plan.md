# Kế Hoạch Triển Khai Dự Án Mới Từng Bước (Atomic Scaffold Plan)

Kế hoạch này chia nhỏ toàn bộ quá trình tạo project mới dựa trên stack hiện tại (`Spring Boot 4.1.0 + Java 17` và `Next.js 16 + React 19 + Tailwind CSS 4`) thành các bước nguyên tử, có thể thực hiện và kiểm thử độc lập.

---

## Giai đoạn 1: Chuẩn bị & Xác định thông tin dự án mới

- [x] **Bước 1.1: Xác định thông tin cơ bản của dự án mới**
  - Tên dự án mới (ví dụ: `my-new-saas` hoặc theo nhu cầu của bạn).
  - Vị trí thư mục đặt code (cùng cấp với thư mục hiện tại hoặc thư mục chỉ định).
  - Tên Database MySQL mới (ví dụ: `saas_new_db`).
- [x] **Bước 1.2: Tạo cấu trúc thư mục gốc**
  ```text
  <ten-project-moi>/
  ├── backend/     (Spring Boot Application)
  └── frontend/    (Next.js Application)
  ```

---

## Giai đoạn 2: Xây dựng Backend từ gốc (Spring Boot 4.1.0)

- [x] **Bước 2.1: Khởi tạo khung Gradle Kotlin DSL**
  - Tạo `backend/build.gradle.kts` và `backend/settings.gradle.kts`.
  - Khai báo plugin: `org.springframework.boot:4.1.0`, `io.freefair.lombok:8.6`, `checkstyle`, `spotbugs`.
  - Thiết lập Java Toolchain: Java 17.
  - Thêm các dependency cốt lõi: Web, Validation, Security, OAuth2 Resource Server, Data JPA, MySQL Connector, Turkraft SpringFilter, Test & H2.
  - Tạo Gradle wrapper (`gradlew`, `gradlew.bat`, `gradle/wrapper/`).
- [x] **Bước 2.2: Cấu hình chất lượng code (Code Quality)**
  - Sao chép / tạo file `backend/checkstyle.xml` (chuẩn Google / dự án hiện tại).
  - Thiết lập SpotBugs cấu hình HTML report và mức phạt `Effort.MAX`.
- [x] **Bước 2.3: Thiết lập cấu hình ứng dụng (`application.properties`)**
  - Khai báo DataSource kết nối MySQL (URL, username, password).
  - Cấu hình JPA: `spring.jpa.hibernate.ddl-auto=update`, `show-sql=true`.
  - Giới hạn upload file: `spring.servlet.multipart.max-file-size=100MB`.
  - Khai báo đường dẫn cặp khóa RSA: `jwt.private-key` và `jwt.public-key`.
- [x] **Bước 2.4: Tạo cặp khóa RSA cho JWT Authentication**
  - Sinh 2 file: `backend/src/main/resources/certs/private.pem` và `backend/src/main/resources/certs/public.pem`.
- [x] **Bước 2.5: Xây dựng tầng Cấu hình chung (Config Layer)**
  - `WebConfiguration.java`: Tự động thêm prefix `/api/v1` cho toàn bộ `@RestController`.
  - `CorsConfig.java`: Cho phép Next.js frontend truy cập (origin: `http://localhost:3000`).
  - `SecurityConfiguration.java`: Cấu hình stateless session, tắt CSRF cho REST API, xác thực Bearer Token qua RSA Decoder, phân quyền public/private routes.
- [x] **Bước 2.6: Xây dựng tầng Xử lý lỗi toàn cục (Global Error Handling)**
  - `RestException.java` & mã lỗi `ErrorCode` enum.
  - `ApiErrorResponse.java`: Chuẩn hóa JSON trả về khi có lỗi (`timestamp`, `status`, `message`, `errors`).
  - `GlobalExceptionHandler.java`: Bắt `@ExceptionHandler` cho Validation (`MethodArgumentNotValidException`), Auth error, và Unhandled exceptions.
- [x] **Bước 2.7: Module Auth & User tối thiểu (Core Module)**
  - Entity: `User.java`, `Role.java`.
  - Repository: `UserRepository.java`.
  - DTO: `LoginRequest`, `RegisterRequest`, `UserResponse`, `TokenResponse`.
  - Service: `AuthService` (mã hóa mật khẩu bằng BCrypt, phát sinh JWT với Claims).
  - Controller: `AuthController` (`POST /api/v1/auth/login`, `POST /api/v1/auth/register`, `GET /api/v1/auth/me`).
- [x] **Bước 2.8: Kiểm thử Backend độc lập**
  - Chạy `gradlew.bat check` và `gradlew.bat test`.
  - Khởi động app bằng `gradlew.bat bootRun`, test gọi API login/register qua cURL hoặc Postman.

---

## Giai đoạn 3: Xây dựng Frontend từ gốc (Next.js 16 + React 19)

- [ ] **Bước 3.1: Khởi tạo dự án Next.js 16**
  - Chạy lệnh khởi tạo Next.js với TypeScript, App Router, ESLint, alias `@/*`.
- [ ] **Bước 3.2: Cài đặt Tailwind CSS v4 & Styling Utilities**
  - Cài đặt `@tailwindcss/postcss` và `tailwindcss`.
  - Thiết lập `globals.css` theo chuẩn Tailwind 4 `@theme`.
  - Cài đặt `clsx`, `tailwind-merge`, `class-variance-authority`.
  - Tạo file `lib/utils.ts` chứa hàm `cn(...)`.
- [ ] **Bước 3.3: Cài đặt bộ thư viện nòng cốt**
  - Data Fetching: `@tanstack/react-query`, `axios`.
  - Form & Validation: `react-hook-form`, `zod`, `@hookform/resolvers`.
  - UI & Icons: `lucide-react`, `@base-ui/react`, `@shadcn/react`, `sonner`, `motion`.
- [ ] **Bước 3.4: Thiết lập cấu trúc thư mục chuẩn (Feature-Driven Architecture)**
  - Tạo các thư mục: `app/`, `features/`, `components/ui/`, `components/common/`, `components/provider/`, `apis/`, `services/`, `hooks/`, `types/`, `lib/`.
- [ ] **Bước 3.5: Cấu hình HTTP Client & Providers**
  - `services/api-client.ts`: Tạo Axios instance cấu hình `baseURL: process.env.NEXT_PUBLIC_API_URL + '/api/v1'`, interceptor tự động inject Bearer token từ cookie/localStorage và xử lý refresh/401.
  - `components/provider/query-provider.tsx`: Bọc `QueryClientProvider` cho toàn app.
  - Thêm `<Toaster />` của `sonner` vào root `layout.tsx`.
- [ ] **Bước 3.6: Tạo bộ UI Primitives cơ bản (`components/ui/`)**
  - `button.tsx`: Nút bấm đa variant (primary, outline, ghost, loading state).
  - `input.tsx`: Input field hỗ trợ hiển thị lỗi validation.
  - `card.tsx`: Khung card hiển thị nội dung.
- [ ] **Bước 3.7: Xây dựng Feature Auth mẫu (`features/auth/`)**
  - `apis/auth.api.ts`: Hàm gọi `login`, `register`, `getMe`.
  - `features/auth/types.ts`: Zod schema cho Login/Register form.
  - `features/auth/components/login-form.tsx`: Form đăng nhập với validation và trạng thái loading.
  - `app/(auth)/login/page.tsx`: Trang đăng nhập.
- [ ] **Bước 3.8: Kiểm thử Frontend độc lập**
  - Chạy `pnpm lint` và `pnpm build` để xác nhận không có lỗi TypeScript hay cú pháp.
  - Chạy `pnpm dev` và truy cập giao diện thử nghiệm.

---

## Giai đoạn 4: Tích hợp Cross-Stack & Hoàn thiện Boilerplate

- [ ] **Bước 4.1: Cấu hình biến môi trường kết nối**
  - Tạo file `.env` cho backend và `.env.local` cho frontend (`NEXT_PUBLIC_API_URL=http://localhost:8080`).
- [ ] **Bước 4.2: Kiểm thử luồng Full-stack End-to-End**
  - Người dùng đăng ký tài khoản mới trên giao diện Frontend -> Backend lưu vào MySQL.
  - Đăng nhập -> Nhận JWT Token -> Lưu token và chuyển hướng tới Dashboard.
  - Gọi API `/api/v1/auth/me` để hiển thị thông tin người dùng đang đăng nhập.
- [ ] **Bước 4.3: Viết tài liệu README hướng dẫn chạy dự án mới**
  - Hướng dẫn clone, cấu hình database, sinh key RSA, chạy backend và chạy frontend.
