-- table Vật Nuôi--
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VATNUOI')
BEGIN
    CREATE TABLE VATNUOI (
        MaVatNuoi VARCHAR(10) PRIMARY KEY,
        LoaiVatNuoi VARCHAR(50) NOT NULL,
        GioiTinh CHAR(1) CHECK (GioiTinh IN ('M', 'F')),
        NgaySinh DATE,
        CanNang DECIMAL(6,2),
        NgayNhap DATE NOT NULL,
        TrangThai VARCHAR(20) DEFAULT 'Dang Nuoi',
        ChuongNuoi VARCHAR(50)
    );
END;

--Table Sức khỏe--
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SUCKHOE')
BEGIN
    CREATE TABLE SUCKHOE (
        MaSucKhoe INT IDENTITY(1,1) PRIMARY KEY,
        MaVatNuoi VARCHAR(10) NOT NULL,
        NgayKiemTra DATE NOT NULL,
        TinhTrang VARCHAR(50) NOT NULL,
        TenBenh VARCHAR(100),
        TrieuChung NVARCHAR(MAX),
        DieuTri NVARCHAR(MAX),
        KetQua VARCHAR(50),

        FOREIGN KEY (MaVatNuoi) 
        REFERENCES VATNUOI(MaVatNuoi) 
        ON DELETE CASCADE
    );
END;

--Table Chuồng trại--
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChuongTrai')
BEGIN
    CREATE TABLE ChuongTrai (
        MaChuong INT PRIMARY KEY,
        TenChuong NVARCHAR(100),
        SucChua INT,
        SoLuongHienTai INT
    );
END;

-- Table Vệ sinh chuồng--
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VeSinhChuong')
BEGIN
    CREATE TABLE VeSinhChuong (
        MaVS INT PRIMARY KEY,
        MaChuong INT,
        NgayVeSinh DATE,
        TrangThai NVARCHAR(50),
        FOREIGN KEY (MaChuong) REFERENCES ChuongTrai(MaChuong)
    );
END;

--Table Nhân Viên --
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NhanVien')
BEGIN
    CREATE TABLE NhanVien (
        MaNhanVien NVARCHAR(50) PRIMARY KEY,
        HoTen NVARCHAR(200),
        ChucVu NVARCHAR(50), -- Nhân viên/Quản lý
        SoDienThoai NVARCHAR(20),
        Email NVARCHAR(100),
        NgayVaoLam DATE
    );
END;

--Table Tài Khoản --
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TaiKhoan')
BEGIN
    CREATE TABLE TaiKhoan (
        MaTaiKhoan NVARCHAR(50) PRIMARY KEY,
        TenDangNhap NVARCHAR(100) NOT NULL,
        MatKhau NVARCHAR(255) NOT NULL,
        VaiTro NVARCHAR(50), -- Chủ trại/Quản lý/Nhân viên (SQL Server không có ENUM mặc định, dùng NVARCHAR)
        MaNhanVien NVARCHAR(50),
        TrangThai NVARCHAR(50), -- Hoạt động/Khóa
        FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
    );
END;

-- Table Phân Công (Lịch làm việc) --
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PhanCong')
BEGIN
    CREATE TABLE PhanCong (
        MaPhanCong NVARCHAR(50) PRIMARY KEY,
        MaNhanVien NVARCHAR(50),
        NgayLam DATE,
        CaLam NVARCHAR(50), -- Sáng/Chiều/Tối
        MoTaCongViec NVARCHAR(MAX),
        KetQuaThucHien NVARCHAR(MAX),
        FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
    );
END;

-- 4. Table Chi Phí --
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChiPhi')
BEGIN
    CREATE TABLE ChiPhi (
        MaChiPhi NVARCHAR(50) PRIMARY KEY,
        LoaiChiPhi NVARCHAR(100), -- Thức ăn/Thuốc/Nhân công...
        SoTien DECIMAL(18, 2),
        NgayPhatSinh DATE,
        GhiChu NVARCHAR(MAX),
        MaNhanVien NVARCHAR(50), -- Người nhập chi phí
        FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
    );
END;

-- table thức ăn-- 
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ThucAn')
BEGIN
    CREATE TABLE ThucAn ( 
        MaThucAn NVARCHAR(10) PRIMARY KEY, 
        TenThucAn NVARCHAR(100), 
        LoaiThucAn NVARCHAR(50), 
        DonVi NVARCHAR(20), 
        SoLuongTonKho DECIMAL(10,2),

        CONSTRAINT CK_TonKho CHECK (SoLuongTonKho >= 0)
    ); 
END;

-- table lịch cho ăn--
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LichChoAn')
BEGIN
    CREATE TABLE LichChoAn ( 
        MaLichChoAn NVARCHAR(10) PRIMARY KEY, 
        GioChoAn TIME, 
        LuongThucAn DECIMAL(10,2), 
        TanSuat NVARCHAR(50), 
        MaVatNuoi VARCHAR(10), 
        MaThucAn NVARCHAR(10),

        FOREIGN KEY (MaVatNuoi) REFERENCES VATNUOI(MaVatNuoi),
        FOREIGN KEY (MaThucAn) REFERENCES ThucAn(MaThucAn),

        CONSTRAINT CK_LuongAn CHECK (LuongThucAn > 0)
    ); 
END;

ALTER TABLE VATNUOI
ADD MaChuong INT;

ALTER TABLE VATNUOI
ADD CONSTRAINT FK_VatNuoi_Chuong
FOREIGN KEY (MaChuong) REFERENCES ChuongTrai(MaChuong);

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PhanCong_LichChoAn')
BEGIN
    CREATE TABLE PhanCong_LichChoAn (
        MaPhanCong NVARCHAR(50),
        MaLichChoAn NVARCHAR(10),
        PRIMARY KEY (MaPhanCong, MaLichChoAn),
        FOREIGN KEY (MaPhanCong) REFERENCES PhanCong(MaPhanCong),
        FOREIGN KEY (MaLichChoAn) REFERENCES LichChoAn(MaLichChoAn)
    );
END;

INSERT INTO ChuongTrai VALUES
(1, N'Chuồng Bò Thịt', 30, 2),
(2, N'Chuồng Bò Sữa', 25, 2),
(3, N'Chuồng Heo', 50, 2),
(4, N'Chuồng Gà', 100, 2),
(5, N'Chuồng Con Non', 40, 2),
(6, N'Chuồng Mang Thai', 20, 2);

INSERT INTO VATNUOI VALUES
('BT001', N'Bò Thịt', 'M', '2023-01-10', 450, '2024-01-01', N'Đang Nuôi', 'CT1', 1),
('BT002', N'Bò Thịt', 'F', '2025-01-01', 120, '2025-02-01', N'Con Non', 'CT5', 5),

('BS001', N'Bò Sữa', 'F', '2023-03-15', 400, '2024-02-01', N'Đang Nuôi', 'CT2', 2),
('BS002', N'Bò Sữa', 'F', '2023-06-10', 420, '2024-03-01', N'Mang Thai', 'CT6', 6),

('H001', N'Heo', 'M', '2024-01-10', 100, '2024-02-01', N'Đang Nuôi', 'CT3', 3),
('H002', N'Heo', 'F', '2025-02-01', 30, '2025-03-01', N'Con Non', 'CT5', 5),

('G001', N'Gà', 'F', '2024-01-05', 2.5, '2024-01-10', N'Đang Nuôi', 'CT4', 4),
('G002', N'Gà', 'F', '2025-03-01', 1.2, '2025-03-10', N'Con Non', 'CT5', 5);

INSERT INTO SUCKHOE (MaVatNuoi, NgayKiemTra, TinhTrang, TenBenh, TrieuChung, DieuTri, KetQua) VALUES
('BT001', '2024-06-01', N'Khỏe', NULL, NULL, NULL, N'Bình thường'),
('BS002', '2024-07-01', N'Khám thai', NULL, NULL, NULL, N'Ổn định'),
('H001', '2024-08-01', N'Bệnh', N'Tiêu chảy', N'Mệt', N'Uống thuốc', N'Đang điều trị'),
('G001', '2024-09-01', N'Khỏe', NULL, NULL, NULL, N'Bình thường');

INSERT INTO VeSinhChuong VALUES
(1, 1, '2026-04-15', N'Đã vệ sinh'),
(2, 2, '2026-04-16', N'Đã vệ sinh'),
(3, 3, '2026-04-17', N'Chưa vệ sinh'),
(4, 4, '2026-04-18', N'Đã vệ sinh');

INSERT INTO ThucAn VALUES
('TA01', N'Cám Bò', N'Tinh', N'Kg', 500),
('TA02', N'Cỏ', N'Thô', N'Kg', 1000),
('TA03', N'Cám Heo', N'Tinh', N'Kg', 300),
('TA04', N'Cám Gà', N'Tinh', N'Kg', 200);

INSERT INTO LichChoAn VALUES
('L01', '07:00', 5, N'2 lần/ngày', 'BT001', 'TA01'),
('L02', '08:00', 4, N'2 lần/ngày', 'BS001', 'TA02'),
('L03', '09:00', 2, N'3 lần/ngày', 'H001', 'TA03'),
('L04', '06:00', 0.5, N'3 lần/ngày', 'G001', 'TA04');

INSERT INTO NhanVien VALUES
('NV01', N'Nguyễn Văn A', N'Quản lý', '0901111111', 'a@gmail.com', '2023-01-01'),
('NV02', N'Trần Thị B', N'Nhân viên', '0902222222', 'b@gmail.com', '2023-05-01');

INSERT INTO TaiKhoan VALUES
('TK01', 'admin', '123456', N'Chủ trại', 'NV01', N'Hoạt động'),
('TK02', 'nhanvien', '123456', N'Nhân viên', 'NV02', N'Hoạt động');

INSERT INTO PhanCong VALUES
('PC01', 'NV02', '2026-04-20', N'Sáng', N'Cho ăn bò', N'Hoàn thành'),
('PC02', 'NV02', '2026-04-21', N'Chiều', N'Vệ sinh chuồng', N'Đang làm');

INSERT INTO PhanCong_LichChoAn VALUES
('PC01', 'L01'),
('PC01', 'L02'),
('PC02', 'L03');

INSERT INTO ChiPhi VALUES
('CP01', N'Thức ăn', 5000000, '2026-04-01', N'Mua cám', 'NV01'),
('CP02', N'Thuốc', 1200000, '2026-04-05', N'Mua thuốc', 'NV02'),
('CP03', N'Nhân công', 3000000, '2026-04-10', N'Lương nhân viên', 'NV01');
