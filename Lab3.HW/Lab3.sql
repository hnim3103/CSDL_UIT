-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT HoTen, CapDo FROM ChuyenGia_KyNang
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_KyNang.MaChuyenGia
WHERE ChuyenGia.MaChuyenGia=1;


-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen FROM ChuyenGia
WHERE MaChuyenGia IN (
	SELECT MaChuyenGia FROM ChuyenGia_DuAn
	WHERE MaDuAn=2
);

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn FROM DuAn
JOIN CongTy ON CongTy.MaCongTy=DuAn.MaCongTy;

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(MaChuyenGia) as SoLuongChuyenGia FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT HoTen, NamKinhNghiem FROM ChuyenGia
WHERE NamKinhNghiem=(
	SELECT MAX(NamKinhNghiem) AS NamKinhNghiemCaoNhat FROM ChuyenGia
);

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn FROM ChuyenGia_DuAn
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_DuAn.MaChuyenGia
GROUP By HoTen;

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TenCongTy, COUNT(MaDuAn) AS SoLuongDuAn FROM DuAn
JOIN CongTy ON CongTy.MaCongTy=DuAn.MaCongTy
GROUP By TenCongTy;


-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất.
SELECT MaKyNang, TenKyNang FROM KyNang
WHERE MaKyNang=(
	SELECT TOP 1 MaKyNang FROM ChuyenGia_KyNang
	GROUP BY MaKyNang
	ORDER BY COUNT(MaChuyenGia) DESC
);

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen FROM ChuyenGia
WHERE MaChuyenGia IN (
	SELECT MaChuyenGia FROM ChuyenGia_KyNang
	WHERE CapDo>4 AND MaKyNang=(SELECT MaKyNang FROM KyNang WHERE TenKyNang='Python')
);

-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT MaDuAn, TenDuAn FROM DuAn
WHERE MaDuAn=(
	SELECT TOP 1 MaDuAn FROM ChuyenGia_DuAn
	GROUP BY MaDuAn
	ORDER BY COUNT(MaChuyenGia) DESC
);


-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT ChuyenGia.HoTen, COUNT(MaKyNang) AS SoLuongKyNang FROM ChuyenGia_KyNang
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_KyNang.MaChuyenGia
GROUP BY ChuyenGia.HoTen;

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT MaDuAn, MaChuyenGia FROM ChuyenGia_DuAn
ORDER BY MaDuAn

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT ChuyenGia.HoTen, COUNT(MaKyNang) AS SoLuongKyNangCapDo5 FROM ChuyenGia_KyNang
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_KyNang.MaChuyenGia
WHERE CapDo=5
GROUP BY ChuyenGia.HoTen;

-- 21. Tìm các công ty không có dự án nào.
SELECT * FROM CongTy
WHERE MaCongTy NOT IN (
	SELECT MaCongTy FROM DuAn
);

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia,
-- bao gồm cả chuyên gia không tham gia dự án nào.
SELECT HoTen, TenDuAn FROM ChuyenGia_DuAn
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN DuAn ON DuAN.MaDuAn=ChuyenGia_DuAn.MaDuAn


-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT HoTen FROM ChuyenGia
WHERE MaChuyenGia IN (
	SELECT MaChuyenGia FROM ChuyenGia_KyNang
	GROUP BY MaChuyenGia
	HAVING COUNT(MaKyNang)>=3
);

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm
-- của tất cả chuyên gia trong các dự án của công ty đó.
SELECT TenCongTy, SUM(NamKinhNghiem) AS SoNamKinhNghiem FROM CongTy
JOIN DuAn ON DuAn.MaCongTy=CongTy.MaCongTy
JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia=ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_DuAn.MaChuyenGia
GROUP BY TenCongTy;


-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT HoTen FROM ChuyenGia
WHERE MaChuyenGia IN (
	SELECT MaChuyenGia FROM ChuyenGia_KyNang
	WHERE MaKyNang=(SELECT MaKyNang FROM KyNang WHERE TenKyNang='Java')
	EXCEPT
	SELECT MaChuyenGia FROM ChuyenGia_KyNang
	WHERE MaKyNang=(SELECT MaKyNang FROM KyNang WHERE TenKyNang='Python')
);


-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
SELECT HoTen FROM ChuyenGia
WHERE MaChuyenGia=(
	SELECT TOP 1 MaChuyenGia FROM ChuyenGia_KyNang
	GROUP BY MaChuyenGia
	ORDER BY COUNT(MaKyNang) DESC
);

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT ChuyenNganh, HoTen FROM ChuyenGia
ORDER BY ChuyenNganh;

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
SELECT TOP 1 TenCongTy, SUM(NamKinhNghiem) AS SoNamKinhNghiem FROM CongTy
JOIN DuAn ON DuAn.MaCongTy=CongTy.MaCongTy
JOIN ChuyenGia_DuAn ON ChuyenGia_DuAn.MaChuyenGia=ChuyenGia_DuAn.MaDuAn
JOIN ChuyenGia ON ChuyenGia.MaChuyenGia=ChuyenGia_DuAn.MaChuyenGia
GROUP BY TenCongTy
ORDER BY SUM(NamKinhNghiem) DESC;


-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia.
SELECT TenKyNang FROM KyNang
JOIN ChuyenGia_KyNang ON ChuyenGia_KyNang.MaChuyenGia=KyNang.MaKyNang
GROUP By TenKyNang
HAVING COUNT(DISTINCT ChuyenGia_KyNang.MaChuyenGia)=(SELECT COUNT(*) MaChuyenGia FROM ChuyenGia);