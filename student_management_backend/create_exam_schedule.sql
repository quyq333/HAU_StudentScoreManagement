USE [HAU_StudentManagement];
GO

SET NOCOUNT ON;

IF COL_LENGTH('dbo.KetQuaHocTap', 'DiemTongKetHienThi') IS NULL
BEGIN
    ALTER TABLE dbo.KetQuaHocTap ADD DiemTongKetHienThi NVARCHAR(100) NULL;
END
GO

UPDATE dbo.KetQuaHocTap
SET DiemTongKetHienThi = FORMAT(DiemTongKet, '0.0', 'en-US')
WHERE DiemTongKetHienThi IS NULL AND DiemTongKet IS NOT NULL;
GO

IF OBJECT_ID('dbo.LichThi', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LichThi (
        Id BIGINT IDENTITY(1,1) PRIMARY KEY,
        MaMonHoc VARCHAR(20) NOT NULL,
        IdPhong BIGINT NULL,
        NgayThi DATE NOT NULL,
        CaThi NVARCHAR(20) NOT NULL,
        GhiChu NVARCHAR(255) NULL,
        CONSTRAINT FK_LichThi_MonHoc FOREIGN KEY (MaMonHoc) REFERENCES dbo.MonHoc(MaMonHoc),
        CONSTRAINT FK_LichThi_PhongHoc FOREIGN KEY (IdPhong) REFERENCES dbo.PhongHoc(Id)
    );
END
GO

IF OBJECT_ID('dbo.DangKyLichThi', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DangKyLichThi (
        Id BIGINT IDENTITY(1,1) PRIMARY KEY,
        IdLichThi BIGINT NOT NULL,
        MaSV VARCHAR(20) NOT NULL,
        CONSTRAINT FK_DangKyLichThi_LichThi FOREIGN KEY (IdLichThi) REFERENCES dbo.LichThi(Id) ON DELETE CASCADE,
        CONSTRAINT FK_DangKyLichThi_SinhVien FOREIGN KEY (MaSV) REFERENCES dbo.SinhVien(MaSV),
        CONSTRAINT UQ_DangKyLichThi UNIQUE (IdLichThi, MaSV)
    );
END
GO

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('LichThi', 'DangKyLichThi')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
