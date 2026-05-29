USE [HAU_StudentManagement];
GO

SET NOCOUNT ON;

-- Convert existing Vietnamese text columns to Unicode.
ALTER TABLE dbo.SinhVien ALTER COLUMN HoTen NVARCHAR(100) NOT NULL;
ALTER TABLE dbo.HocKy ALTER COLUMN TenHocKy NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.MonHoc ALTER COLUMN TenMonHoc NVARCHAR(200) NOT NULL;
ALTER TABLE dbo.PhongHoc ALTER COLUMN TenPhong NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.PhongHoc ALTER COLUMN ToaNha NVARCHAR(50) NULL;
ALTER TABLE dbo.PhongHoc ALTER COLUMN LoaiPhong NVARCHAR(50) NULL;
ALTER TABLE dbo.GiangVien ALTER COLUMN HoTen NVARCHAR(100) NOT NULL;
ALTER TABLE dbo.GiangVien ALTER COLUMN Khoa NVARCHAR(100) NULL;
ALTER TABLE dbo.LichHoc ALTER COLUMN ThuTrongTuan NVARCHAR(20) NOT NULL;
ALTER TABLE dbo.LichHoc ALTER COLUMN CaHoc NVARCHAR(20) NOT NULL;
ALTER TABLE dbo.TaiLieuHocTap ALTER COLUMN TenTaiLieu NVARCHAR(200) NOT NULL;
ALTER TABLE dbo.TaiLieuHocTap ALTER COLUMN LoaiTaiLieu NVARCHAR(50) NULL;
ALTER TABLE dbo.TaiLieuHocTap ALTER COLUMN DuongDan NVARCHAR(500) NULL;
GO

-- Repair finite values that were already stored with '?' before the columns were Unicode.
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Thứ 2' WHERE ThuTrongTuan = N'Th? 2';
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Thứ 3' WHERE ThuTrongTuan = N'Th? 3';
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Thứ 4' WHERE ThuTrongTuan = N'Th? 4';
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Thứ 5' WHERE ThuTrongTuan = N'Th? 5';
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Thứ 6' WHERE ThuTrongTuan = N'Th? 6';
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Thứ 7' WHERE ThuTrongTuan = N'Th? 7';
UPDATE dbo.LichHoc SET ThuTrongTuan = N'Chủ nhật' WHERE ThuTrongTuan = N'Ch? nh?t';

UPDATE dbo.LichHoc SET CaHoc = N'Ca sáng' WHERE CaHoc = N'Ca s?ng';
UPDATE dbo.LichHoc SET CaHoc = N'Ca chiều' WHERE CaHoc = N'Ca chi?u';
UPDATE dbo.LichHoc SET CaHoc = N'Ca tối' WHERE CaHoc = N'Ca t?i';

UPDATE dbo.PhongHoc
SET LoaiPhong = N'Phòng lý thuyết'
WHERE LoaiPhong IN (N'Phòng lý thuy?t', N'Phòng l? thuy?t', N'Lý thuy?t', N'L? thuy?t');

UPDATE dbo.PhongHoc
SET LoaiPhong = N'Phòng thực hành'
WHERE LoaiPhong IN (N'Phòng th?c hành', N'Phòng th?c h?nh', N'Th?c hành', N'Th?c h?nh');

UPDATE dbo.PhongHoc
SET LoaiPhong = N'Hội trường'
WHERE LoaiPhong IN (N'H?i trường', N'H?i tr??ng');
GO

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE (TABLE_NAME = 'LichHoc' AND COLUMN_NAME IN ('ThuTrongTuan', 'CaHoc'))
   OR (TABLE_NAME = 'PhongHoc' AND COLUMN_NAME IN ('TenPhong', 'ToaNha', 'LoaiPhong'))
ORDER BY TABLE_NAME, COLUMN_NAME;

SELECT DISTINCT ThuTrongTuan, CaHoc FROM dbo.LichHoc ORDER BY ThuTrongTuan, CaHoc;
SELECT DISTINCT LoaiPhong, ToaNha FROM dbo.PhongHoc ORDER BY LoaiPhong, ToaNha;
