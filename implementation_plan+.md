# Mở rộng hệ thống: Lịch học, Phòng học, Tài liệu học tập

Mục tiêu: Bổ sung thêm ba phân hệ chức năng mới vào hệ thống quản lý sinh viên hiện tại, bao gồm:
1. Quản lý phòng học (Classroom)
2. Quản lý lịch học (Schedule)
3. Quản lý tài liệu học tập (Study Material)

## User Review Required

> [!WARNING]
> Cấu hình `spring.jpa.hibernate.ddl-auto=none` hiện tại trong `application.properties` sẽ không tự động tạo các bảng mới. Tôi có thể đổi thành `update` tạm thời để Spring Boot tự tạo schema, hoặc tôi sẽ cung cấp file SQL để bạn chạy thủ công trong SQL Server. Hãy cho tôi biết lựa chọn của bạn.

## Open Questions

> [!NOTE]
> 1. Về "Lịch học", bạn muốn quản lý theo từng buổi học cụ thể (ngày cố định) hay theo lịch học cố định hàng tuần (ví dụ: Thứ 2 ca 1)?
> 2. Về "Tài liệu học tập", ứng dụng chỉ cần lưu trữ **đường dẫn (URL)** (link Drive, Dropbox...) hay bạn muốn cài đặt chức năng **upload file** vật lý trực tiếp lên server Spring Boot?

## Proposed Changes

### Backend: Spring Boot

#### [NEW] `student_management_backend/src/main/java/com/hau/student/entity/Classroom.java`
- Chứa thông tin: `id`, `tenPhong` (Tên phòng), `toaNha` (Tòa nhà), `sucChua` (Sức chứa).

#### [NEW] `student_management_backend/src/main/java/com/hau/student/entity/Schedule.java`
- Chứa thông tin: `id`, quan hệ `@ManyToOne` với `Subject` và `Classroom`, `ngayHoc` (Ngày học), `caHoc` (Ca học), `giangVien` (Giảng viên).

#### [NEW] `student_management_backend/src/main/java/com/hau/student/entity/StudyMaterial.java`
- Chứa thông tin: `id`, quan hệ `@ManyToOne` với `Subject`, `tenTaiLieu` (Tên tài liệu), `loaiTaiLieu` (Loại tài liệu), `duongDan` (URL/Path), `ngayTaiLen` (Ngày tải lên).

#### [NEW] Repositories & Services
- Thêm các interface Repository (`ClassroomRepository`, `ScheduleRepository`, `StudyMaterialRepository`).
- Thêm Service (interface và implementation) tương ứng để xử lý logic.

#### [NEW] Controllers
- `AdminClassroomController`, `AdminScheduleController`, `AdminStudyMaterialController` trong thư mục `admin` để cung cấp API thêm/sửa/xóa.
- `ScheduleController`, `StudyMaterialController` cho sinh viên lấy danh sách (chỉ xem).

---

### Frontend: Flutter App

#### [NEW] Models
- `lib/models/classroom_model.dart`
- `lib/models/schedule_model.dart`
- `lib/models/study_material_model.dart`

#### [MODIFY] Services
- Cập nhật `lib/services/admin_api_service.dart` và `lib/services/student_service.dart` bổ sung các API calls tương ứng.

#### [NEW] Screens (Giao diện)
- Thêm các màn hình Quản lý trong `lib/screens/admin/` (ví dụ: `classroom_management_screen.dart`, `schedule_management_screen.dart`, `material_management_screen.dart`).
- Cập nhật chi tiết môn học của sinh viên `lib/screens/subject_detail_screen.dart` để hiển thị **Tài liệu** và **Lịch học** của môn đó.

## Verification Plan

### Automated Tests
- Kiểm tra tính toàn vẹn của DTO và Controller bằng cách gọi API thông qua Swagger/curl nội bộ.

### Manual Verification
- Deploy backend và frontend locally.
- Đăng nhập quyền Admin: Test CRUD (Tạo phòng học -> Gán lịch học cho môn -> Thêm tài liệu).
- Đăng nhập quyền Sinh viên: Truy cập môn học để xác nhận lịch học, phòng học và tài liệu được hiển thị đầy đủ và có thiết kế hiện đại, đồng bộ.
