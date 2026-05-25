-- USE [HAU_StudentManagement]
-- GO

-- Xóa các bảng cũ nếu đã tồn tại để tạo lại (Theo thứ tự khóa ngoại trước)
IF OBJECT_ID('TaiLieuHocTap', 'U') IS NOT NULL DROP TABLE TaiLieuHocTap;
IF OBJECT_ID('LichHoc', 'U') IS NOT NULL DROP TABLE LichHoc;
IF OBJECT_ID('PhongHoc', 'U') IS NOT NULL DROP TABLE PhongHoc;
IF OBJECT_ID('GiangVien', 'U') IS NOT NULL DROP TABLE GiangVien;
IF OBJECT_ID('KetQuaHocTap', 'U') IS NOT NULL DROP TABLE KetQuaHocTap;
IF OBJECT_ID('SinhVien', 'U') IS NOT NULL DROP TABLE SinhVien;
IF OBJECT_ID('MonHoc', 'U') IS NOT NULL DROP TABLE MonHoc;
IF OBJECT_ID('HocKy', 'U') IS NOT NULL DROP TABLE HocKy;
GO

-- 1. Tạo bảng SinhVien
CREATE TABLE SinhVien (
    MaSV VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATETIME,
    Lop VARCHAR(50),
    MatKhau VARCHAR(255) NOT NULL,
    Role VARCHAR(20) DEFAULT 'ROLE_STUDENT'
);
GO

-- 2. Tạo bảng HocKy (Tạo trước MonHoc để tham chiếu)
CREATE TABLE HocKy (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TenHocKy NVARCHAR(50) NOT NULL,
    NamHoc VARCHAR(20) NOT NULL
);
GO

-- 3. Tạo bảng MonHoc (Có IdHocKy)
CREATE TABLE MonHoc (
    MaMonHoc VARCHAR(20) PRIMARY KEY,
    TenMonHoc NVARCHAR(200) NOT NULL,
    SoTinChi INT NOT NULL,
    IdHocKy INT,
    CONSTRAINT FK_MonHoc_HocKy FOREIGN KEY (IdHocKy) REFERENCES HocKy(Id)
);
GO

-- 4. Tạo bảng KetQuaHocTap
CREATE TABLE KetQuaHocTap (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    MaSV VARCHAR(20) NOT NULL,
    MaMonHoc VARCHAR(20) NOT NULL,
    IdHocKy INT NOT NULL,
    DiemChuyenCan FLOAT,
    DiemKiemTra FLOAT,
    DiemThi FLOAT,
    DiemTongKet FLOAT,
    DiemChu VARCHAR(5),
    CONSTRAINT FK_KetQua_SinhVien FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV),
    CONSTRAINT FK_KetQua_MonHoc FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc),
    CONSTRAINT FK_KetQua_HocKy FOREIGN KEY (IdHocKy) REFERENCES HocKy(Id)
);
GO

-- 5. Tạo bảng PhongHoc
CREATE TABLE PhongHoc (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TenPhong NVARCHAR(50) NOT NULL,
    ToaNha NVARCHAR(50),
    SucChua INT,
    LoaiPhong NVARCHAR(50)
);
GO

-- 6. Tạo bảng GiangVien
CREATE TABLE GiangVien (
    MaGV VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    SoDienThoai VARCHAR(20),
    Khoa NVARCHAR(100)
);
GO

-- 7. Tạo bảng LichHoc (Kết nối với MonHoc, PhongHoc, và GiangVien)
CREATE TABLE LichHoc (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    MaMonHoc VARCHAR(20) NOT NULL,
    IdPhong INT NOT NULL,
    MaGV VARCHAR(20) NOT NULL,
    ThuTrongTuan NVARCHAR(20) NOT NULL,
    CaHoc NVARCHAR(20) NOT NULL,
    NgayBatDau DATE,
    NgayKetThuc DATE,
    IsConfirmed BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_LichHoc_MonHoc FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc),
    CONSTRAINT FK_LichHoc_PhongHoc FOREIGN KEY (IdPhong) REFERENCES PhongHoc(Id),
    CONSTRAINT FK_LichHoc_GiangVien FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV)
);
GO

-- 8. Tạo bảng TaiLieuHocTap
CREATE TABLE TaiLieuHocTap (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    MaMonHoc VARCHAR(20) NOT NULL,
    TenTaiLieu NVARCHAR(200) NOT NULL,
    LoaiTaiLieu NVARCHAR(50),
    DuongDan NVARCHAR(500),
    NgayTaiLen DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_TaiLieu_MonHoc FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc)
);
GO

-- ==========================================
-- THÊM DỮ LIỆU MẪU (DUMMY DATA)
-- ==========================================

-- Thêm Sinh Viên và Admin
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, Lop, MatKhau, Role) 
VALUES 
('2255010178', N'Sinh Viên Test HAU', '2004-01-01', '22CNTT1', '123456', 'ROLE_STUDENT'),
('admin', N'Quản trị viên', '1990-01-01', NULL, 'admin123', 'ROLE_ADMIN');

-- Thêm Học Kỳ
INSERT INTO HocKy (TenHocKy, NamHoc) VALUES 
(N'Học kỳ 1', '2022-2023'),
(N'Học kỳ 2', '2022-2023');

-- Thêm một số Môn Học (Thuộc học kỳ 1 và 2)
INSERT INTO MonHoc (MaMonHoc, TenMonHoc, SoTinChi, IdHocKy) VALUES 
('IT101', N'Nhập môn Lập trình', 3, 1),
('IT102', N'Cấu trúc dữ liệu và giải thuật', 3, 1),
('IT103', N'Cơ sở dữ liệu', 3, 2);

-- Thêm Kết Quả Học Tập cho Sinh Viên 2255010178
INSERT INTO KetQuaHocTap (MaSV, MaMonHoc, IdHocKy, DiemChuyenCan, DiemKiemTra, DiemThi, DiemTongKet, DiemChu) VALUES 
('2255010178', 'IT101', 1, 9.0, 8.5, 8.0, 8.3, 'B+'),
('2255010178', 'IT102', 1, 10.0, 7.0, 9.0, 8.6, 'A'),
('2255010178', 'IT103', 2, 8.0, 6.0, 4.0, 5.2, 'D');

-- Thêm Phòng Học
INSERT INTO PhongHoc (TenPhong, ToaNha, SucChua, LoaiPhong) VALUES
(N'P.401', N'Nhà H', 80, N'Lý thuyết'),
(N'P.502', N'Nhà H', 60, N'Thực hành CNTT');

-- Thêm Giảng Viên
INSERT INTO GiangVien (MaGV, HoTen, Email, SoDienThoai, Khoa) VALUES
('GV01', N'Nguyễn Văn A', 'a.nv@hau.edu.vn', '0912345678', N'Công nghệ thông tin'),
('GV02', N'Trần Thị B', 'b.tt@hau.edu.vn', '0987654321', N'Công nghệ thông tin');

-- Thêm Lịch Học
INSERT INTO LichHoc (MaMonHoc, IdPhong, MaGV, ThuTrongTuan, CaHoc, NgayBatDau, NgayKetThuc) VALUES
('IT101', 1, 'GV01', N'Thứ 2', N'Ca 1', '2026-05-25', '2026-06-22'),
('IT102', 2, 'GV02', N'Thứ 4', N'Ca 3', '2026-05-25', '2026-06-22');

-- Thêm Tài Liệu Học Tập
INSERT INTO TaiLieuHocTap (MaMonHoc, TenTaiLieu, LoaiTaiLieu, DuongDan) VALUES
('IT101', N'Slide bài giảng Nhập môn Lập trình - Tuần 1', 'PDF', '/documents/it101-slide-t1.pdf'),
('IT102', N'Tài liệu thực hành Cấu trúc dữ liệu', 'PDF', '/documents/it102-lab.pdf');

GO
