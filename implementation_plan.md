# Kế hoạch Triển khai Backend Spring Boot

Mục tiêu: Xây dựng Backend REST API cho hệ thống `HAU_StudentManagement` bằng Spring Boot 3 và kết nối với cơ sở dữ liệu SQL Server của bạn.

> [!IMPORTANT]
> **Xác nhận từ người dùng (User Review Required)**
> Tôi sẽ tạo một thư mục dự án mới tên là `student_management_backend` nằm ngang hàng với thư mục `flutter_mobile_application` hiện tại của bạn (`C:\Users\Admin\OneDrive\Desktop\Mobile2\student_management_backend`). Bạn có đồng ý với vị trí này không?

## Thông tin Cấu hình (Đã ghi nhận)
- **Database:** `HAU_StudentManagement`
- **Tài khoản:** `sa`
- **Mật khẩu:** `quy28102004`
- **Port:** `1433` (Mặc định SQL Server)

## Các bước triển khai (Proposed Changes)

### 1. Khởi tạo Dự án Maven
Tôi sẽ tạo cấu trúc thư mục chuẩn của Spring Boot và tệp `pom.xml` chứa các thư viện:
- `spring-boot-starter-web` (REST API)
- `spring-boot-starter-data-jpa` (ORM)
- `spring-boot-starter-security` (Bảo mật)
- `mssql-jdbc` (Driver kết nối SQL Server)
- `jjwt-api`, `jjwt-impl`, `jjwt-jackson` (Xử lý JWT Token)
- `lombok` (Giảm boilerplate code)

### 2. Cấu hình Cơ sở dữ liệu
#### [NEW] `src/main/resources/application.properties`
Cấu hình chuỗi kết nối (Connection String) sử dụng thông tin tài khoản `sa` và mật khẩu bạn vừa cung cấp.

### 3. Xây dựng Các Tầng Ứng dụng (Layers)

- **Tầng Entity (`entity/`)**: Tạo các class Java ánh xạ trực tiếp với bảng `SinhVien`, `MonHoc`, `HocKy`, `KetQuaHocTap` trong SQL Server.
- **Tầng Repository (`repository/`)**: Tạo các interface kế thừa `JpaRepository` để thực hiện truy vấn CSDL.
- **Tầng Security (`security/`)**: Viết logic mã hóa mật khẩu bằng BCrypt, cấu hình bộ lọc JWT (`JwtAuthenticationFilter`) và lớp cấp phát Token (`JwtTokenProvider`).
- **Tầng Service (`service/`)**: Triển khai các logic nghiệp vụ như tính điểm GPA, thống kê tín chỉ, xác thực đăng nhập.
- **Tầng Controller (`controller/`)**: Mở các API endpoint (VD: `/api/v1/auth/login`, `/api/v1/results/gpa`) để App Flutter có thể gọi đến.

## Verification Plan
1. Viết toàn bộ mã nguồn.
2. Dùng lệnh `mvn clean install` để tải thư viện và biên dịch.
3. Hướng dẫn bạn chạy Backend (`mvn spring-boot:run`).
4. (Tuỳ chọn) Chạy lại App Flutter để kiểm tra kết nối Login thành công với tài khoản sinh viên thật trong máy bạn (`2255010178`).

Vui lòng bấm **Approve** (Duyệt) hoặc trả lời xác nhận để tôi bắt đầu tạo mã nguồn ngay lập tức!
