# TỔNG HỢP CÁC CHỨC NĂNG CỦA DỰ ÁN HAU STUDENT MANAGEMENT

Dự án **HAU Student Management** là một hệ thống quản lý học tập toàn diện dành cho sinh viên trường Đại học Kiến trúc Hà Nội (HAU), kết hợp giữa ứng dụng di động **Flutter (Frontend)** hiện đại và hệ thống API **Spring Boot 3 (Backend)** hiệu năng cao sử dụng cơ sở dữ liệu **Microsoft SQL Server**.

Dưới đây là tài liệu tổng hợp toàn bộ các chức năng đã phát triển trong hệ thống, phân chia chi tiết theo vai trò của người dùng (Sinh viên và Quản trị viên).

---

## 🛠️ CÔNG NGHỆ ÁP DỤNG
*   **Frontend (Mobile App)**: Flutter (Dart), Flutter Providers (quản lý trạng thái), FL Charts (biểu đồ), Dio (gửi HTTP request), Url Launcher (mở tài liệu).
*   **Backend (RESTful API)**: Java 17, Spring Boot 3, Spring Security & JWT Token (bảo mật), Spring Data JPA, Hibernate.
*   **Cơ sở dữ liệu**: Microsoft SQL Server.

---

## 🔐 1. HỆ THỐNG XÁC THỰC & BẢO MẬT (AUTHENTICATION)
*   **Đăng nhập bảo mật**: Sử dụng tài khoản (Mã sinh viên/Admin) và mật khẩu, xác thực qua cơ chế JWT (JSON Web Token).
*   **Phân quyền chặt chẽ (Role-based Authorization)**: Phân quyền cụ thể giữa hai nhóm quyền `STUDENT` và `ADMIN` cho từng API endpoint của Backend và giao diện tương ứng trên ứng dụng di động.
*   **Lưu phiên đăng nhập**: Sử dụng `SharedPreferences` ở thiết bị di động để lưu trữ an toàn JWT Token và thông tin người dùng, tự động đăng nhập ở các lần khởi động tiếp theo.

---

## 🎓 2. PHÂN HỆ DÀNH CHO SINH VIÊN (STUDENT PORTAL)

### 📊 2.1. Trang chủ & Tổng quan học tập (GPA Dashboard)
*   **Thống kê tổng quan**: Hiển thị nhanh Điểm trung bình tích lũy (GPA) và tổng số tín chỉ đã hoàn thành.
*   **Biểu đồ GPA các kỳ**: Biểu đồ đường (`FL Chart`) trực quan hóa quá trình tăng/giảm điểm GPA qua từng học kỳ học tập tại trường.
*   **Lối tắt nhanh**: Điều hướng nhanh tới các phần Lịch học, Lịch thi, Tài liệu học tập và Đăng ký lịch học.
*   **Cảnh báo học tập**: Phát hiện và hiển thị hộp thoại cảnh báo kèm lối tắt danh sách các môn chưa đạt (F) để sinh viên chủ động đăng ký học lại.

### 👤 2.2. Hồ sơ cá nhân (Profile Screen)
*   Hiển thị chi tiết hồ sơ sinh viên: Mã sinh viên, họ tên, giới tính, ngày sinh, lớp, chuyên ngành, khoa, khóa học và trạng thái học tập.

### 📝 2.3. Xem Điểm & Kết quả học tập
*   **Xem điểm theo kỳ**: Hiển thị danh sách học kỳ sinh viên đã học. Bấm vào học kỳ sẽ liệt kê toàn bộ các môn học tương ứng.
*   **Bảng điểm thành phần chi tiết**: Khi bấm chọn từng môn, sinh viên sẽ xem được:
    *   Điểm chuyên cần.
    *   Điểm giữa kỳ (điểm kiểm tra).
    *   Điểm cuối kỳ (điểm thi).
    *   Điểm tổng kết (hệ 10 và hệ 4).
    *   Điểm chữ tương ứng (A, B+, B, C+, C, D+, D, F).
*   **Trạng thái môn học**: Đánh giá trực quan trạng thái "Đạt" hoặc "Chưa đạt (Cần học lại)" bằng màu sắc sinh động (Xanh/Đỏ).

### 📅 2.4. Thời khóa biểu & Đăng ký Lịch học
*   **Thời khóa biểu cá nhân**: Hiển thị thời khóa biểu dạng danh sách theo tuần bao gồm ca học, thứ trong tuần, thời gian bắt đầu/kết thúc, phòng học và giảng viên phụ trách.
*   **Đăng ký Lịch học**: Giao diện đăng ký các lớp học đang mở trong kỳ học. Cho phép sinh viên đăng ký môn học mới hoặc hủy đăng ký trực tiếp trên ứng dụng.

### ✍️ 2.5. Xem Lịch Thi
*   Hiển thị danh sách lịch thi cá nhân chi tiết (môn thi, ngày thi, ca thi, phòng thi).
*   *Lưu ý*: Chỉ những môn học sinh viên đã đăng ký và được Admin phê duyệt đủ điều kiện dự thi mới hiển thị lịch thi tại đây.

### 📚 2.6. Tài liệu học tập theo môn học
*   **Danh sách môn học**: Liệt kê các môn học sinh viên đang học hoặc đã hoàn thành. Mỗi môn học hiển thị kèm huy hiệu (Badge) số lượng tài liệu đang có (ví dụ: `3 tài liệu` hoặc `Trống`).
*   **Danh sách tài liệu**: Khi nhấn chọn môn học, ứng dụng hiển thị tất cả tài liệu của môn học đó:
    *   Phân loại trực quan: PDF, DOCX (Word), Video bài giảng, hoặc Link ngoài.
    *   Xem nhanh ngày đăng tải.
    *   Hỗ trợ bấm để mở liên kết tài liệu trực tiếp trên trình duyệt hoặc ứng dụng đọc file của điện thoại.

---

## 🛠️ 3. PHÂN HỆ DÀNH CHO QUẢN TRỊ VIÊN (ADMIN PANEL)

Admin Dashboard cho phép quản lý toàn diện cơ sở dữ liệu của trường học thông qua các chức năng CRUD chuyên nghiệp:

### 👥 3.1. Quản lý Sinh viên (Student Management)
*   Quản lý danh sách sinh viên toàn trường.
*   Thêm mới sinh viên, chỉnh sửa thông tin lớp, khoa, ngành học, cập nhật mật khẩu hoặc xóa tài khoản sinh viên.

### 📖 3.2. Quản lý Môn học & Học kỳ
*   **Quản lý Môn học**: Thiết lập danh sách môn học trong chương trình đào tạo của trường kèm theo mã môn học và số tín chỉ của từng môn.
*   **Quản lý Học kỳ**: Tạo lập học kỳ mới (ví dụ: Học kỳ 1, năm học 2026-2027) phục vụ phân công lịch học và lịch thi.

### 🏫 3.3. Quản lý Phòng học & Giảng viên
*   **Quản lý Phòng học**: Quản lý cơ sở vật chất (danh sách phòng học, số lượng chỗ ngồi, trang thiết bị).
*   **Quản lý Giảng viên**: Quản lý thông tin giảng viên (Họ tên, mã giảng viên, chuyên khoa giảng dạy).

### 📅 3.4. Quản lý Lịch học & Thời khóa biểu
*   Lập thời khóa biểu giảng dạy cho các môn học (gán phòng học, thứ học, ca học, ngày bắt đầu và ngày kết thúc).
*   Giao diện phê duyệt (Confirm / Unconfirm) lịch học. Chỉ những lịch học được Admin duyệt thì sinh viên mới có quyền xem và đăng ký trên Mobile.

### ✍️ 3.5. Quản lý Điểm số & Ràng buộc Nhập điểm
*   Tìm kiếm và nhập điểm chuyên cần, giữa kỳ, thi cuối kỳ cho sinh viên theo từng môn học.
*   **RÀNG BUỘC NGHIỆP VỤ ĐÀO TẠO**: Hệ thống tích hợp bộ lọc nghiệp vụ nghiêm ngặt. Admin chỉ có thể nhập điểm cho sinh viên đối với môn học thỏa mãn đồng thời cả 3 điều kiện:
    1.  Sinh viên **đã đăng ký thành công** lịch học môn đó.
    2.  Môn học đó **đã được xếp lịch thi**.
    3.  **Ngày thi** của môn học đó đã trôi qua (phòng tránh việc nhập điểm trước khi thi).

### 🏁 3.6. Quản lý Lịch thi & Điều kiện dự thi (Exam Management)
*   Tạo lịch thi cho từng môn học (phòng thi, ngày thi, ca thi).
*   **Xét duyệt điều kiện dự thi**: Quản lý danh sách sinh viên được quyền tham gia phòng thi. Chỉ những sinh viên được Admin phê duyệt (tích chọn) đủ điều kiện thi mới được xuất hiện trong danh sách phòng thi và hiển thị lịch thi trên thiết bị di động cá nhân.

### 📂 3.7. Quản lý Tài liệu Học tập
*   Hiển thị danh sách các môn học có trong hệ thống đào tạo.
*   Bấm vào một môn học để quản lý riêng danh sách tài liệu của môn học đó:
    *   Tải lên tài liệu mới (Tên tài liệu, loại tài liệu: PDF/DOCX/Video/Link, đường dẫn URL).
    *   Sửa đổi thông tin tài liệu.
    *   Xóa tài liệu khỏi hệ thống.
