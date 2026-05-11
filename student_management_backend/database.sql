-- USE [HAU_StudentManagement]
-- GO

-- Xóa các bảng cũ nếu đã tồn tại để tạo lại (Theo thứ tự khóa ngoại trước)
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

GO
