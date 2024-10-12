--51
SELECT *
FROM ChuyenGia

--52
SELECT HoTen, Email
FROM ChuyenGia

--53
SELECT TenCongTy, SoNhanVien
FROM CongTy

--54
SELECT TenDuAn
FROM DuAn
WHERE TrangThai = N'Đang thực hiện'

--55
SELECT TenKyNang, LoaiKyNang 
FROM KyNang

--56
SELECT HoTen, ChuyenNganh
FROM ChuyenGia
WHERE GioiTinh = N'Nam'

--57
SELECT TenCongTy, LinhVuc
FROM CongTy
WHERE SoNhanVien > 150

--58
SELECT TenDuAn
FROM DuAn
WHERE YEAR(NgayBatDau) = 2023

--59
SELECT TenKyNang
FROM KyNang
WHERE LoaiKyNang = N'Công cụ'

--60
SELECT HoTen, NamKinhNghiem
FROM ChuyenGia
WHERE NamKinhNghiem > 5

--61
SELECT TenCongTy, DiaChi
FROM CongTy
WHERE LinhVuc = N'Phát triển phần mềm'

--62
SELECT TenDuAn
FROM DuAn
WHERE YEAR(NgayKetThuc) = 2023

--63
SELECT  TenKyNang, CapDo
FROM ChuyenGia_KyNang, KyNang
WHERE ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang

--64
SELECT MaChuyenGia, VaiTro
FROM ChuyenGia_DuAn

--65
SELECT HoTen, NgaySinh
FROM ChuyenGia
WHERE YEAR(NgaySinh) >= 1990

--66
SELECT	TenCongTy, SoNhanVien
FROM CongTy
ORDER BY SoNhanVien DESC

--67
SELECT TenDuAn, NgayBatDau
FROM DuAn
ORDER BY NgayBatDau ASC

--68
SELECT DISTINCT TenKyNang
FROM KyNang

--69
SELECT TOP 5 HoTen, Email
FROM ChuyenGia

--70
SELECT TenCongTy
FROM CongTy
WHERE TenCongTy LIKE '%Tech%'

--71
SELECT TenDuAn, TrangThai
FROM DuAn
WHERE TrangThai != N'Hoàn thành'

--72
SELECT HoTen, ChuyenNganh
FROM ChuyenGia
ORDER BY ChuyenNganh, HoTen ASC

--73
SELECT TenCongTy, LinhVuc
FROM CongTy
WHERE SoNhanVien >= 100 AND SoNhanVien <= 200

--74
SELECT TenKyNang, LoaiKyNang
FROM KyNang
ORDER BY LoaiKyNang DESC, TenKyNang ASC

--75
SELECT HoTen, SoDienThoai
FROM ChuyenGia
WHERE Email LIKE '%email.com%'
