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

-- 1. Table Nhân Viên --
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

-- 2. Table Tài Khoản --
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

-- 3. Table Phân Công (Lịch làm việc) --
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