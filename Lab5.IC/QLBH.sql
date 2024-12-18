--11--
CREATE TRIGGER TRG_INS_NGHD 
ON dbo.HOADON
FOR INSERT
AS
BEGIN
	DECLARE @MaKH CHAR(10), @NgayHD smalldatetime, @NgayDK smalldatetime

	SELECT @NgayHD = NGHD, @MaKH = MAKH
	FROM inserted

	SELECT @NgayDK = NGDK
	FROM dbo.KHACHHANG
	WHERE @MaKH = MAKH

	IF (@NgayHD < @NgayDK)
		BEGIN 
			PRINT N'Ngày mua hàng không hợp lệ'
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			PRINT N'Thêm một hóa đơn thành công'
		END
END 
GO

--12--
CREATE TRIGGER TRG_INS_UPD_NGHD_NV
ON dbo.HOADON
FOR INSERT, UPDATE 
AS 
BEGIN
	DECLARE @MaNV CHAR(10), @NgayBH smalldatetime, @NgayVL char(10)

	SELECT @NgayBH = NGHD, @MaNV = MANV
	FROM inserted

	SELECT @NgayVL = NGVL 
	FROM dbo.NHANVIEN
	WHERE MANV = @MaNV

	IF (@NgayBH < @NgayVL)
		BEGIN
			PRINT N'Ngày bán hàng không hợp lệ'
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			PRINT N'Thêm 1 hóa đơn thành công'
		END
END 
GO

--13--
CREATE TRIGGER TRG_UPD_TRIGIA 
ON dbo.CTHD
FOR INSERT
AS
BEGIN
	DECLARE @TongTien INT, @SoHD CHAR(10)

	SELECT @TongTien = SUM(SL * GIA), @SoHD = SOHD
	FROM inserted
	JOIN dbo.SANPHAM AS SP ON inserted.MASP = SP.MASP
	GROUP BY SOHD

	UPDATE dbo.HOADON
	SET TRIGIA += @TongTien
	WHERE SOHD = @SoHD
END
GO

CREATE TRIGGER TRG_DEL_TRIGIA
ON dbo.CTHD
FOR DELETE
AS 
BEGIN
	DECLARE @Tien INT, @SoHD CHAR(10)

	SELECT @SoHD = SOHD, @Tien = SL * GIA
	FROM deleted JOIN dbo.SANPHAM AS SP
	ON SP.MASP = deleted.MASP

	UPDATE HOADON
	SET TRIGIA -= @Tien
	WHERE SOHD = @SoHD
END 
GO

--14--
CREATE TRIGGER TRG_INS_UPD_DoanhSo 
ON dbo.HOADON
FOR INSERT, UPDATE
AS 
BEGIN
	DECLARE @DoanhSo INT, @MaKH CHAR(10)

	SELECT @MaKH = MAKH, @DoanhSo = SUM(TRIGIA)
	FROM inserted
	GROUP BY MAKH

	UPDATE dbo.KHACHHANG
	SET DOANHSO += @DoanhSo
	WHERE MAKH = @MaKH
END
GO