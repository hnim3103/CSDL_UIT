-- Cau 9: Lop truong cua 1 lop phai la hoc vien cua lop do
-- 9.1 trigger update LOP
CREATE TRIGGER lop_update
ON LOP
AFTER UPDATE
AS
IF (UPDATE(TRGLOP))
BEGIN
	DECLARE @MALOP varchar(4), @TRGLOP varchar(4)
	SELECT @MALOP = MALOP, @TRGLOP = TRGLOP FROM INSERTED
	IF (NOT EXISTS (SELECT * FROM HOCVIEN HV
							WHERE HV.MAHV = @TRGLOP AND HV.MALOP = @MALOP))
		BEGIN
			PRINT 'LOI: LOP TRUONG PHAI LA HOC VIEN CUA LOP DO'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 9.2 trigger update HOCVIEN
CREATE TRIGGER hocvien_update
ON HOCVIEN
AFTER UPDATE
AS
IF (UPDATE(MALOP))
BEGIN
	IF(EXISTS (SELECT * FROM LOP, INSERTED I WHERE LOP.TRGLOP =I.MAHV))
		BEGIN
			PRINT 'HOC VIEN LA TRUONG LOP, KHONG THE CHUYEN LOP'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 10: Truong khoa phai la giao vien thuoc khoa va co hoc vi la 'TS' hoac 'PTS'
-- 10.1 trigger update KHOA
CREATE TRIGGER khoa_update_trgkhoa
ON KHOA
AFTER UPDATE
AS
BEGIN
	IF(NOT EXISTS (SELECT * FROM INSERTED I, GIAOVIEN GV 
							WHERE I.TRGKHOA = GV.MAGV AND I.MAKHOA = GV.MAKHOA AND GV.HOCVI IN ('TS', 'PTS')))
		BEGIN
			PRINT 'LOI: TRUONG KHOA PHAI LA GIAO VIEN THUOC KHOA VA CO HOC VI LA TS HOAC PTS'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 10.2 trigger update hoc vi cua GIAOVIEN
CREATE TRIGGER giaovien_update_hocvi
ON GIAOVIEN
AFTER UPDATE
AS
IF (UPDATE (HOCVI))
BEGIN
	IF (EXISTS (SELECT * FROM KHOA, INSERTED I WHERE I.MAGV = KHOA.TRGKHOA AND I.HOCVI NOT IN ('TS', 'PTS')))
		BEGIN
			PRINT 'LOI: GIAO VIEN DANG LA TRUONG KHOA VA HOC VI PHAI LA TS HOAC PTS'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 10.3 trigger update khoa GIAOVIEN
CREATE TRIGGER giaovien_update_khoa
ON GIAOVIEN
AFTER UPDATE
AS
IF (UPDATE (MAKHOA))
BEGIN
	IF (EXISTS (SELECT * FROM KHOA, INSERTED I WHERE I.MAGV = KHOA.TRGKHOA))
		BEGIN
			PRINT 'LOI: GIAO VIEN DANG LA TRUONG KHOA'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 15: Hoc vien chi duoc thi 1 mon nao do khi lop cua hoc vien da hoc xong mon nay
-- 15.1 trigger insert, update ngay thi KETQUATHI
CREATE TRIGGER trg15_ketquathi_insert_update
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @NGTHI smalldatetime, @NGKT smalldatetime, @MAHV varchar(4), @MALOP varchar(4)
	SELECT @NGTHI = I.NGTHI, @NGKT = GD.DENNGAY, @MAHV = I.MAHV, @MALOP = GD.MALOP 
		FROM INSERTED I, GIANGDAY GD, HOCVIEN HV 
			WHERE HV.MAHV = I.MAHV AND HV.MALOP = GD.MALOP AND I.MAMH = GD.MAMH
	IF(@NGTHI < @NGKT)
		BEGIN
			PRINT 'LOI: NGAY THI PHAI LON HON HOAC BANG NGAY KET THUC MON'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 15.2 trigger update ngay ket thuc GIANGDAY
CREATE TRIGGER trg15_giangday_update
ON GIANGDAY
AFTER UPDATE
AS
IF (UPDATE(DENNGAY))
BEGIN
	DECLARE @NGTHI smalldatetime, @NGKT smalldatetime, @MAHV varchar(4), @MALOP varchar(4)
	SELECT @NGTHI = KQ.NGTHI, @NGKT = I.DENNGAY, @MAHV = KQ.MAHV, @MALOP = I.MALOP
		FROM INSERTED I, KETQUATHI KQ, HOCVIEN HV
			WHERE HV.MAHV = KQ.MAHV AND HV.MALOP = I.MALOP AND KQ.MAMH = I.MAMH
	IF(@NGTHI < @NGKT)
		BEGIN
			PRINT 'LOI: NGAY THI PHAI LON HON HOAC BANG NGAY KET THUC MON'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 16: Moi hoc ky cua 1 nam hoc moi lop chi duoc hoc toi da 3 mon
CREATE TRIGGER trg16_giangday_insert_update
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF ((SELECT COUNT(DISTINCT GD.MAMH) FROM INSERTED I, GIANGDAY GD
				WHERE I.MALOP = GD.MALOP AND I.HOCKY = GD.HOCKY AND I.NAM = GD.NAM) > 3)
		BEGIN
			PRINT 'LOI: TRONG 1 HOC KY CUA 1 NAM MOI LOP CHI DUOC HOC TOI DA 3 MON'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 17: Si so cua 1 lop bang so luong hoc vien cua lop do
-- 17.1: trigger insert, update HOCVIEN
CREATE TRIGGER trg17_hocvien_insert_update
ON HOCVIEN
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @SISO tinyint, @MALOP varchar(4)
	SELECT @MALOP = MALOP FROM INSERTED
	SELECT @SISO = COUNT(*) FROM HOCVIEN HV, INSERTED I
			WHERE HV.MALOP = I.MALOP
	UPDATE LOP SET SISO = @SISO WHERE LOP.MALOP = @MALOP
END
-- 17.2: trigger delete HOCVIEN
CREATE TRIGGER trg17_hocvien_delete
ON HOCVIEN
AFTER DELETE
AS
BEGIN
	DECLARE @SISO tinyint, @MALOP varchar(4)
	SELECT @MALOP = MALOP FROM DELETED
	SELECT @SISO = COUNT(*) FROM HOCVIEN HV, DELETED D
		WHERE HV.MALOP = D.MALOP
	UPDATE LOP SET SISO = @SISO WHERE LOP.MALOP = @MALOP
END
-- 17.3: trigger update LOP
CREATE TRIGGER trg_17_lop_update
ON LOP
AFTER UPDATE
AS
BEGIN
	DECLARE @SISO tinyint, @MALOP varchar(4)
	SELECT @MALOP = MALOP FROM INSERTED
	SELECT @SISO = COUNT(*) FROM HOCVIEN HV, INSERTED I
		WHERE HV.MALOP = I.MALOP
	UPDATE LOP SET SISO = @SISO WHERE LOP.MALOP = @MALOP
END
-- Cau 18: Trong quan he DIEUKIEN gia tri cua thuoc tinh MAMH va MAMH_TRUOC trong cung mot bo khong duoc giong nhau 
--				("A","A") va cung khong ton tai hai bo ("A","B") va ("B","A").
CREATE TRIGGER trg18_dieukien_insert
ON DIEUKIEN
AFTER INSERT
AS
BEGIN
	DECLARE @I_MAMH varchar(10), @I_MAMH_TRUOC varchar (10)
	SELECT @I_MAMH = MAMH, @I_MAMH_TRUOC = MAMH_TRUOC FROM INSERTED
	IF((@I_MAMH = @I_MAMH_TRUOC) 
		OR EXISTS (SELECT * FROM DIEUKIEN DK, INSERTED I
							WHERE (I.MAMH = DK.MAMH_TRUOC AND I.MAMH_TRUOC = DK.MAMH)
								OR (DK.MAMH = I.MAMH_TRUOC AND DK.MAMH_TRUOC = I.MAMH)))
		BEGIN
			PRINT 'LOI! VUI LONG NHAP LAI'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 19: Cac giao vien co cung hoc vi, hoc ham, he so luong thi co muc luong bang nhau
CREATE TRIGGER trg19_giaovien_insert_update
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF (EXISTS (SELECT * FROM GIAOVIEN GV, INSERTED I
						WHERE GV.MAGV <> I.MAGV AND I.HOCVI = GV.HOCVI AND I.HOCHAM = GV.HOCHAM
							AND I.HESO = GV.HESO AND I.MUCLUONG <> GV.MUCLUONG))
		BEGIN 
			PRINT 'LOI: CAC GIAO VIEN CO CUNG HOC VI, HOC HAM, HE SO LUONG THI CO MUC LUONG BANG NHAU!'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 20: Hoc vien chi duoc thi lai khi diem cua lan thi truoc do duoi 5
CREATE TRIGGER trg20_ketquathi_insert_update
ON KETQUATHI
AFTER INSERT
AS
BEGIN
	IF (EXISTS (SELECT * FROM KETQUATHI KQ, INSERTED I
						WHERE KQ.MAHV = I.MAHV AND KQ.MAMH = I.MAMH
								AND KQ.LANTHI < I.LANTHI AND KQ.DIEM >= 5))
		BEGIN 
			PRINT 'LOI: HOC VIEN CHI DUOC THI LAI KHI DIEM CUA LAN THI TRUOC DO DUOI 5'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 21: Ngay thi cua lan thi sau phai lon hon ngay thi cua lan thi truoc voi cung hoc vien cung mon hoc
CREATE TRIGGER trg21_ketquathi_insert_update
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	IF (EXISTS (SELECT * FROM KETQUATHI KQ, INSERTED I
						WHERE KQ.MAHV = I.MAHV AND KQ.MAMH = I.MAMH
								AND I.LANTHI > KQ.LANTHI AND I.NGTHI < KQ.NGTHI))
		BEGIN
			PRINT 'LOI: NGAY THI CUA LAN THI SAU PHAI LON HON NGAY THI CUA LAN THI TRUOC!'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 22: Hoc vien chi duoc thi nhung mon ma lop do da hoc xong
-- 22.1 trigger insert, update ngay thi KETQUATHI
CREATE TRIGGER trg22_ketquathi_insert_update
ON KETQUATHI
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @NGTHI smalldatetime, @NGKT smalldatetime, @MAHV varchar(4), @MALOP varchar(4)
	SELECT @NGTHI = I.NGTHI, @NGKT = GD.DENNGAY, @MAHV = I.MAHV, @MALOP = GD.MALOP 
		FROM INSERTED I, GIANGDAY GD, HOCVIEN HV 
			WHERE HV.MAHV = I.MAHV AND HV.MALOP = GD.MALOP AND I.MAMH = GD.MAMH
	IF(@NGTHI < @NGKT)
		BEGIN
			PRINT 'LOI: NGAY THI PHAI LON HON HOAC BANG NGAY KET THUC MON'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 22.2 trigger update ngay ket thuc GIANGDAY
CREATE TRIGGER trg22_giangday_update
ON GIANGDAY
AFTER UPDATE
AS
IF (UPDATE(DENNGAY))
BEGIN
	DECLARE @NGTHI smalldatetime, @NGKT smalldatetime, @MAHV varchar(4), @MALOP varchar(4)
	SELECT @NGTHI = KQ.NGTHI, @NGKT = I.DENNGAY, @MAHV = KQ.MAHV, @MALOP = I.MALOP
		FROM INSERTED I, KETQUATHI KQ, HOCVIEN HV
			WHERE HV.MAHV = KQ.MAHV AND HV.MALOP = I.MALOP AND KQ.MAMH = I.MAMH
	IF(@NGTHI < @NGKT)
		BEGIN
			PRINT 'LOI: NGAY THI PHAI LON HON HOAC BANG NGAY KET THUC MON'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 23: Khi phan cong giang day phai luu y thu tu truoc sau giua cac mon hoc.
CREATE TRIGGER trg23_giangday_insert_update
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MAMH_TRUOC varchar(10)
	SELECT @MAMH_TRUOC = DK.MAMH_TRUOC FROM DIEUKIEN DK, INSERTED I
			WHERE DK.MAMH = I.MAMH
	IF (NOT EXISTS (SELECT * FROM GIANGDAY GD, INSERTED I
							WHERE GD.MALOP = I.MALOP AND GD.MAMH = @MAMH_TRUOC))
		BEGIN
			PRINT 'LOI: PHAN CONG GIANG DAY SAI THU TU TRUOC SAU CUA DIEU KIEN MON HOC'
			ROLLBACK TRANSACTION
		END
	ELSE 
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- Cau 24: Giao vien chi duoc phan cong day nhung mon thuoc khoa giao vien do phu trach
-- 24.1: trigger insert, update GIANGDAY
CREATE TRIGGER trg24_giangday_insert_update
ON GIANGDAY
AFTER INSERT, UPDATE
AS
BEGIN
	IF (EXISTS (SELECT * FROM MONHOC MH, GIAOVIEN GV, INSERTED I
						WHERE I.MAGV = GV.MAGV AND I.MAMH = MH.MAMH
								AND MH.MAKHOA <> GV.MAKHOA))
		BEGIN
			PRINT 'LOI: GIAO VIEN CHI DUOC PHAN CONG DAY NHUNG MON THUOC KHOA GIAO VIEN DO PHU TRACH'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 24.2: trigger update MONHOC
CREATE TRIGGER trg24_monhoc_update
ON MONHOC
AFTER UPDATE
AS
BEGIN
	IF (EXISTS (SELECT * FROM GIANGDAY GD, GIAOVIEN GV, INSERTED I
						WHERE I.MAMH = GD.MAMH AND GD.MAGV = GV.MAGV AND GV.MAKHOA <> I.MAKHOA))
		BEGIN
			PRINT 'LOI: GIAO VIEN CHI DUOC PHAN CONG DAY NHUNG MON THUOC KHOA GIAO VIEN DO PHU TRACH'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END
-- 24.3: trigger update GIAOVIEN
CREATE TRIGGER trg24_giaovien_update
ON GIAOVIEN
AFTER UPDATE
AS
BEGIN
	IF (EXISTS (SELECT * FROM GIANGDAY GD, MONHOC MH, INSERTED I
						WHERE I.MAGV = GD.MAGV AND GD.MAMH = MH.MAMH AND I.MAKHOA <> MH.MAKHOA))
		BEGIN
			PRINT 'LOI: GIAO VIEN CHI DUOC PHAN CONG DAY NHUNG MON THUOC KHOA GIAO VIEN DO PHU TRACH'
			ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			PRINT 'THAO TAC THANH CONG'
		END
END