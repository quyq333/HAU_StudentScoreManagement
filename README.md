# HAU Mobile App - Quản Lý Sinh Viên

Dự án Flutter Mobile App dành cho sinh viên trường Đại học Kiến trúc Hà Nội (HAU). 
Project này bao gồm ứng dụng di động phía người dùng (Frontend) và API máy chủ (Backend).

## 📁 Cấu trúc thư mục dự án
- `/lib`: Chứa toàn bộ source code Flutter (Giao diện, Model, Service,...).
- `/student_management_backend`: Chứa source code Backend Java Spring Boot.

## 🚀 Hướng dẫn chạy phía Backend (Spring Boot)
Trước khi chạy Frontend, bạn **bắt buộc phải khởi chạy Backend** và cấu hình Database trước.
👉 **[Xem Hướng dẫn Cài đặt Backend chi tiết tại đây](./student_management_backend/README.md)**

## 📱 Hướng dẫn chạy phía Frontend (Flutter App)

### 1. Yêu cầu hệ thống
- Flutter SDK (Khuyên dùng phiên bản stable mới nhất).
- Android Studio (cùng với Android Emulator) hoặc thiết bị thật (Android/iOS).

### 2. Cài đặt thư viện (Dependencies)
Mở terminal tại thư mục gốc `flutter_mobile_application` và chạy lệnh sau để tải các package:
```bash
flutter pub get
```

### 3. Cấu hình IP Máy chủ (Rất Quan Trọng)
Hiện tại, IP của máy chủ API đang được cấu hình tĩnh bên trong file `lib/utils/app_constants.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
```
- **Nếu chạy bằng Máy ảo Android (Emulator):** Giữ nguyên `10.0.2.2` vì đây là IP vòng lặp của Emulator trỏ về máy thật.
- **Nếu chạy bằng Máy thật (Cắm cáp) hoặc iOS Simulator:** Bạn phải sửa `10.0.2.2` thành **địa chỉ IPv4 LAN** của máy tính bạn (Ví dụ: `192.168.1.5`). *Đảm bảo điện thoại và máy tính kết nối chung mạng WiFi.*

### 4. Khởi chạy Ứng dụng
Để chạy ứng dụng lên thiết bị ảo hoặc thiết bị thật:
```bash
flutter run
```

## 🛠 Khắc phục một số lỗi thường gặp

1. **Lỗi báo sai thông tin đăng nhập (Mã 401/403):** 
   - Đảm bảo trong bảng `SinhVien` trong SQL Server của bạn đã có dữ liệu.
   - Tài khoản đăng nhập tương ứng với `Mã Sinh Viên` và `Mật khẩu` lưu trong cơ sở dữ liệu.
   
2. **Lỗi không kết nối được đến máy chủ (Network Error):**
   - Đảm bảo Backend Spring Boot đang chạy ổn định.
   - Kiểm tra lại địa chỉ `baseUrl` (IP) trong file `app_constants.dart` như đã hướng dẫn ở Bước 3.
   
3. **Cảnh báo OnBackInvokedCallback (Android 13+):**
   - Trong quá trình build có thể có Warning liên quan tới việc vuốt Back. Lỗi này đã được tắt qua cấu hình Manifest và không ảnh hưởng tới tiến trình chạy. Bạn có thể bỏ qua nó.
