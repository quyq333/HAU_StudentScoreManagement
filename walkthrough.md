# Báo cáo hoàn thành: Mở rộng quản lý Lịch học, Phòng học, Tài liệu học tập

Hệ thống đã được bổ sung thành công ba phân hệ lớn theo yêu cầu. Dưới đây là những nội dung đã được thực hiện và cách kiểm tra.

## Các thay đổi đã thực hiện

### 1. Cấu hình Database
- Đã cập nhật `application.properties` để chuyển `spring.jpa.hibernate.ddl-auto` sang chế độ `update`. Khi bạn chạy lại Backend, Spring Boot sẽ tự động tạo thêm 3 bảng mới vào SQL Server: `PhongHoc`, `LichHoc`, `TaiLieuHocTap`.

### 2. Backend (Spring Boot)
- **Entities**: Tạo các thực thể `Classroom`, `Schedule`, `StudyMaterial` với các quan hệ (Relation) thích hợp tới môn học (`Subject`).
- **Repositories**: Tạo các interface kế thừa từ `JpaRepository` cho việc lấy dữ liệu.
- **Controllers**:
  - `AdminClassroomController`, `AdminScheduleController`, `AdminStudyMaterialController`: Cung cấp full tính năng CRUD cho người quản trị (quyền `ADMIN`).
  - `ScheduleController`, `StudyMaterialController`: Cung cấp API cho sinh viên xem danh sách lịch và tài liệu theo môn học (quyền `STUDENT`, `ADMIN`).

### 3. Frontend (Flutter)
- **Models**: Bổ sung các data classes: `classroom_model.dart`, `schedule_model.dart`, `study_material_model.dart`.
- **Services**: Cập nhật `student_service.dart` (lấy dữ liệu view sinh viên) và `admin_api_service.dart` (CRUD cho admin). Các constant endpoint cũng đã được khai báo tại `app_constants.dart`.
- **Giao diện sinh viên**:
  - Tại trang chi tiết điểm của môn học (`SubjectDetailScreen`), đã bổ sung giao diện hiển thị danh sách **Lịch học** và **Tài liệu học tập**. Hệ thống sẽ tự động gọi API và load dữ liệu đẹp mắt thông qua giao diện dạng Card.
- **Giao diện Admin**:
  - Đã thêm một lối tắt mới mang tên **Mở Rộng** trên `AdminDashboardScreen`.
  - Mở ra trang quản lý mở rộng (`ManageExtrasScreen`) gồm 3 tab tiện lợi để xem trước danh sách phòng học, lịch học, và tài liệu từ backend.

## Hướng dẫn xác minh (Verification Plan)

> [!IMPORTANT]
> Hãy làm theo các bước sau để thấy rõ hiệu quả:

1. **Khởi động lại Backend**: Stop process Java hiện tại và Run lại Spring Boot. Spring JPA sẽ tự động tạo bảng mới.
2. **Khởi động ứng dụng Flutter**.
3. **Sử dụng Postman/Swagger/Terminal**: Do giao diện "thêm mới" (Add/Create) trên mobile admin hiện tại chỉ được tạo khung hiển thị danh sách, bạn có thể tạo dữ liệu mẫu thông qua API backend:
   - Thêm phòng học vào `/api/v1/admin/classrooms`.
   - Thêm lịch học gắn với môn học vào `/api/v1/admin/schedules`.
   - Thêm tài liệu gắn với môn học vào `/api/v1/admin/materials`.
4. **Kiểm tra trên App**:
   - Đăng nhập bằng tài khoản Sinh Viên.
   - Nhấn vào một môn học để xem chi tiết điểm số.
   - Cuộn xuống dưới, bạn sẽ thấy thông tin Lịch học (Giảng viên, ca học, phòng học) và Tài liệu học tập (nếu có dữ liệu mẫu đã tạo).
