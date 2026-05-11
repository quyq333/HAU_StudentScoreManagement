# HAU Student Management - Backend

Đây là phần Backend API cho ứng dụng Quản lý Sinh Viên trường HAU, được xây dựng bằng **Spring Boot 3** và **Java 17**.

## 🛠 Yêu cầu hệ thống (Prerequisites)
- **Java Development Kit (JDK) 17** trở lên.
- **Apache Maven**.
- **Microsoft SQL Server** (Bật TCP/IP và cấu hình cổng 1433).

## 🗄️ Cấu hình Database
1. Mở SQL Server Management Studio (SSMS).
2. Đảm bảo bạn đã có một Database tên là: `HAU_StudentManagement`.
3. Kiểm tra thông tin đăng nhập SQL Server trong file `src/main/resources/application.properties`:
   - `spring.datasource.url`: jdbc:sqlserver://localhost:1433;databaseName=HAU_StudentManagement;encrypt=true;trustServerCertificate=true
   - `spring.datasource.username`: sa (tài khoản mặc định)
   - `spring.datasource.password`: quy28102004 (hoặc thay bằng mật khẩu SQL Server của bạn)
4. Chế độ Hibernate DDL Auto đang được set là `update`, do đó các bảng (VD: bảng `SinhVien`) sẽ tự động được tạo khi chạy server lần đầu tiên.

## 🚀 Cách chạy Backend
Bạn có thể khởi chạy server bằng Command Line / Terminal tại thư mục `student_management_backend`:

```bash
mvn clean spring-boot:run
```
*(Hoặc bạn có thể mở thư mục này bằng IntelliJ IDEA / Eclipse và ấn nút Run ở class Application)*

Sau khi chạy thành công, Server sẽ hoạt động ở cổng: `http://localhost:8080`

## 🔐 Xác thực & Đăng nhập
- API sử dụng **JWT (JSON Web Token)** để bảo mật.
- Để Test tính năng đăng nhập trên Mobile, bạn cần đảm bảo trong bảng `SinhVien` của database `HAU_StudentManagement` đã có ít nhất một bản ghi. 
- Mật khẩu hiện đang lưu ở dạng Plaintext (Văn bản thuần túy) nên lúc insert dữ liệu bạn cứ nhập mật khẩu bình thường (VD: `123456`).

## 📚 Các API Endpoints Chính
| Method | Endpoint | Mô tả | Yêu cầu Token |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/v1/auth/login` | Đăng nhập hệ thống bằng Mã SV và Mật khẩu | ❌ Không |
| **GET** | `/api/v1/student/profile` | Lấy thông tin hồ sơ của sinh viên | ✅ Có |
| **GET** | `/api/v1/semesters` | Lấy danh sách kỳ học | ✅ Có |
| **GET** | `/api/v1/results` | Lấy kết quả học tập | ✅ Có |
| **GET** | `/api/v1/results/gpa` | Lấy điểm trung bình tích lũy (GPA) | ✅ Có |
| **GET** | `/api/v1/results/failed` | Lấy danh sách các môn thi trượt | ✅ Có |

> **Note:** Backend đã được mở cấu hình CORS để cho phép App Flutter (và cả Web) có thể gọi chéo được API một cách mượt mà.
