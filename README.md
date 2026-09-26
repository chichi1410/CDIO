# SaaS Starter Platform (Spring Boot 4 + Next.js 16)

Dự án mẫu full-stack doanh nghiệp kết hợp **Spring Boot 4.1.0** (Backend REST API + Security JWT OAuth2 RSA) và **Next.js 16** (Frontend App Router + React 19 + Tailwind v4).

---

## 🏗️ Cấu Trúc Dự Án

```text
SAAS/
├── backend/                  # Spring Boot 4.1.0 (Java 17)
│   ├── src/main/java/        # Mã nguồn Java (Controllers, Services, Security, Errors)
│   ├── src/main/resources/   # application.properties & certs/ (RSA private/public keys)
│   └── build.gradle.kts      # Gradle Kotlin DSL dependencies & static analysis
├── frontend/                 # Next.js 16 (React 19 + Tailwind v4)
│   ├── app/                  # Next.js App Router (Landing, Auth, Dashboard)
│   ├── features/             # Feature-driven modules (Auth form, validation schemas)
│   ├── apis/                 # Axios client API calls
│   ├── services/             # Axios instance & Interceptors
│   ├── components/ui/        # Reusable UI primitives (Button, Input, Card)
│   └── .env.local            # NEXT_PUBLIC_API_URL=http://localhost:8080
└── scaffold_new_project_plan.md
```

---

## 🚀 Hướng Dẫn Chạy Dự Án Từng Bước

### 1. Yêu Cầu Tiền Đề (Prerequisites)
- **Java**: OpenJDK 17 trở lên.
- **Node.js**: Node 20+ và `npm` hoặc `pnpm`.
- **MySQL**: MySQL 8.0+ đang chạy ở `localhost:3306` (Tạo database `saas_new_db`).

### 2. Khởi Động Backend (Spring Boot 4)

```bash
cd backend

# Chạy static analysis & unit tests
./gradlew check

# Khởi chạy ứng dụng Spring Boot (Cổng 8080)
./gradlew bootRun
```

> **Lưu ý về Cặp Khóa RSA**: Cặp khóa RSA256 JWT đã được tạo sẵn tại `backend/src/main/resources/certs/private.pem` và `public.pem`.

### 3. Khởi Động Frontend (Next.js 16)

```bash
cd frontend

# Cài đặt dependencies (nếu chưa cài)
npm install

# Kiểm tra lint & typecheck
npm run build

# Khởi chạy server phát triển (Cổng 3000)
npm run dev
```


## ⚙️ Biến Môi Trường

- **Frontend (`frontend/.env.local`)**:
  ```env
  NEXT_PUBLIC_API_URL=http://localhost:8080
  ```

- **Backend (`backend/src/main/resources/application.properties`)**:
  ```properties
  AUTH_ALLOWED_ORIGINS=http://localhost:3000
  spring.datasource.url=jdbc:mysql://localhost:3306/saas_new_db
  ```
