# Hướng dẫn Kiểm thử: Tính năng CRUD Phòng học và Lịch học cho Admin

Chúng ta đã hoàn thiện toàn bộ các chức năng Thêm, Sửa, Xóa phòng học và lịch học trực tiếp từ giao diện Admin của ứng dụng Flutter. Dưới đây là các thay đổi chi tiết và cách kiểm thử.

---

## Các thay đổi đã thực hiện

### 1. Giao diện Phòng học (`lib/screens/admin/manage_classrooms_screen.dart`)
- **Danh sách**: Đã bổ sung các biểu tượng Edit (Bút chì màu xanh) và Delete (Thùng rác màu đỏ) vào phần `trailing` của mỗi Card phòng học.
- **Thêm/Sửa phòng học**:
  - Khi nhấn nút (+) hoặc nút Edit, một Dialog hiện đại sẽ xuất hiện để nhập dữ liệu.
  - Form hỗ trợ:
    - **Tên phòng** (Ví dụ: `Phong 302`)
    - **Tòa nhà** (Ví dụ: `Nhà U1`)
    - **Sức chứa** (Số nguyên, ví dụ: `50`)
    - **Loại phòng** (Dropdown chọn: `Phòng lý thuyết`, `Phòng thực hành`, `Hội trường`)
  - Kết nối API `createClassroom` và `updateClassroom` từ `AdminApiService`.
- **Xóa phòng học**:
  - Nhấn nút Delete sẽ hiện một AlertDialog xác nhận xóa. Đồng ý sẽ gọi API `deleteClassroom`.

### 2. Giao diện Lịch học (`lib/screens/admin/manage_schedules_screen.dart`)
- **Tải dữ liệu liên kết**: Khi vào trang lịch học, ứng dụng tự động tải song song 3 API: Danh sách lịch học (`getSchedules()`), danh sách phòng học (`getClassrooms()`) và danh sách môn học (`getSubjects()`).
- **Danh sách**: Hiển thị chi tiết Thứ, Ca học, Giảng viên, Môn học và thông tin Phòng học (Tên phòng & Toà nhà). Có đầy đủ 2 nút Edit & Delete.
- **Thêm/Sửa lịch học**:
  - Mở Dialog nhập liệu dạng Dropdown/Form:
    - **Môn học**: Dropdown chọn môn học (lấy từ dữ liệu thực tế của hệ thống).
    - **Phòng học**: Dropdown chọn phòng học (lấy từ danh sách phòng thực tế).
    - **Thứ**: Dropdown chọn từ Thứ 2 đến Chủ nhật.
    - **Ca học**: Dropdown chọn Ca 1 đến Ca 6.
    - **Giảng viên**: Ô nhập văn bản tên giảng viên.
  - Kết nối API `createSchedule` và `updateSchedule` tương ứng.
- **Xóa lịch học**:
  - Có Dialog xác nhận xóa lịch học trước khi thực hiện gọi API `deleteSchedule`.

---

## Hướng dẫn Xác minh (Verification)

1. **Khởi chạy ứng dụng Flutter**.
2. **Đăng nhập** bằng tài khoản Admin.
3. **Quản lý Phòng học**:
   - Nhấp vào mục **Phòng học**.
   - Nhấn nút (+) ở góc dưới bên phải, nhập thông tin: Phòng: `P501`, Toà: `Nhà A`, Sức chứa: `80`, chọn `Hội trường`, nhấn **Lưu**.
   - Xác nhận phòng học mới xuất hiện trong danh sách.
   - Nhấp vào biểu tượng sửa (Edit) của phòng `P501`, đổi sức chứa thành `100`, nhấn **Lưu**. Xác nhận dữ liệu được cập nhật.
   - Nhấp vào biểu tượng xóa (Delete) của phòng `P501`, chọn **Xóa**. Phòng sẽ biến mất khỏi danh sách.
4. **Quản lý Lịch học**:
   - Nhấp vào mục **Lịch học**.
   - Nhấn nút (+) ở góc dưới bên phải.
   - Chọn một **Môn học**, một **Phòng học** từ danh sách thả xuống.
   - Chọn Thứ: `Thứ 3`, Ca học: `Ca 2`.
   - Nhập tên giảng viên: `Nguyễn Văn A`.
   - Nhấn **Lưu** và xác nhận lịch học mới hiển thị đầy đủ thông tin giảng viên, môn học, phòng học.
   - Nhấp vào biểu tượng sửa (Edit) của lịch học đó để đổi tên giảng viên thành `Trần Thị B`. Nhấn **Lưu** và kiểm tra kết quả.
   - Nhấp biểu tượng xóa (Delete), chọn **Xóa** để xóa lịch học này khỏi hệ thống.
