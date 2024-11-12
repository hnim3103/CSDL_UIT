-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 WITH TIES CG.HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.MaChuyenGia, CG.HoTen
ORDER BY SoLuongKyNang DESC;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2, CG1.ChuyenNganh
FROM ChuyenGia CG1
JOIN ChuyenGia CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh
WHERE ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <= 2
  AND CG1.MaChuyenGia < CG2.MaChuyenGia;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT CT.TenCongTy, COUNT(DA.MaDuAn) AS SoLuongDuAn, SUM(CG.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn = CGDA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY CT.MaCongTy, CT.TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT CG.HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
WHERE CGKN.CapDo = 5
GROUP BY CG.MaChuyenGia, CG.HoTen
HAVING NOT EXISTS (
    SELECT 1
    FROM ChuyenGia_KyNang CGKN2
    WHERE CGKN2.MaChuyenGia = CG.MaChuyenGia AND CGKN2.CapDo < 3
);

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT CG.HoTen, COUNT(CGDA.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia CG
LEFT JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY CG.MaChuyenGia, CG.HoTen;

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
WITH MaxCapDo AS (
    SELECT KN.LoaiKyNang, MAX(CGKN.CapDo) AS MaxCapDo
    FROM ChuyenGia_KyNang CGKN
    JOIN KyNang KN ON CGKN.MaKyNang = KN.MaKyNang
    GROUP BY KN.LoaiKyNang
)
SELECT CG.HoTen, KN.TenKyNang, CGKN.CapDo
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON CGKN.MaKyNang = KN.MaKyNang
JOIN MaxCapDo MCD ON KN.LoaiKyNang = MCD.LoaiKyNang AND CGKN.CapDo = MCD.MaxCapDo
ORDER BY KN.LoaiKyNang, CGKN.CapDo DESC;

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh, COUNT(MaChuyenGia) * 100.0 / (SELECT COUNT(*) FROM ChuyenGia) AS TyLe
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT CGKN1.MaKyNang AS KyNang1, CGKN2.MaKyNang AS KyNang2, COUNT(*) AS SoLanXuatHienCungNhau
FROM ChuyenGia_KyNang CGKN1
JOIN ChuyenGia_KyNang CGKN2 ON CGKN1.MaChuyenGia = CGKN2.MaChuyenGia AND CGKN1.MaKyNang < CGKN2.MaKyNang
GROUP BY CGKN1.MaKyNang, CGKN2.MaKyNang
ORDER BY SoLanXuatHienCungNhau DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT CT.TenCongTy, AVG(DATEDIFF(day, DA.NgayBatDau, DA.NgayKetThuc)) AS SoNgayTrungBinh
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
WITH ChuyenGiaKyNang AS (
    SELECT CG.MaChuyenGia, STRING_AGG(KN.TenKyNang, ', ') AS KetHopKyNang
    FROM ChuyenGia_KyNang CGKN
    JOIN ChuyenGia CG ON CGKN.MaChuyenGia = CG.MaChuyenGia
    JOIN KyNang KN ON CGKN.MaKyNang = KN.MaKyNang
    GROUP BY CG.MaChuyenGia
),
KetHopDocDao AS (
    SELECT KetHopKyNang, COUNT(*) AS Count
    FROM ChuyenGiaKyNang
    GROUP BY KetHopKyNang
    HAVING COUNT(*) = 1
)
SELECT CG.HoTen, CGKN.KetHopKyNang
FROM ChuyenGia CG
JOIN ChuyenGiaKyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KetHopDocDao KHDD ON CGKN.KetHopKyNang = KHDD.KetHopKyNang;

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT CG.HoTen, COUNT(CGDA.MaDuAn) AS SoLuongDuAn, SUM(CGKN.CapDo) AS TongCapDoKyNang
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.MaChuyenGia, CG.HoTen
ORDER BY SoLuongDuAn DESC, TongCapDoKyNang DESC;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT DA.MaDuAn, DA.TenDuAn
FROM DuAn DA
JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn = CGDA.MaDuAn
JOIN ChuyenGia CG ON CGDA.MaChuyenGia = CG.MaChuyenGia
GROUP BY DA.MaDuAn, DA.TenDuAn
HAVING COUNT(DISTINCT CG.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT CT.TenCongTy, COUNT(CASE WHEN DA.TrangThai = N'Hoàn thành' THEN 1 END) * 100.0 / COUNT(*) AS TyLeThanhCong
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY CT.TenCongTy;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
WITH ChuyenGiaCapDo AS (
    SELECT 
        CGKN1.MaChuyenGia AS MaChuyenGia1,
        CGKN2.MaChuyenGia AS MaChuyenGia2,
        CGKN1.MaKyNang AS KyNangA,
        CGKN2.MaKyNang AS KyNangB,
        CGKN1.CapDo AS CapDoA,
        CGKN2.CapDo AS CapDoB
    FROM ChuyenGia_KyNang CGKN1
    JOIN ChuyenGia_KyNang CGKN2 ON CGKN1.MaChuyenGia != CGKN2.MaChuyenGia
    WHERE CGKN1.MaKyNang < CGKN2.MaKyNang
)
SELECT 
    ChuyenGia1.HoTen AS TenChuyenGia1,
    KyNangA.TenKyNang AS TenKyNangA,
    ChuyenGiaCapDo.CapDoA AS CapDoA,
    ChuyenGia2.HoTen AS TenChuyenGia2,
    KyNangB.TenKyNang AS TenKyNangB,
    ChuyenGiaCapDo.CapDoB AS CapDoB
FROM ChuyenGiaCapDo
JOIN ChuyenGia AS ChuyenGia1 ON ChuyenGiaCapDo.MaChuyenGia1 = ChuyenGia1.MaChuyenGia
JOIN ChuyenGia AS ChuyenGia2 ON ChuyenGiaCapDo.MaChuyenGia2 = ChuyenGia2.MaChuyenGia
JOIN KyNang AS KyNangA ON ChuyenGiaCapDo.KyNangA = KyNangA.MaKyNang
JOIN KyNang AS KyNangB ON ChuyenGiaCapDo.KyNangB = KyNangB.MaKyNang
WHERE (CapDoA > 3 AND CapDoB <= 3) OR (CapDoA <= 3 AND CapDoB > 3);