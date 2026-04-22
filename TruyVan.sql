--truy vẫn
--danh sách theo dõi vật nuôi
SELECT vn.MaVatNuoi, vn.LoaiVatNuoi, vn.TrangThai, ct.TenChuong
FROM VATNUOI vn
JOIN ChuongTrai ct ON vn.MaChuong = ct.MaChuong;

--theo dõi sức khỏe vật nuôi
SELECT vn.MaVatNuoi, vn.LoaiVatNuoi, sk.NgayKiemTra, sk.TinhTrang, sk.TenBenh
FROM VATNUOI vn
JOIN SUCKHOE sk ON vn.MaVatNuoi = sk.MaVatNuoi;

-- Lịch cho ăn + nhân viên phụ trách việc đó 
SELECT nv.HoTen, pc.NgayLam, lca.GioChoAn, vn.MaVatNuoi
FROM PhanCong pc
JOIN NhanVien nv ON pc.MaNhanVien = nv.MaNhanVien
JOIN PhanCong_LichChoAn pclca ON pc.MaPhanCong = pclca.MaPhanCong
JOIN LichChoAn lca ON pclca.MaLichChoAn = lca.MaLichChoAn
JOIN VATNUOI vn ON lca.MaVatNuoi = vn.MaVatNuoi;

-- thống kê chi phí
SELECT LoaiChiPhi, SUM(SoTien) AS TongTien
FROM ChiPhi
GROUP BY LoaiChiPhi;


-- Store Procedure 
--thêm vật nuôi
CREATE PROCEDURE sp_ThemVatNuoi
    @Ma VARCHAR(10),
    @Loai NVARCHAR(50),
    @GioiTinh CHAR(1),
    @NgayNhap DATE,
    @MaChuong INT
AS
BEGIN
    INSERT INTO VATNUOI(MaVatNuoi, LoaiVatNuoi, GioiTinh, NgayNhap, MaChuong)
    VALUES (@Ma, @Loai, @GioiTinh, @NgayNhap, @MaChuong);
END;

-- cập nhật tình trạng sức khỏe
CREATE PROCEDURE sp_CapNhatSucKhoe
    @MaVatNuoi VARCHAR(10),
    @TinhTrang NVARCHAR(50)
AS
BEGIN
    UPDATE SUCKHOE
    SET TinhTrang = @TinhTrang
    WHERE MaVatNuoi = @MaVatNuoi;
END;

--Trigger
CREATE TRIGGER trg_KiemTraSucChuaChuong
ON VATNUOI
AFTER INSERT
AS
BEGIN
-- Kiểm tra nếu chuồng bị vượt sức chứa
    IF EXISTS (
        SELECT 1
        FROM ChuongTrai ct
        JOIN (
            SELECT MaChuong, COUNT(*) AS SoLuongThem
            FROM inserted
            GROUP BY MaChuong
        ) i ON ct.MaChuong = i.MaChuong
        WHERE ct.SoLuongHienTai + i.SoLuongThem > ct.SucChua
    )
    BEGIN
        PRINT N'Chuồng đã vượt sức chứa!';
        ROLLBACK TRANSACTION;
        RETURN;
    END

-- Nếu hợp lệ → cập nhật số lượng chuồng
    UPDATE ct
    SET SoLuongHienTai = SoLuongHienTai + i.SoLuongThem
    FROM ChuongTrai ct
    JOIN (
        SELECT MaChuong, COUNT(*) AS SoLuongThem
        FROM inserted
        GROUP BY MaChuong
    ) i ON ct.MaChuong = i.MaChuong;
END;


--Veiw
--view thống kê vật nuôi
CREATE VIEW vw_ThongKeVatNuoiTheoLoai
AS
SELECT 
    LoaiVatNuoi,
    COUNT(*) AS SoLuong
FROM VATNUOI
GROUP BY LoaiVatNuoi;
--cách chạy view
SELECT * 
FROM vw_ThongKeVatNuoiTheoLoai;

--view thông tin vật nuôi
CREATE VIEW vw_VatNuoi_ChuongTrai
AS
SELECT
    vn.MaVatNuoi,
    vn.LoaiVatNuoi,
    vn.GioiTinh,
    vn.TrangThai,
    ct.TenChuong,
    ct.SucChua,
    ct.SoLuongHienTai
FROM VATNUOI vn
JOIN ChuongTrai ct
    ON vn.MaChuong = ct.MaChuong;
-- cách chạy
SELECT * 
FROM vw_VatNuoi_ChuongTrai;