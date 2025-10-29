	/* =========================================================
	Activewear Store - SQL Server DDL & Seed (DATN) - COMPLETE VERSION FIXED
	Target: SQL Server 2019+
	Tính chất: Idempotent (chạy nhiều lần không lỗi, không trùng)
	Compatible với mọi máy SQL Server
	Bao gồm đầy đủ 32 bảng và tất cả chức năng
	ĐÃ SỬA LỖI CASCADE PATH CONFLICT
	========================================================= */

	----------------------------------------------------------
	-- 0) CREATE DATABASE (nếu chưa có)
	----------------------------------------------------------
	IF DB_ID(N'DATN') IS NULL
	BEGIN
		CREATE DATABASE DATN;
		PRINT N'✅ Database DATN đã được tạo.';
	END
	ELSE
	BEGIN
		PRINT N'ℹ️ Database DATN đã tồn tại — sẽ sử dụng DB hiện có.';
	END
	GO

	USE DATN;
	GO

	SET ANSI_NULLS ON;
	SET QUOTED_IDENTIFIER ON;
	SET NOCOUNT ON;
	GO

	----------------------------------------------------------
	-- 1) TABLES (32 bảng đầy đủ)
	----------------------------------------------------------

	-- 1.1 Vai trò
	IF OBJECT_ID(N'dbo.vai_tro',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[vai_tro](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten_vai_tro] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](255) NULL,
		[quyen_han] [nvarchar](max) NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_vai_tro] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_vai_tro_ten] UNIQUE NONCLUSTERED ([ten_vai_tro] ASC)
	);
	PRINT N'✅ Tạo dbo.vai_tro';
	END

	-- 1.2 Danh mục
	IF OBJECT_ID(N'dbo.danh_muc',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[danh_muc](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[slug] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[hinh_anh] [nvarchar](500) NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[hien_thi_trang_chu] [bit] NOT NULL DEFAULT (0),
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_danh_muc] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_danh_muc_slug] UNIQUE NONCLUSTERED ([slug] ASC)
	);
	PRINT N'✅ Tạo dbo.danh_muc';
	END

	-- 1.3 Thương hiệu
	IF OBJECT_ID(N'dbo.thuong_hieu',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[thuong_hieu](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[slug] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[hinh_anh] [nvarchar](500) NULL,
		[quoc_gia] [nvarchar](100) NULL,
		[website] [nvarchar](255) NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[hien_thi_trang_chu] [bit] NOT NULL DEFAULT (0),
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_thuong_hieu] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_thuong_hieu_slug] UNIQUE NONCLUSTERED ([slug] ASC)
	);
	PRINT N'✅ Tạo dbo.thuong_hieu';
	END

	-- 1.4 Danh mục môn thể thao
	IF OBJECT_ID(N'dbo.danh_muc_mon_the_thao',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[danh_muc_mon_the_thao](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[slug] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[hinh_anh] [nvarchar](500) NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[hien_thi_trang_chu] [bit] NOT NULL DEFAULT (0),
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_danh_muc_mon_the_thao] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_danh_muc_mon_the_thao_slug] UNIQUE NONCLUSTERED ([slug] ASC)
	);
	PRINT N'✅ Tạo dbo.danh_muc_mon_the_thao';
	END

	-- 1.5 Sản phẩm (bảng chính)
	IF OBJECT_ID(N'dbo.san_pham',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[san_pham](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ma_san_pham] [nvarchar](255) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[slug] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](max) NULL,
		[mo_ta_ngan] [nvarchar](500) NULL,
		[gia] [decimal](19, 4) NULL,
		[gia_goc] [decimal](19, 4) NULL,
		[anh_chinh] [nvarchar](255) NULL,
		[so_luong_ton] [int] NOT NULL DEFAULT (0),
		[chat_lieu] [nvarchar](255) NULL,
		[xuat_xu] [nvarchar](255) NULL,
		[trong_luong] [decimal](10, 2) NULL,
		[kich_thuoc] [nvarchar](100) NULL,
		[size_guide] [nvarchar](max) NULL,
		[luot_xem] [int] NOT NULL DEFAULT (0),
		[da_ban] [int] NOT NULL DEFAULT (0),
		[diem_trung_binh] [decimal](3, 2) NULL,
		[so_danh_gia] [int] NOT NULL DEFAULT (0),
		[id_danh_muc] [bigint] NULL,
		[id_thuong_hieu] [bigint] NULL,
		[id_mon_the_thao] [bigint] NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[noi_bat] [bit] NOT NULL DEFAULT (0),
		[ban_chay] [bit] NOT NULL DEFAULT (0),
		[moi_ve] [bit] NOT NULL DEFAULT (0),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
	CONSTRAINT [PK_san_pham] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_san_pham_slug] UNIQUE NONCLUSTERED ([slug] ASC),
	CONSTRAINT [UQ_san_pham_ma] UNIQUE NONCLUSTERED ([ma_san_pham] ASC)
	);
	PRINT N'✅ Tạo dbo.san_pham';
	END

	-- 1.6 Ảnh sản phẩm
	IF OBJECT_ID(N'dbo.anh_san_pham',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[anh_san_pham](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[url_anh] [nvarchar](255) NOT NULL,
		[la_anh_chinh] [bit] NOT NULL DEFAULT (0),
		[thu_tu] [int] NULL,
		[ngay_them] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_anh_san_pham] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.anh_san_pham';
	END

	-- 1.7 Biến thể sản phẩm
	IF OBJECT_ID(N'dbo.bien_the_san_pham',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[bien_the_san_pham](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[ma_sku] [nvarchar](100) NOT NULL,
		[kich_co] [nvarchar](10) NULL,
		[mau_sac] [nvarchar](50) NULL,
		[so_luong] [int] NOT NULL DEFAULT (0),
		[gia_ban] [decimal](19, 4) NULL,
		[gia_khuyen_mai] [decimal](19, 4) NULL,
		[anh_bien_the] [nvarchar](255) NULL,
		[mau_sac_hex] [nvarchar](7) NULL,
		[trong_luong] [decimal](10, 2) NULL,
		[trang_thai] [bit] NOT NULL DEFAULT (1),
		[hien_thi] [bit] NOT NULL DEFAULT (1),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
		[so_luong_ton] [int] NOT NULL DEFAULT (0),
	CONSTRAINT [PK_bien_the_san_pham] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_bien_the_sku] UNIQUE NONCLUSTERED ([ma_sku] ASC)
	);
	PRINT N'✅ Tạo dbo.bien_the_san_pham';
	END

	-- 1.8 Người dùng
	IF OBJECT_ID(N'dbo.nguoi_dung',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[nguoi_dung](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[email] [nvarchar](255) NOT NULL,
		[mat_khau] [nvarchar](255) NOT NULL,
		[so_dien_thoai] [nvarchar](20) NULL,
		[so_dien_thoai_2] [nvarchar](20) NULL,
		[ngay_sinh] [date] NULL,
		[gioi_tinh] [nvarchar](10) NULL,
		[dia_chi] [nvarchar](500) NULL,
		[hinh_dai_dien] [nvarchar](255) NULL,
		[vai_tro_id] [bigint] NOT NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[email_verified] [bit] NOT NULL DEFAULT (0),
		[ngay_dang_ky] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_nguoi_dung] PRIMARY KEY CLUSTERED ([id] ASC),
	-- CONSTRAINT [UQ_nguoi_dung_email] UNIQUE NONCLUSTERED ([email] ASC) -- Bỏ unique trên email gốc, chỉ dùng email_lc
	);
	PRINT N'✅ Tạo dbo.nguoi_dung';
	END

	-- 1.9 Địa chỉ
	IF OBJECT_ID(N'dbo.dia_chi',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[dia_chi](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[ten_nguoi_nhan] [nvarchar](255) NOT NULL,
		[so_dien_thoai] [nvarchar](20) NOT NULL,
		[dia_chi_chi_tiet] [nvarchar](500) NOT NULL,
		[tinh_thanh] [nvarchar](100) NOT NULL,
		[quan_huyen] [nvarchar](100) NOT NULL,
		[phuong_xa] [nvarchar](100) NOT NULL,
		[la_dia_chi_mac_dinh] [bit] NOT NULL DEFAULT (0),
		[ghi_chu] [nvarchar](500) NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_dia_chi] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.dia_chi';
	END

	-- 1.10 Giỏ hàng
	IF OBJECT_ID(N'dbo.gio_hang',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[gio_hang](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_gio_hang] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_gio_hang_nguoi_dung] UNIQUE NONCLUSTERED ([nguoi_dung_id] ASC)
	);
	PRINT N'✅ Tạo dbo.gio_hang';
	END

	-- 1.11 Chi tiết giỏ hàng
	IF OBJECT_ID(N'dbo.chi_tiet_gio_hang',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[chi_tiet_gio_hang](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[gio_hang_id] [bigint] NOT NULL,
		[san_pham_id] [bigint] NOT NULL,
		[so_luong] [int] NOT NULL DEFAULT (1),
		[gia_ban] [decimal](19, 4) NOT NULL,
		[kich_thuoc] [nvarchar](50) NULL,
		[mau_sac] [nvarchar](50) NULL,
		[ngay_them] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_chi_tiet_gio_hang] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.chi_tiet_gio_hang';
	END

	-- 1.12 Đơn hàng
	IF OBJECT_ID(N'dbo.don_hang',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[don_hang](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ma_don_hang] [nvarchar](50) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[tong_tien] [decimal](19, 4) NOT NULL,
		[phi_van_chuyen] [decimal](19, 4) NOT NULL DEFAULT (0),
		[tong_thanh_toan] [decimal](19, 4) NOT NULL,
		[trang_thai] [nvarchar](50) NOT NULL DEFAULT (N'CHO_XAC_NHAN'),
		[phuong_thuc_thanh_toan] [nvarchar](50) NOT NULL DEFAULT (N'COD'),
		[ten_nguoi_nhan] [nvarchar](255) NOT NULL,
		[so_dien_thoai] [nvarchar](20) NOT NULL,
		[dia_chi_giao_hang] [nvarchar](500) NOT NULL,
		[ghi_chu] [nvarchar](500) NULL,
		[ngay_dat_hang] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_giao_hang] [datetime2](0) NULL,
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_don_hang] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_don_hang_ma] UNIQUE NONCLUSTERED ([ma_don_hang] ASC)
	);
	PRINT N'✅ Tạo dbo.don_hang';
	END

	-- 1.13 Chi tiết đơn hàng
	IF OBJECT_ID(N'dbo.chi_tiet_don_hang',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[chi_tiet_don_hang](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[don_hang_id] [bigint] NOT NULL,
		[san_pham_id] [bigint] NOT NULL,
		[ten_san_pham] [nvarchar](255) NOT NULL,
		[so_luong] [int] NOT NULL,
		[gia_ban] [decimal](19, 4) NOT NULL,
		[thanh_tien] [decimal](19, 4) NOT NULL,
		[kich_thuoc] [nvarchar](50) NULL,
		[mau_sac] [nvarchar](50) NULL,
	CONSTRAINT [PK_chi_tiet_don_hang] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.chi_tiet_don_hang';
	END

	-- 1.14 Thanh toán
	IF OBJECT_ID(N'dbo.thanh_toan',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[thanh_toan](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[don_hang_id] [bigint] NOT NULL,
		[ma_giao_dich] [nvarchar](100) NOT NULL,
		[phuong_thuc] [nvarchar](50) NOT NULL,
		[so_tien] [decimal](19, 4) NOT NULL,
		[trang_thai] [nvarchar](50) NOT NULL,
		[thong_tin_them] [nvarchar](max) NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_thanh_toan] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_thanh_toan_ma_giao_dich] UNIQUE NONCLUSTERED ([ma_giao_dich] ASC)
	);
	PRINT N'✅ Tạo dbo.thanh_toan';
	END

	-- 1.15 Yêu thích
	IF OBJECT_ID(N'dbo.yeu_thich',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[yeu_thich](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[san_pham_id] [bigint] NOT NULL,
		[ngay_them] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_yeu_thich] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_yeu_thich_nguoi_dung_san_pham] UNIQUE NONCLUSTERED ([nguoi_dung_id] ASC, [san_pham_id] ASC)
	);
	PRINT N'✅ Tạo dbo.yeu_thich';
	END

	-- 1.16 Đánh giá
	IF OBJECT_ID(N'dbo.danh_gia',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[danh_gia](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[san_pham_id] [bigint] NOT NULL,
		[don_hang_id] [bigint] NULL,
		[diem] [int] NOT NULL,
		[noi_dung] [nvarchar](1000) NULL,
		[hinh_anh] [nvarchar](500) NULL,
		[trang_thai] [nvarchar](50) NOT NULL DEFAULT (N'CHO_DUYET'),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_danh_gia] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.danh_gia';
	END

	-- 1.17 Banner
	IF OBJECT_ID(N'dbo.banner',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[banner](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[hinh_anh] [nvarchar](500) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[link] [nvarchar](500) NULL,
		[vi_tri] [nvarchar](50) NOT NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_bat_dau] [datetime2](0) NULL,
		[ngay_ket_thuc] [datetime2](0) NULL,
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_banner] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.banner';
	END

	-- 1.18 Cấu hình
	IF OBJECT_ID(N'dbo.cau_hinh',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[cau_hinh](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[gia_tri] [nvarchar](max) NULL,
		[mo_ta] [nvarchar](500) NULL,
		[loai] [nvarchar](50) NOT NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_cau_hinh] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_cau_hinh_ten] UNIQUE NONCLUSTERED ([ten] ASC)
	);
	PRINT N'✅ Tạo dbo.cau_hinh';
	END

	-- 1.19 Khuyến mãi
	IF OBJECT_ID(N'dbo.khuyen_mai',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[khuyen_mai](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[loai] [nvarchar](50) NOT NULL,
		[gia_tri] [decimal](19, 4) NOT NULL,
		[ngay_bat_dau] [datetime2](0) NOT NULL,
		[ngay_ket_thuc] [datetime2](0) NOT NULL,
		[so_luong_su_dung] [int] NOT NULL DEFAULT (0),
		[so_luong_toi_da] [int] NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_khuyen_mai] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.khuyen_mai';
	END

	-- 1.20 Lịch sử giá
	IF OBJECT_ID(N'dbo.lich_su_gia',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[lich_su_gia](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[gia_cu] [decimal](19, 4) NULL,
		[gia_moi] [decimal](19, 4) NOT NULL,
		[nguoi_thay_doi] [bigint] NULL,
		[ly_do] [nvarchar](500) NULL,
		[loai_thay_doi] [nvarchar](50) NOT NULL,
		[ngay_thay_doi] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_lich_su_gia] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.lich_su_gia';
	END

	-- 1.21 Lịch sử tồn kho
	IF OBJECT_ID(N'dbo.lich_su_ton_kho',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[lich_su_ton_kho](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[so_luong_cu] [int] NOT NULL,
		[so_luong_moi] [int] NOT NULL,
		[so_luong_thay_doi] [int] NOT NULL,
		[nguoi_thay_doi] [bigint] NULL,
		[ly_do] [nvarchar](500) NULL,
		[loai_thay_doi] [nvarchar](50) NOT NULL,
		[ngay_thay_doi] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_lich_su_ton_kho] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.lich_su_ton_kho';
	END

	-- 1.22 Lịch sử xem
	IF OBJECT_ID(N'dbo.lich_su_xem',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[lich_su_xem](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NULL,
		[san_pham_id] [bigint] NOT NULL,
		[ip_address] [nvarchar](50) NULL,
		[user_agent] [nvarchar](500) NULL,
		[ngay_xem] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_lich_su_xem] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.lich_su_xem';
	END

	-- 1.23 Mã giảm giá
	IF OBJECT_ID(N'dbo.ma_giam_gia',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[ma_giam_gia](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ma] [nvarchar](50) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[loai] [nvarchar](50) NOT NULL,
		[gia_tri] [decimal](19, 4) NOT NULL,
		[ngay_bat_dau] [datetime2](0) NOT NULL,
		[ngay_ket_thuc] [datetime2](0) NOT NULL,
		[so_luong_su_dung] [int] NOT NULL DEFAULT (0),
		[so_luong_toi_da] [int] NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_ma_giam_gia] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_ma_giam_gia_ma] UNIQUE NONCLUSTERED ([ma] ASC)
	);
	PRINT N'✅ Tạo dbo.ma_giam_gia';
	END

	-- 1.24 Nhật ký admin
	IF OBJECT_ID(N'dbo.nhat_ky_admin',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[nhat_ky_admin](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[hanh_dong] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[duong_dan] [nvarchar](500) NULL,
		[ip_address] [nvarchar](50) NULL,
		[user_agent] [nvarchar](500) NULL,
		[ngay_thuc_hien] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_nhat_ky_admin] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.nhat_ky_admin';
	END

	-- 1.25 Nhóm sản phẩm
	IF OBJECT_ID(N'dbo.nhom_san_pham',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[nhom_san_pham](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](255) NOT NULL,
		[slug] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[hinh_anh] [nvarchar](500) NULL,
		[loai] [nvarchar](50) NOT NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[hien_thi_trang_chu] [bit] NOT NULL DEFAULT (0),
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_bat_dau] [datetime2](0) NULL,
		[ngay_ket_thuc] [datetime2](0) NULL,
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_nhom_san_pham] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_nhom_san_pham_slug] UNIQUE NONCLUSTERED ([slug] ASC)
	);
	PRINT N'✅ Tạo dbo.nhom_san_pham';
	END

	-- 1.26 OTP Token (Legacy - giữ lại để tương thích)
	IF OBJECT_ID(N'dbo.otp_token',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[otp_token](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NOT NULL,
		[token] [nvarchar](255) NOT NULL,
		[loai] [nvarchar](50) NOT NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_het_han] [datetime2](0) NOT NULL,
		[ip_address] [nvarchar](50) NULL,
		[user_agent] [nvarchar](500) NULL,
		[da_su_dung] [bit] NOT NULL DEFAULT (0),
		[ngay_su_dung] [datetime2](0) NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_otp_token] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_otp_token_token] UNIQUE NONCLUSTERED ([token] ASC)
	);
	PRINT N'✅ Tạo dbo.otp_token';
	END

	-- 1.26.1 OTP Verification (Bảng mới - chi tiết hơn với bảo mật)
	IF OBJECT_ID(N'dbo.otp_verification',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[otp_verification](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[email] [nvarchar](255) NOT NULL,
		[otp_hash] [nvarchar](255) NOT NULL, -- Hash của OTP thay vì lưu rõ
		[otp_salt] [nvarchar](255) NOT NULL, -- Salt để hash OTP
		[type] [nvarchar](50) NOT NULL DEFAULT (N'REGISTRATION'),
		[expires_at] [datetime2](0) NOT NULL,
		[is_used] [bit] NOT NULL DEFAULT (0),
		[attempts] [int] NOT NULL DEFAULT (0),
		[max_attempts] [int] NOT NULL DEFAULT (3),
		[ip_address] [nvarchar](50) NULL,
		[user_agent] [nvarchar](500) NULL,
		[nguoi_dung_id] [bigint] NULL,
		[created_at] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[used_at] [datetime2](0) NULL,
	CONSTRAINT [PK_otp_verification] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.otp_verification';
	END

	-- 1.27 Sản phẩm khuyến mãi
	IF OBJECT_ID(N'dbo.san_pham_khuyen_mai',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[san_pham_khuyen_mai](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[id_khuyen_mai] [bigint] NOT NULL,
		[gia_khuyen_mai] [decimal](19, 4) NULL,
		[ngay_bat_dau] [datetime2](0) NOT NULL,
		[ngay_ket_thuc] [datetime2](0) NOT NULL,
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
		[ghi_chu] [nvarchar](500) NULL,
	CONSTRAINT [PK_san_pham_khuyen_mai] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.san_pham_khuyen_mai';
	END

	-- 1.28 Sản phẩm liên quan
	IF OBJECT_ID(N'dbo.san_pham_lien_quan',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[san_pham_lien_quan](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[id_san_pham_lien_quan] [bigint] NOT NULL,
		[loai] [nvarchar](50) NOT NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[tu_dong] [bit] NOT NULL DEFAULT (0),
		[do_lien_quan] [decimal](5, 4) NULL,
		[ngay_them] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_san_pham_lien_quan] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.san_pham_lien_quan';
	END

	-- 1.29 Sản phẩm nhóm
	IF OBJECT_ID(N'dbo.san_pham_nhom',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[san_pham_nhom](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[id_nhom] [bigint] NOT NULL,
		[thu_tu] [int] NOT NULL DEFAULT (0),
		[ngay_them] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_san_pham_nhom] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.san_pham_nhom';
	END

	-- 1.30 Sản phẩm tag
	IF OBJECT_ID(N'dbo.san_pham_tag',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[san_pham_tag](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[id_san_pham] [bigint] NOT NULL,
		[id_tag] [bigint] NOT NULL,
		[ngay_them] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_san_pham_tag] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.san_pham_tag';
	END

	-- 1.31 Tag
	IF OBJECT_ID(N'dbo.tag',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[tag](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten] [nvarchar](100) NOT NULL,
		[slug] [nvarchar](100) NOT NULL,
		[mau_sac] [nvarchar](50) NULL,
		[mo_ta] [nvarchar](255) NULL,
		[so_luong_su_dung] [int] NOT NULL DEFAULT (0),
		[hoat_dong] [bit] NOT NULL DEFAULT (1),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_tag] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [UQ_tag_slug] UNIQUE NONCLUSTERED ([slug] ASC)
	);
	PRINT N'✅ Tạo dbo.tag';
	END

	-- 1.32 Thông báo
	IF OBJECT_ID(N'dbo.thong_bao',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[thong_bao](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NULL,
		[tieu_de] [nvarchar](255) NOT NULL,
		[noi_dung] [nvarchar](1000) NOT NULL,
		[loai] [nvarchar](50) NOT NULL,
		[da_doc] [bit] NOT NULL DEFAULT (0),
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_thong_bao] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.thong_bao';
	END

	----------------------------------------------------------
	-- 1.33) CÁC BẢNG MỚI CHO WEBSITE BÁN QUẦN ÁO THỂ THAO
	----------------------------------------------------------

	-- 1.33.1 Kho hàng
	IF OBJECT_ID(N'dbo.kho_hang',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[kho_hang](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten_kho] [nvarchar](255) NOT NULL,
		[dia_chi] [nvarchar](500) NOT NULL,
		[so_dien_thoai] [nvarchar](20) NULL,
		[nguoi_quan_ly] [nvarchar](255) NULL,
		[trang_thai] [bit] NOT NULL DEFAULT (1),
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_kho_hang] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.kho_hang';
	END

	-- 1.33.2 Vận chuyển
	IF OBJECT_ID(N'dbo.van_chuyen',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[van_chuyen](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ten_don_vi] [nvarchar](255) NOT NULL,
		[mo_ta] [nvarchar](1000) NULL,
		[gia_van_chuyen] [decimal](19, 4) NOT NULL DEFAULT (0),
		[thoi_gian_giao_hang] [nvarchar](100) NULL,
		[trang_thai] [bit] NOT NULL DEFAULT (1),
		[nguoi_tao] [bigint] NULL,
		[nguoi_cap_nhat] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
		[ngay_cap_nhat] [datetime2](0) NULL,
	CONSTRAINT [PK_van_chuyen] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.van_chuyen';
	END

	-- 1.33.3 Chat hỗ trợ
	IF OBJECT_ID(N'dbo.chat_support',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[chat_support](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[nguoi_dung_id] [bigint] NULL,
		[nhan_vien_id] [bigint] NULL,
		[noi_dung] [nvarchar](max) NOT NULL,
		[loai_tin_nhan] [nvarchar](50) NOT NULL DEFAULT (N'USER'),
		[trang_thai] [nvarchar](50) NOT NULL DEFAULT (N'CHO_XU_LY'),
		[ngay_gui] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_chat_support] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.chat_support';
	END

	-- 1.33.4 Thống kê bán hàng
	IF OBJECT_ID(N'dbo.thong_ke',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[thong_ke](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[ngay] [date] NOT NULL,
		[loai_thong_ke] [nvarchar](50) NOT NULL,
		[gia_tri] [decimal](19, 4) NOT NULL,
		[so_luong] [int] NOT NULL DEFAULT (0),
		[mo_ta] [nvarchar](500) NULL,
		-- Thêm các cột liên kết
		[san_pham_id] [bigint] NULL,
		[danh_muc_id] [bigint] NULL,
		[thuong_hieu_id] [bigint] NULL,
		[don_hang_id] [bigint] NULL,
		[nguoi_dung_id] [bigint] NULL,
		[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_thong_ke] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.thong_ke';
	END

	-- 1.33.5 Lịch sử áp dụng khuyến mãi
	IF OBJECT_ID(N'dbo.khuyen_mai_ap_dung',N'U') IS NULL
	BEGIN
	CREATE TABLE [dbo].[khuyen_mai_ap_dung](
		[id] [bigint] IDENTITY(1,1) NOT NULL,
		[don_hang_id] [bigint] NOT NULL,
		[khuyen_mai_id] [bigint] NULL,
		[ma_giam_gia_id] [bigint] NULL,
		[so_tien_giam] [decimal](19, 4) NOT NULL,
		[ngay_ap_dung] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	CONSTRAINT [PK_khuyen_mai_ap_dung] PRIMARY KEY CLUSTERED ([id] ASC)
	);
	PRINT N'✅ Tạo dbo.khuyen_mai_ap_dung';
	END

	----------------------------------------------------------
	-- 2) FOREIGN KEY CONSTRAINTS (ĐÃ SỬA LỖI CASCADE)
	----------------------------------------------------------

	-- San pham foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_danh_muc')
		ALTER TABLE dbo.san_pham ADD CONSTRAINT FK_san_pham_danh_muc 
		FOREIGN KEY (id_danh_muc) REFERENCES dbo.danh_muc(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_thuong_hieu')
		ALTER TABLE dbo.san_pham ADD CONSTRAINT FK_san_pham_thuong_hieu 
		FOREIGN KEY (id_thuong_hieu) REFERENCES dbo.thuong_hieu(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_mon_the_thao')
		ALTER TABLE dbo.san_pham ADD CONSTRAINT FK_san_pham_mon_the_thao 
		FOREIGN KEY (id_mon_the_thao) REFERENCES dbo.danh_muc_mon_the_thao(id);

	-- Anh san pham foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_anh_san_pham_san_pham')
		ALTER TABLE dbo.anh_san_pham ADD CONSTRAINT FK_anh_san_pham_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Bien the san pham foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_bien_the_san_pham_san_pham')
		ALTER TABLE dbo.bien_the_san_pham ADD CONSTRAINT FK_bien_the_san_pham_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Nguoi dung foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_nguoi_dung_vai_tro')
		ALTER TABLE dbo.nguoi_dung ADD CONSTRAINT FK_nguoi_dung_vai_tro 
		FOREIGN KEY (vai_tro_id) REFERENCES dbo.vai_tro(id);

	-- Dia chi foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_dia_chi_nguoi_dung')
		ALTER TABLE dbo.dia_chi ADD CONSTRAINT FK_dia_chi_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	-- Gio hang foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_gio_hang_nguoi_dung')
		ALTER TABLE dbo.gio_hang ADD CONSTRAINT FK_gio_hang_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	-- Chi tiet gio hang foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_chi_tiet_gio_hang_gio_hang')
		ALTER TABLE dbo.chi_tiet_gio_hang ADD CONSTRAINT FK_chi_tiet_gio_hang_gio_hang 
		FOREIGN KEY (gio_hang_id) REFERENCES dbo.gio_hang(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_chi_tiet_gio_hang_san_pham')
		ALTER TABLE dbo.chi_tiet_gio_hang ADD CONSTRAINT FK_chi_tiet_gio_hang_san_pham 
		FOREIGN KEY (san_pham_id) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Don hang foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_don_hang_nguoi_dung')
		ALTER TABLE dbo.don_hang ADD CONSTRAINT FK_don_hang_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id);

	-- Chi tiet don hang foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_chi_tiet_don_hang_don_hang')
		ALTER TABLE dbo.chi_tiet_don_hang ADD CONSTRAINT FK_chi_tiet_don_hang_don_hang 
		FOREIGN KEY (don_hang_id) REFERENCES dbo.don_hang(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_chi_tiet_don_hang_san_pham')
		ALTER TABLE dbo.chi_tiet_don_hang ADD CONSTRAINT FK_chi_tiet_don_hang_san_pham 
		FOREIGN KEY (san_pham_id) REFERENCES dbo.san_pham(id);

	-- Thanh toan foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thanh_toan_don_hang')
		ALTER TABLE dbo.thanh_toan ADD CONSTRAINT FK_thanh_toan_don_hang 
		FOREIGN KEY (don_hang_id) REFERENCES dbo.don_hang(id);

	-- Yeu thich foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_yeu_thich_nguoi_dung')
		ALTER TABLE dbo.yeu_thich ADD CONSTRAINT FK_yeu_thich_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_yeu_thich_san_pham')
		ALTER TABLE dbo.yeu_thich ADD CONSTRAINT FK_yeu_thich_san_pham 
		FOREIGN KEY (san_pham_id) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Danh gia foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_danh_gia_nguoi_dung')
		ALTER TABLE dbo.danh_gia ADD CONSTRAINT FK_danh_gia_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_danh_gia_san_pham')
		ALTER TABLE dbo.danh_gia ADD CONSTRAINT FK_danh_gia_san_pham 
		FOREIGN KEY (san_pham_id) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_danh_gia_don_hang')
		ALTER TABLE dbo.danh_gia ADD CONSTRAINT FK_danh_gia_don_hang 
		FOREIGN KEY (don_hang_id) REFERENCES dbo.don_hang(id);

	-- Lich su gia foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_lich_su_gia_san_pham')
		ALTER TABLE dbo.lich_su_gia ADD CONSTRAINT FK_lich_su_gia_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Lich su ton kho foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_lich_su_ton_kho_san_pham')
		ALTER TABLE dbo.lich_su_ton_kho ADD CONSTRAINT FK_lich_su_ton_kho_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Lich su xem foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_lich_su_xem_nguoi_dung')
		ALTER TABLE dbo.lich_su_xem ADD CONSTRAINT FK_lich_su_xem_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_lich_su_xem_san_pham')
		ALTER TABLE dbo.lich_su_xem ADD CONSTRAINT FK_lich_su_xem_san_pham 
		FOREIGN KEY (san_pham_id) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	-- Nhat ky admin foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_nhat_ky_admin_nguoi_dung')
		ALTER TABLE dbo.nhat_ky_admin ADD CONSTRAINT FK_nhat_ky_admin_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	-- OTP token foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_otp_token_nguoi_dung')
		ALTER TABLE dbo.otp_token ADD CONSTRAINT FK_otp_token_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	-- OTP verification foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_otp_verification_nguoi_dung')
		ALTER TABLE dbo.otp_verification ADD CONSTRAINT FK_otp_verification_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	-- OTP verification indexes
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_otp_verification_email_type' AND object_id = OBJECT_ID('dbo.otp_verification'))
		CREATE NONCLUSTERED INDEX [IX_otp_verification_email_type] ON [dbo].[otp_verification] ([email], [type]);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_otp_verification_expires_at' AND object_id = OBJECT_ID('dbo.otp_verification'))
		CREATE NONCLUSTERED INDEX [IX_otp_verification_expires_at] ON [dbo].[otp_verification] ([expires_at]);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_otp_verification_created_at' AND object_id = OBJECT_ID('dbo.otp_verification'))
		CREATE NONCLUSTERED INDEX [IX_otp_verification_created_at] ON [dbo].[otp_verification] ([created_at]);

	-- San pham khuyen mai foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_khuyen_mai_san_pham')
		ALTER TABLE dbo.san_pham_khuyen_mai ADD CONSTRAINT FK_san_pham_khuyen_mai_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_khuyen_mai_khuyen_mai')
		ALTER TABLE dbo.san_pham_khuyen_mai ADD CONSTRAINT FK_san_pham_khuyen_mai_khuyen_mai 
		FOREIGN KEY (id_khuyen_mai) REFERENCES dbo.khuyen_mai(id) ON DELETE CASCADE;

	-- San pham lien quan foreign keys (ĐÃ SỬA LỖI CASCADE)
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_lien_quan_san_pham')
		ALTER TABLE dbo.san_pham_lien_quan ADD CONSTRAINT FK_san_pham_lien_quan_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE NO ACTION;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_lien_quan_san_pham_lien_quan')
		ALTER TABLE dbo.san_pham_lien_quan ADD CONSTRAINT FK_san_pham_lien_quan_san_pham_lien_quan 
		FOREIGN KEY (id_san_pham_lien_quan) REFERENCES dbo.san_pham(id) ON DELETE NO ACTION;

	-- San pham nhom foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_nhom_san_pham')
		ALTER TABLE dbo.san_pham_nhom ADD CONSTRAINT FK_san_pham_nhom_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_nhom_nhom')
		ALTER TABLE dbo.san_pham_nhom ADD CONSTRAINT FK_san_pham_nhom_nhom 
		FOREIGN KEY (id_nhom) REFERENCES dbo.nhom_san_pham(id) ON DELETE CASCADE;

	-- San pham tag foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_tag_san_pham')
		ALTER TABLE dbo.san_pham_tag ADD CONSTRAINT FK_san_pham_tag_san_pham 
		FOREIGN KEY (id_san_pham) REFERENCES dbo.san_pham(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_tag_tag')
		ALTER TABLE dbo.san_pham_tag ADD CONSTRAINT FK_san_pham_tag_tag 
		FOREIGN KEY (id_tag) REFERENCES dbo.tag(id) ON DELETE CASCADE;

	-- Thong bao foreign key
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thong_bao_nguoi_dung')
		ALTER TABLE dbo.thong_bao ADD CONSTRAINT FK_thong_bao_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	-- Banner foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_banner_nguoi_tao')
		ALTER TABLE dbo.banner ADD CONSTRAINT FK_banner_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_banner_nguoi_cap_nhat')
		ALTER TABLE dbo.banner ADD CONSTRAINT FK_banner_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Ma giam gia foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ma_giam_gia_nguoi_tao')
		ALTER TABLE dbo.ma_giam_gia ADD CONSTRAINT FK_ma_giam_gia_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ma_giam_gia_nguoi_cap_nhat')
		ALTER TABLE dbo.ma_giam_gia ADD CONSTRAINT FK_ma_giam_gia_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Cau hinh foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_cau_hinh_nguoi_tao')
		ALTER TABLE dbo.cau_hinh ADD CONSTRAINT FK_cau_hinh_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_cau_hinh_nguoi_cap_nhat')
		ALTER TABLE dbo.cau_hinh ADD CONSTRAINT FK_cau_hinh_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Khuyen mai foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_khuyen_mai_nguoi_tao')
		ALTER TABLE dbo.khuyen_mai ADD CONSTRAINT FK_khuyen_mai_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_khuyen_mai_nguoi_cap_nhat')
		ALTER TABLE dbo.khuyen_mai ADD CONSTRAINT FK_khuyen_mai_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Nhom san pham foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_nhom_san_pham_nguoi_tao')
		ALTER TABLE dbo.nhom_san_pham ADD CONSTRAINT FK_nhom_san_pham_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_nhom_san_pham_nguoi_cap_nhat')
		ALTER TABLE dbo.nhom_san_pham ADD CONSTRAINT FK_nhom_san_pham_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- San pham khuyen mai foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_khuyen_mai_nguoi_tao')
		ALTER TABLE dbo.san_pham_khuyen_mai ADD CONSTRAINT FK_san_pham_khuyen_mai_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_san_pham_khuyen_mai_nguoi_cap_nhat')
		ALTER TABLE dbo.san_pham_khuyen_mai ADD CONSTRAINT FK_san_pham_khuyen_mai_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Kho hang foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_kho_hang_nguoi_tao')
		ALTER TABLE dbo.kho_hang ADD CONSTRAINT FK_kho_hang_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_kho_hang_nguoi_cap_nhat')
		ALTER TABLE dbo.kho_hang ADD CONSTRAINT FK_kho_hang_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Van chuyen foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_van_chuyen_nguoi_tao')
		ALTER TABLE dbo.van_chuyen ADD CONSTRAINT FK_van_chuyen_nguoi_tao 
		FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_van_chuyen_nguoi_cap_nhat')
		ALTER TABLE dbo.van_chuyen ADD CONSTRAINT FK_van_chuyen_nguoi_cap_nhat 
		FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Chat support foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_chat_support_nguoi_dung')
		ALTER TABLE dbo.chat_support ADD CONSTRAINT FK_chat_support_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_chat_support_nhan_vien')
		ALTER TABLE dbo.chat_support ADD CONSTRAINT FK_chat_support_nhan_vien 
		FOREIGN KEY (nhan_vien_id) REFERENCES dbo.nguoi_dung(id);

	-- Khuyen mai ap dung foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_khuyen_mai_ap_dung_don_hang')
		ALTER TABLE dbo.khuyen_mai_ap_dung ADD CONSTRAINT FK_khuyen_mai_ap_dung_don_hang 
		FOREIGN KEY (don_hang_id) REFERENCES dbo.don_hang(id) ON DELETE CASCADE;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_khuyen_mai_ap_dung_khuyen_mai')
		ALTER TABLE dbo.khuyen_mai_ap_dung ADD CONSTRAINT FK_khuyen_mai_ap_dung_khuyen_mai 
		FOREIGN KEY (khuyen_mai_id) REFERENCES dbo.khuyen_mai(id);

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_khuyen_mai_ap_dung_ma_giam_gia')
		ALTER TABLE dbo.khuyen_mai_ap_dung ADD CONSTRAINT FK_khuyen_mai_ap_dung_ma_giam_gia 
		FOREIGN KEY (ma_giam_gia_id) REFERENCES dbo.ma_giam_gia(id);

	-- Thong ke foreign keys
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thong_ke_san_pham')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT FK_thong_ke_san_pham 
		FOREIGN KEY (san_pham_id) REFERENCES dbo.san_pham(id) ON DELETE SET NULL;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thong_ke_danh_muc')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT FK_thong_ke_danh_muc 
		FOREIGN KEY (danh_muc_id) REFERENCES dbo.danh_muc(id) ON DELETE SET NULL;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thong_ke_thuong_hieu')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT FK_thong_ke_thuong_hieu 
		FOREIGN KEY (thuong_hieu_id) REFERENCES dbo.thuong_hieu(id) ON DELETE SET NULL;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thong_ke_don_hang')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT FK_thong_ke_don_hang 
		FOREIGN KEY (don_hang_id) REFERENCES dbo.don_hang(id) ON DELETE SET NULL;

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_thong_ke_nguoi_dung')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT FK_thong_ke_nguoi_dung 
		FOREIGN KEY (nguoi_dung_id) REFERENCES dbo.nguoi_dung(id) ON DELETE SET NULL;

	----------------------------------------------------------
	-- 2.2) DATA CORRECTNESS FIXES - ƯU TIÊN CAO
	----------------------------------------------------------

	-- Cart item → link variant
	IF COL_LENGTH('dbo.chi_tiet_gio_hang','bien_the_id') IS NULL
		ALTER TABLE dbo.chi_tiet_gio_hang ADD bien_the_id BIGINT NULL;
	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name='FK_ctgh_bien_the')
		ALTER TABLE dbo.chi_tiet_gio_hang ADD CONSTRAINT FK_ctgh_bien_the
		FOREIGN KEY (bien_the_id) REFERENCES dbo.bien_the_san_pham(id);

	-- Chống trùng biến thể trong giỏ hàng (sửa lỗi NULL đụng nhau)
	IF OBJECT_ID(N'dbo.chi_tiet_gio_hang', N'U') IS NOT NULL
	BEGIN
		-- Gỡ nếu đã tồn tại
		IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_ctgh_bien_the')
			ALTER TABLE dbo.chi_tiet_gio_hang DROP CONSTRAINT UQ_ctgh_bien_the;

		IF EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_ctgh_san_pham_variant')
			ALTER TABLE dbo.chi_tiet_gio_hang DROP CONSTRAINT UQ_ctgh_san_pham_variant;

		-- Tạo UNIQUE cho trường hợp có biến thể
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UIX_ctgh_bien_the_not_null')
			CREATE UNIQUE INDEX UIX_ctgh_bien_the_not_null 
			ON dbo.chi_tiet_gio_hang(gio_hang_id, bien_the_id)
			WHERE bien_the_id IS NOT NULL;

		-- Tạo UNIQUE fallback cho trường hợp chưa có biến thể
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UIX_ctgh_fallback_when_null_variant')
			CREATE UNIQUE INDEX UIX_ctgh_fallback_when_null_variant
			ON dbo.chi_tiet_gio_hang(gio_hang_id, san_pham_id, kich_thuoc, mau_sac)
			WHERE bien_the_id IS NULL;
	END

-- Order item → link variant (vẫn snapshot tên/giá/size/màu để "đóng băng" thời điểm mua)
IF COL_LENGTH('dbo.chi_tiet_don_hang','bien_the_id') IS NULL
    ALTER TABLE dbo.chi_tiet_don_hang ADD bien_the_id BIGINT NULL;
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name='FK_ctdh_bien_the')
    ALTER TABLE dbo.chi_tiet_don_hang ADD CONSTRAINT FK_ctdh_bien_the
    FOREIGN KEY (bien_the_id) REFERENCES dbo.bien_the_san_pham(id);

-- Thêm cột van_chuyen_id cho don_hang (gộp logic - tránh lặp)
IF COL_LENGTH('dbo.don_hang','van_chuyen_id') IS NULL
    ALTER TABLE dbo.don_hang ADD van_chuyen_id BIGINT NULL;

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name='FK_don_hang_van_chuyen')
    ALTER TABLE dbo.don_hang ADD CONSTRAINT FK_don_hang_van_chuyen
    FOREIGN KEY (van_chuyen_id) REFERENCES dbo.van_chuyen(id);

-- Tạo index SAU khi có cột van_chuyen_id
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_don_hang_van_chuyen' AND object_id = OBJECT_ID('dbo.don_hang'))
    CREATE NONCLUSTERED INDEX IX_don_hang_van_chuyen ON dbo.don_hang(van_chuyen_id);

-- FK cho trường người tạo/cập nhật trong san_pham (tùy chọn)
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name='FK_san_pham_nguoi_tao')
    ALTER TABLE dbo.san_pham ADD CONSTRAINT FK_san_pham_nguoi_tao
    FOREIGN KEY (nguoi_tao) REFERENCES dbo.nguoi_dung(id);

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name='FK_san_pham_nguoi_cap_nhat')
    ALTER TABLE dbo.san_pham ADD CONSTRAINT FK_san_pham_nguoi_cap_nhat
    FOREIGN KEY (nguoi_cap_nhat) REFERENCES dbo.nguoi_dung(id);

	-- Tạo index cho các cột mới được thêm (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.chi_tiet_gio_hang', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_ctgh_bien_the')
			CREATE NONCLUSTERED INDEX IX_ctgh_bien_the ON dbo.chi_tiet_gio_hang(bien_the_id);
	END

	IF OBJECT_ID(N'dbo.chi_tiet_don_hang', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_ctdh_bien_the')
			CREATE NONCLUSTERED INDEX IX_ctdh_bien_the ON dbo.chi_tiet_don_hang(bien_the_id);
	END

-- Index hiệu năng và covering cho các truy vấn thường xuyên
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_hoat_dong_covering')
    CREATE NONCLUSTERED INDEX IX_sp_hoat_dong_covering ON dbo.san_pham(hoat_dong) 
    INCLUDE (ten, gia, anh_chinh, id_danh_muc, id_thuong_hieu, noi_bat, ban_chay, moi_ve);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_dm_hoat_dong_covering')
    CREATE NONCLUSTERED INDEX IX_dm_hoat_dong_covering ON dbo.danh_muc(hoat_dong) 
    INCLUDE (ten, slug, hinh_anh, thu_tu, hien_thi_trang_chu);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_th_hoat_dong_covering')
    CREATE NONCLUSTERED INDEX IX_th_hoat_dong_covering ON dbo.thuong_hieu(hoat_dong) 
    INCLUDE (ten, slug, hinh_anh, thu_tu, hien_thi_trang_chu);

-- Bộ index "theo màn hình" (covering & composite)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_active_dm')
    CREATE INDEX IX_sp_active_dm ON dbo.san_pham(hoat_dong, id_danh_muc) 
    INCLUDE(ten, gia, anh_chinh, slug);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_active_th')
    CREATE INDEX IX_sp_active_th ON dbo.san_pham(hoat_dong, id_thuong_hieu) 
    INCLUDE(ten, gia, anh_chinh, slug);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_flags')
    CREATE INDEX IX_sp_flags ON dbo.san_pham(noi_bat, ban_chay, moi_ve) 
    INCLUDE(ten, gia, anh_chinh, slug);

-- Tối ưu truy vấn danh sách sản phẩm theo giá
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_active_price')
    CREATE INDEX IX_sp_active_price ON dbo.san_pham(hoat_dong, gia)
    INCLUDE(ten, slug, anh_chinh, id_danh_muc, id_thuong_hieu);

	-- Index FK còn thiếu (tăng tốc join/DELETE/UPDATE)
	-- Review liên kết đơn hàng
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_danh_gia_don_hang')
		CREATE NONCLUSTERED INDEX IX_danh_gia_don_hang ON dbo.danh_gia(don_hang_id);

	-- Thông báo theo user
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_bao_user')
		CREATE NONCLUSTERED INDEX IX_thong_bao_user ON dbo.thong_bao(nguoi_dung_id, da_doc);

	-- Bảng M-N/áp dụng KM
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_kmad_dh')
		CREATE NONCLUSTERED INDEX IX_kmad_dh ON dbo.khuyen_mai_ap_dung(don_hang_id);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_kmad_km')
		CREATE NONCLUSTERED INDEX IX_kmad_km ON dbo.khuyen_mai_ap_dung(khuyen_mai_id);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_kmad_mgg')
		CREATE NONCLUSTERED INDEX IX_kmad_mgg ON dbo.khuyen_mai_ap_dung(ma_giam_gia_id);

	-- Thong ke indexes
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_ke_ngay_loai')
		CREATE NONCLUSTERED INDEX IX_thong_ke_ngay_loai ON dbo.thong_ke(ngay, loai_thong_ke);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_ke_san_pham')
		CREATE NONCLUSTERED INDEX IX_thong_ke_san_pham ON dbo.thong_ke(san_pham_id);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_ke_danh_muc')
		CREATE NONCLUSTERED INDEX IX_thong_ke_danh_muc ON dbo.thong_ke(danh_muc_id);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_ke_thuong_hieu')
		CREATE NONCLUSTERED INDEX IX_thong_ke_thuong_hieu ON dbo.thong_ke(thuong_hieu_id);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_ke_don_hang')
		CREATE NONCLUSTERED INDEX IX_thong_ke_don_hang ON dbo.thong_ke(don_hang_id);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_thong_ke_nguoi_dung')
		CREATE NONCLUSTERED INDEX IX_thong_ke_nguoi_dung ON dbo.thong_ke(nguoi_dung_id);

	-- Sản phẩm khuyến mãi
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_spkm_sp')
		CREATE NONCLUSTERED INDEX IX_spkm_sp ON dbo.san_pham_khuyen_mai(id_san_pham);

	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_spkm_km')
		CREATE NONCLUSTERED INDEX IX_spkm_km ON dbo.san_pham_khuyen_mai(id_khuyen_mai);

	-- Chỉ mục FK còn lại (nhỏ nhưng hữu ích)
	-- Don hang: trạng thái + thời điểm
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_don_hang_status_time')
		CREATE NONCLUSTERED INDEX IX_don_hang_status_time 
		ON dbo.don_hang(trang_thai, ngay_dat_hang) 
		INCLUDE(nguoi_dung_id, tong_thanh_toan);

-- san_pham_lien_quan: hay join theo id_san_pham
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_splq_sp')
    CREATE NONCLUSTERED INDEX IX_splq_sp ON dbo.san_pham_lien_quan(id_san_pham);

-- Ràng buộc SKU: chống whitespace 2 đầu & độ dài tối thiểu
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_bienthe_sku_trim')
    ALTER TABLE dbo.bien_the_san_pham ADD CONSTRAINT CK_bienthe_sku_trim
    CHECK (LEN(LTRIM(RTRIM(ma_sku))) >= 3);

-- Index theo màn hình chi tiết đơn hàng
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ctdh_dh_cover')
    CREATE NONCLUSTERED INDEX IX_ctdh_dh_cover 
    ON dbo.chi_tiet_don_hang(don_hang_id)
    INCLUDE(ten_san_pham, so_luong, gia_ban, thanh_tien, mau_sac, kich_thuoc, bien_the_id);

-- OTP: unique "OTP active per email/type" (sửa lỗi non-deterministic function)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_otp_active_email_type')
    CREATE UNIQUE INDEX UQ_otp_active_email_type
    ON dbo.otp_verification(email, [type])
    WHERE is_used = 0; -- bỏ SYSUTCDATETIME() vì không được phép trong filtered index


	-- Index cho OTP verification (sửa filtered index)
	IF OBJECT_ID(N'dbo.otp_verification', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_otp_verification_active')
			CREATE NONCLUSTERED INDEX IX_otp_verification_active ON dbo.otp_verification(email, type, is_used, expires_at) 
			WHERE is_used = 0;
	END

	-- Bảo đảm "duy nhất" thông minh
	-- Ảnh sản phẩm "ảnh chính": mỗi sản phẩm chỉ có 1 ảnh chính
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_asp_main_per_sp')
		CREATE UNIQUE INDEX UQ_asp_main_per_sp
		ON dbo.anh_san_pham(id_san_pham)
		WHERE la_anh_chinh = 1;

	-- Địa chỉ mặc định: mỗi user chỉ nên có 1 địa chỉ mặc định
	IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_dia_chi_default_per_user')
		CREATE UNIQUE INDEX UQ_dia_chi_default_per_user
		ON dbo.dia_chi(nguoi_dung_id)
		WHERE la_dia_chi_mac_dinh = 1;

	-- Chặn trùng/quan hệ "tự liên kết" cho các bảng M-N
	-- Tránh dữ liệu bẩn, lặp cặp, hoặc liên kết sản phẩm với… chính nó

	-- Tránh trùng cặp (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.san_pham_tag', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UQ_san_pham_tag_pair')
			ALTER TABLE dbo.san_pham_tag ADD CONSTRAINT UQ_san_pham_tag_pair UNIQUE (id_san_pham, id_tag);
	END

	IF OBJECT_ID(N'dbo.san_pham_nhom', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UQ_san_pham_nhom_pair')
			ALTER TABLE dbo.san_pham_nhom ADD CONSTRAINT UQ_san_pham_nhom_pair UNIQUE (id_san_pham, id_nhom);
	END

	IF OBJECT_ID(N'dbo.san_pham_lien_quan', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UQ_san_pham_lien_quan_pair')
			ALTER TABLE dbo.san_pham_lien_quan ADD CONSTRAINT UQ_san_pham_lien_quan_pair 
			UNIQUE (id_san_pham, id_san_pham_lien_quan);
	END

	-- Không cho link chính nó (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.san_pham_lien_quan', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_splq_not_self')
			ALTER TABLE dbo.san_pham_lien_quan ADD CONSTRAINT CK_splq_not_self
			CHECK (id_san_pham <> id_san_pham_lien_quan);

		-- (Tùy chọn) chống cặp đối xứng A-B và B-A: ép thứ tự id
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_splq_ordered')
			ALTER TABLE dbo.san_pham_lien_quan ADD CONSTRAINT CK_splq_ordered
			CHECK (id_san_pham < id_san_pham_lien_quan);
	END

	-- CHECK constraints để giữ dữ liệu hợp lệ
	-- Giá/tiền và số lượng không âm
	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_sp_gia')
		ALTER TABLE dbo.san_pham ADD CONSTRAINT CK_sp_gia 
		CHECK ((gia IS NULL OR gia >= 0) AND (gia_goc IS NULL OR gia_goc >= 0));

	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_bien_the_qty')
		ALTER TABLE dbo.bien_the_san_pham ADD CONSTRAINT CK_bien_the_qty 
		CHECK (so_luong >= 0 AND so_luong_ton >= 0);

	-- Chỉ thêm constraint nếu bảng tồn tại
	IF OBJECT_ID(N'dbo.chi_tiet_gio_hang', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_ctgh_qty')
			ALTER TABLE dbo.chi_tiet_gio_hang ADD CONSTRAINT CK_ctgh_qty 
			CHECK (so_luong > 0);
	END

	IF OBJECT_ID(N'dbo.chi_tiet_don_hang', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_ctdh_qty')
			ALTER TABLE dbo.chi_tiet_don_hang ADD CONSTRAINT CK_ctdh_qty 
			CHECK (so_luong > 0);
	END

	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_danh_gia_diem')
		ALTER TABLE dbo.danh_gia ADD CONSTRAINT CK_danh_gia_diem 
		CHECK (diem BETWEEN 1 AND 5);

	-- Thời hạn KM/MGG hợp lệ (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.khuyen_mai', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_km_dates')
			ALTER TABLE dbo.khuyen_mai ADD CONSTRAINT CK_km_dates 
			CHECK (ngay_bat_dau <= ngay_ket_thuc);
	END

	IF OBJECT_ID(N'dbo.ma_giam_gia', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_mgg_dates')
			ALTER TABLE dbo.ma_giam_gia ADD CONSTRAINT CK_mgg_dates 
			CHECK (ngay_bat_dau <= ngay_ket_thuc);
	END

	-- Ràng buộc giảm giá hợp lệ cho khuyến mãi (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.khuyen_mai', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_km_gia_tri')
			ALTER TABLE dbo.khuyen_mai ADD CONSTRAINT CK_km_gia_tri 
			CHECK (
				(loai = 'PERCENTAGE' AND gia_tri >= 0 AND gia_tri <= 100) OR
				(loai = 'FIXED_AMOUNT' AND gia_tri >= 0)
			);
	END

	IF OBJECT_ID(N'dbo.ma_giam_gia', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_mgg_gia_tri')
			ALTER TABLE dbo.ma_giam_gia ADD CONSTRAINT CK_mgg_gia_tri 
			CHECK (
				(loai = 'PERCENTAGE' AND gia_tri >= 0 AND gia_tri <= 100) OR
				(loai = 'FIXED_AMOUNT' AND gia_tri >= 0)
			);
	END

	-- Ràng buộc giá khuyến mãi <= giá bán cho biến thể (cải thiện)
	IF EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_bien_the_gia_km')
		ALTER TABLE dbo.bien_the_san_pham DROP CONSTRAINT CK_bien_the_gia_km;

	ALTER TABLE dbo.bien_the_san_pham ADD CONSTRAINT CK_bien_the_gia_km
	CHECK (
		(gia_ban IS NULL OR gia_ban >= 0)
		AND (gia_khuyen_mai IS NULL OR (gia_khuyen_mai >= 0 AND gia_khuyen_mai <= gia_ban))
	);

	-- Bổ sung CHECK chống âm & sai logic
	-- Không âm cho các cột tiền
	IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_don_hang_phi_vc')
		ALTER TABLE dbo.don_hang ADD CONSTRAINT CK_don_hang_phi_vc CHECK (phi_van_chuyen >= 0);

	IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_thanh_toan_so_tien')
		ALTER TABLE dbo.thanh_toan ADD CONSTRAINT CK_thanh_toan_so_tien CHECK (so_tien >= 0);

	IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_kmad_so_tien_giam')
		ALTER TABLE dbo.khuyen_mai_ap_dung ADD CONSTRAINT CK_kmad_so_tien_giam CHECK (so_tien_giam >= 0);

	-- OTP attempts hợp lệ
	IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_otp_attempts')
		ALTER TABLE dbo.otp_verification ADD CONSTRAINT CK_otp_attempts
		CHECK (attempts >= 0 AND max_attempts >= 0 AND attempts <= max_attempts);

	-- Trạng thái dạng chuỗi → CHECK (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.don_hang', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_don_hang_status')
			ALTER TABLE dbo.don_hang ADD CONSTRAINT CK_don_hang_status
			CHECK (trang_thai IN (N'CHO_XAC_NHAN',N'DA_XAC_NHAN',N'DANG_GIAO',N'DA_GIAO',N'DA_HUY',N'DA_TRA_HANG'));
	END

	IF OBJECT_ID(N'dbo.thanh_toan', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_thanh_toan_status')
			ALTER TABLE dbo.thanh_toan ADD CONSTRAINT CK_thanh_toan_status
			CHECK (trang_thai IN (N'CHO_XU_LY',N'THANH_CONG',N'THAT_BAI',N'HOAN_TIEN'));
	END

	-- Chuẩn hóa enum cột chuỗi với CHECK constraints (chỉ thêm nếu bảng tồn tại)
	IF OBJECT_ID(N'dbo.banner', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_banner_vi_tri')
			ALTER TABLE dbo.banner ADD CONSTRAINT CK_banner_vi_tri
			CHECK (vi_tri IN (N'MAIN',N'SIDE',N'TOP',N'BOTTOM',N'POPUP'));
	END

	IF OBJECT_ID(N'dbo.nhom_san_pham', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_nhom_san_pham_loai')
			ALTER TABLE dbo.nhom_san_pham ADD CONSTRAINT CK_nhom_san_pham_loai
			CHECK (loai IN (N'GENDER',N'AGE',N'SPORT',N'SEASON',N'STYLE'));
	END

	IF OBJECT_ID(N'dbo.chat_support', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_chat_support_loai_tin_nhan')
			ALTER TABLE dbo.chat_support ADD CONSTRAINT CK_chat_support_loai_tin_nhan
			CHECK (loai_tin_nhan IN (N'USER',N'STAFF',N'SYSTEM'));

		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_chat_support_trang_thai')
			ALTER TABLE dbo.chat_support ADD CONSTRAINT CK_chat_support_trang_thai
			CHECK (trang_thai IN (N'CHO_XU_LY',N'DANG_XU_LY',N'DA_GIAI_QUYET',N'DONG'));
	END

	IF OBJECT_ID(N'dbo.khuyen_mai', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_khuyen_mai_loai')
			ALTER TABLE dbo.khuyen_mai ADD CONSTRAINT CK_khuyen_mai_loai
			CHECK (loai IN (N'PERCENTAGE',N'FIXED_AMOUNT',N'BUY_X_GET_Y',N'FREE_SHIPPING'));
	END

	IF OBJECT_ID(N'dbo.ma_giam_gia', N'U') IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_ma_giam_gia_loai')
			ALTER TABLE dbo.ma_giam_gia ADD CONSTRAINT CK_ma_giam_gia_loai
			CHECK (loai IN (N'PERCENTAGE',N'FIXED_AMOUNT',N'BUY_X_GET_Y',N'FREE_SHIPPING'));
	END

	IF OBJECT_ID(N'dbo.danh_gia', N'U') IS NOT NULL
	BEGIN
	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_danh_gia_trang_thai')
		ALTER TABLE dbo.danh_gia ADD CONSTRAINT CK_danh_gia_trang_thai
		CHECK (trang_thai IN (N'CHO_DUYET',N'DA_DUYET',N'TU_CHOI',N'AN'));

	-- Thong ke constraints
	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_thong_ke_loai')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT CK_thong_ke_loai
		CHECK (loai_thong_ke IN (N'DOANH_THU',N'SO_LUONG_BAN',N'DON_HANG',N'KHACH_HANG',N'SAN_PHAM',N'DANH_MUC',N'THUONG_HIEU',N'KHUYEN_MAI'));

	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_thong_ke_gia_tri')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT CK_thong_ke_gia_tri
		CHECK (gia_tri >= 0);

	IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_thong_ke_so_luong')
		ALTER TABLE dbo.thong_ke ADD CONSTRAINT CK_thong_ke_so_luong
		CHECK (so_luong >= 0);
	END


	----------------------------------------------------------
	-- 2.2) AUTO-UPDATE TRIGGERS
	----------------------------------------------------------

-- Trigger cập nhật ngay_cap_nhat cho san_pham
IF OBJECT_ID('dbo.trg_san_pham_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_san_pham_updated_at;
GO
CREATE TRIGGER dbo.trg_san_pham_updated_at
ON dbo.san_pham
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE sp
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.san_pham sp
    JOIN inserted i ON i.id = sp.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho bien_the_san_pham
IF OBJECT_ID('dbo.trg_bien_the_san_pham_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_bien_the_san_pham_updated_at;
GO
CREATE TRIGGER dbo.trg_bien_the_san_pham_updated_at
ON dbo.bien_the_san_pham
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE btsp
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.bien_the_san_pham btsp
    JOIN inserted i ON i.id = btsp.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho don_hang
IF OBJECT_ID('dbo.trg_don_hang_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_don_hang_updated_at;
GO
CREATE TRIGGER dbo.trg_don_hang_updated_at
ON dbo.don_hang
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE dh
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.don_hang dh
    JOIN inserted i ON i.id = dh.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho nguoi_dung
IF OBJECT_ID('dbo.trg_nguoi_dung_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_nguoi_dung_updated_at;
GO
CREATE TRIGGER dbo.trg_nguoi_dung_updated_at
ON dbo.nguoi_dung
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE nd
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.nguoi_dung nd
    JOIN inserted i ON i.id = nd.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho banner
IF OBJECT_ID('dbo.trg_banner_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_banner_updated_at;
GO
CREATE TRIGGER dbo.trg_banner_updated_at
ON dbo.banner
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE b
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.banner b
    JOIN inserted i ON i.id = b.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho khuyen_mai
IF OBJECT_ID('dbo.trg_khuyen_mai_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_khuyen_mai_updated_at;
GO
CREATE TRIGGER dbo.trg_khuyen_mai_updated_at
ON dbo.khuyen_mai
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE km
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.khuyen_mai km
    JOIN inserted i ON i.id = km.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho ma_giam_gia
IF OBJECT_ID('dbo.trg_ma_giam_gia_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_ma_giam_gia_updated_at;
GO
CREATE TRIGGER dbo.trg_ma_giam_gia_updated_at
ON dbo.ma_giam_gia
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE mgg
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.ma_giam_gia mgg
    JOIN inserted i ON i.id = mgg.id;
END
GO

-- Trigger cập nhật ngay_cap_nhat cho cau_hinh
IF OBJECT_ID('dbo.trg_cau_hinh_updated_at','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_cau_hinh_updated_at;
GO
CREATE TRIGGER dbo.trg_cau_hinh_updated_at
ON dbo.cau_hinh
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu chính cột ngay_cap_nhat được update thì bỏ qua để tránh vòng lặp
    IF UPDATE(ngay_cap_nhat) RETURN;

    UPDATE ch
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM dbo.cau_hinh ch
    JOIN inserted i ON i.id = ch.id;
END
GO

	----------------------------------------------------------
	-- 2.3) OTP STORED PROCEDURES
	----------------------------------------------------------

	-- Tạo stored procedure để cleanup OTP cũ
	IF OBJECT_ID(N'dbo.CleanupExpiredOtps', N'P') IS NOT NULL
		DROP PROCEDURE [dbo].[CleanupExpiredOtps];
	GO

	CREATE PROCEDURE [dbo].[CleanupExpiredOtps]
	AS
	BEGIN
		SET NOCOUNT ON;
		
		-- Xóa các OTP đã hết hạn
		DELETE FROM [dbo].[otp_verification] 
		WHERE [expires_at] < SYSUTCDATETIME();
		
		-- Xóa các OTP đã sử dụng cũ hơn 7 ngày
		DELETE FROM [dbo].[otp_verification] 
		WHERE [is_used] = 1 AND [used_at] < DATEADD(day, -7, SYSUTCDATETIME());
		
		-- Xóa các OTP chưa sử dụng cũ hơn 24 giờ
		DELETE FROM [dbo].[otp_verification] 
		WHERE [is_used] = 0 AND [created_at] < DATEADD(hour, -24, SYSUTCDATETIME());
		
		PRINT N'✅ Đã cleanup OTP cũ thành công';
	END
	GO

	-- Stored procedure tăng attempts với guard (chống brute-force)
	IF OBJECT_ID(N'dbo.IncrementOtpAttempts', N'P') IS NOT NULL
		DROP PROCEDURE [dbo].[IncrementOtpAttempts];
	GO

	CREATE PROCEDURE [dbo].[IncrementOtpAttempts]
		@Id BIGINT
	AS
	BEGIN
		SET NOCOUNT ON;

		UPDATE dbo.otp_verification
		SET attempts = CASE WHEN attempts < max_attempts THEN attempts + 1 ELSE attempts END
		WHERE id = @Id;

		-- (tùy chọn) Trả về trạng thái hiện tại
		SELECT attempts, max_attempts
		FROM dbo.otp_verification
		WHERE id = @Id;
	END
	GO

	-- Tạo stored procedure để lấy OTP active
	IF OBJECT_ID(N'dbo.GetActiveOtp', N'P') IS NOT NULL
		DROP PROCEDURE [dbo].[GetActiveOtp];
	GO

	CREATE PROCEDURE [dbo].[GetActiveOtp]
		@Email NVARCHAR(255),
		@Type NVARCHAR(50) = 'REGISTRATION'
	AS
	BEGIN
		SET NOCOUNT ON;
		
		SELECT TOP 1
			[id],
			[email],
			[otp_hash],
			[otp_salt],
			[type],
			[expires_at],
			[is_used],
			[attempts],
			[max_attempts],
			[created_at],
			[used_at]
		FROM [dbo].[otp_verification]
		WHERE [email] = @Email 
			AND [type] = @Type 
			AND [is_used] = 0 
			AND [expires_at] > SYSUTCDATETIME() 
			AND [attempts] < [max_attempts]
		ORDER BY [created_at] DESC;
	END
	GO

	-- Tạo stored procedure để đánh dấu OTP đã sử dụng
	IF OBJECT_ID(N'dbo.MarkOtpAsUsed', N'P') IS NOT NULL
		DROP PROCEDURE [dbo].[MarkOtpAsUsed];
	GO

	CREATE PROCEDURE [dbo].[MarkOtpAsUsed]
		@Id BIGINT
	AS
	BEGIN
		SET NOCOUNT ON;
		
		UPDATE [dbo].[otp_verification]
		SET [is_used] = 1, [used_at] = SYSUTCDATETIME()
		WHERE [id] = @Id;
	END
	GO


	-- Tạo stored procedure để đếm OTP gần đây (rate limiting)
	IF OBJECT_ID(N'dbo.CountRecentOtps', N'P') IS NOT NULL
		DROP PROCEDURE [dbo].[CountRecentOtps];
	GO

	CREATE PROCEDURE [dbo].[CountRecentOtps]
		@Email NVARCHAR(255),
		@Hours INT = 1
	AS
	BEGIN
		SET NOCOUNT ON;
		
		SELECT COUNT(*) as [count]
		FROM [dbo].[otp_verification]
		WHERE [email] = @Email 
			AND [created_at] > DATEADD(hour, -@Hours, SYSUTCDATETIME());
	END
	GO

	----------------------------------------------------------
	-- 2.3) PERFORMANCE INDEXES - ƯU TIÊN CAO
	----------------------------------------------------------

	-- Tạo index cho mọi cột FK (hiện bạn mới index một số chỗ)
	-- Tối thiểu cho các bảng lớn/truy vấn thường xuyên

	-- Cart & Order indexes
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_ctgh_gio_hang')
		CREATE NONCLUSTERED INDEX IX_ctgh_gio_hang ON dbo.chi_tiet_gio_hang(gio_hang_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_ctgh_san_pham')
		CREATE NONCLUSTERED INDEX IX_ctgh_san_pham ON dbo.chi_tiet_gio_hang(san_pham_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_ctdh_don_hang')
		CREATE NONCLUSTERED INDEX IX_ctdh_don_hang ON dbo.chi_tiet_don_hang(don_hang_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_ctdh_san_pham')
		CREATE NONCLUSTERED INDEX IX_ctdh_san_pham ON dbo.chi_tiet_don_hang(san_pham_id);

	-- Product & Variant indexes
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_bienthe_sp')
		CREATE NONCLUSTERED INDEX IX_bienthe_sp ON dbo.bien_the_san_pham(id_san_pham);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_asp_sp')
		CREATE NONCLUSTERED INDEX IX_asp_sp ON dbo.anh_san_pham(id_san_pham);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_dm')
		CREATE NONCLUSTERED INDEX IX_sp_dm ON dbo.san_pham(id_danh_muc);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_th')
		CREATE NONCLUSTERED INDEX IX_sp_th ON dbo.san_pham(id_thuong_hieu);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_sp_mtt')
		CREATE NONCLUSTERED INDEX IX_sp_mtt ON dbo.san_pham(id_mon_the_thao);

	-- Order & Payment indexes
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_dh_nd')
		CREATE NONCLUSTERED INDEX IX_dh_nd ON dbo.don_hang(nguoi_dung_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_tt_dh')
		CREATE NONCLUSTERED INDEX IX_tt_dh ON dbo.thanh_toan(don_hang_id, trang_thai);

	-- User & Address indexes
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_dia_chi_nd')
		CREATE NONCLUSTERED INDEX IX_dia_chi_nd ON dbo.dia_chi(nguoi_dung_id);

	-- Review & Favorite indexes
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_danh_gia_sp')
		CREATE NONCLUSTERED INDEX IX_danh_gia_sp ON dbo.danh_gia(san_pham_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_danh_gia_nd')
		CREATE NONCLUSTERED INDEX IX_danh_gia_nd ON dbo.danh_gia(nguoi_dung_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_yeu_thich_nd')
		CREATE NONCLUSTERED INDEX IX_yeu_thich_nd ON dbo.yeu_thich(nguoi_dung_id);

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_yeu_thich_sp')
		CREATE NONCLUSTERED INDEX IX_yeu_thich_sp ON dbo.yeu_thich(san_pham_id);

	-- Email & mật khẩu - chuẩn hóa lowercase để unique "đúng nghĩa"
	IF COL_LENGTH('dbo.nguoi_dung','email_lc') IS NULL
		ALTER TABLE dbo.nguoi_dung ADD email_lc AS LOWER(email) PERSISTED;

	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='UQ_nguoi_dung_email_lc')
		CREATE UNIQUE INDEX UQ_nguoi_dung_email_lc ON dbo.nguoi_dung(email_lc);

-- Validation cho email và SĐT (nới lỏng - để app validate chi tiết)
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_nguoi_dung_email_format')
    ALTER TABLE dbo.nguoi_dung ADD CONSTRAINT CK_nguoi_dung_email_format
    CHECK (email LIKE '%@%' AND LEN(email) >= 5);

IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_nguoi_dung_so_dien_thoai')
    ALTER TABLE dbo.nguoi_dung ADD CONSTRAINT CK_nguoi_dung_so_dien_thoai 
    CHECK (
        so_dien_thoai IS NULL
        OR (LEN(so_dien_thoai) BETWEEN 8 AND 20
            AND so_dien_thoai LIKE '[+0-9]%'      -- bắt đầu bằng + hoặc số
            AND so_dien_thoai NOT LIKE '%[^0-9+]%' -- chỉ chứa số và dấu +
        )
    );

-- Validation cho địa chỉ (nới lỏng)
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE name='CK_dia_chi_so_dien_thoai')
    ALTER TABLE dbo.dia_chi ADD CONSTRAINT CK_dia_chi_so_dien_thoai 
    CHECK (
        LEN(so_dien_thoai) BETWEEN 8 AND 20
        AND so_dien_thoai LIKE '[+0-9]%'
        AND so_dien_thoai NOT LIKE '%[^0-9+]%' -- chỉ chứa số và dấu +
    );

	----------------------------------------------------------
	-- 2.4) BỔ SUNG TÍNH NĂNG (NẾU CẦN MỞ RỘNG)
	----------------------------------------------------------


	-- Quản lý tồn kho theo kho và biến thể
	IF OBJECT_ID(N'dbo.ton_kho_kho',N'U') IS NULL
	BEGIN
		CREATE TABLE dbo.ton_kho_kho(
			id BIGINT IDENTITY(1,1) PRIMARY KEY,
			kho_hang_id BIGINT NOT NULL,
			bien_the_id BIGINT NOT NULL,
			so_luong INT NOT NULL DEFAULT(0),
			ngay_cap_nhat DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
			CONSTRAINT FK_tkk_kho FOREIGN KEY (kho_hang_id) REFERENCES dbo.kho_hang(id) ON DELETE CASCADE,
			CONSTRAINT FK_tkk_bienthe FOREIGN KEY (bien_the_id) REFERENCES dbo.bien_the_san_pham(id) ON DELETE CASCADE,
			CONSTRAINT UQ_tkk UNIQUE (kho_hang_id, bien_the_id),
			CONSTRAINT CK_tkk_qty CHECK (so_luong >= 0)
		);
		PRINT N'✅ Tạo dbo.ton_kho_kho';
	END

	-- Tổng tiền đơn hàng nhất quán - VIEW hỗ trợ báo cáo
	IF OBJECT_ID(N'dbo.v_don_hang_tong', N'V') IS NULL
	EXEC('CREATE VIEW dbo.v_don_hang_tong AS
	SELECT dh.id, dh.ma_don_hang, dh.tong_tien, dh.phi_van_chuyen,
		ISNULL(SUM(kmad.so_tien_giam),0) AS tong_giam,
		dh.tong_tien + dh.phi_van_chuyen - ISNULL(SUM(kmad.so_tien_giam),0) AS thanh_toan_thuc_te
	FROM dbo.don_hang dh
	LEFT JOIN dbo.khuyen_mai_ap_dung kmad ON kmad.don_hang_id = dh.id
	GROUP BY dh.id, dh.ma_don_hang, dh.tong_tien, dh.phi_van_chuyen;');

	-- VIEW tồn kho nhất quán - tính tổng tồn kho từ biến thể
	IF OBJECT_ID(N'dbo.v_san_pham_ton_kho', N'V') IS NULL
	EXEC('CREATE VIEW dbo.v_san_pham_ton_kho AS
	SELECT sp.id, sp.ten, sp.so_luong_ton AS ton_kho_cu,
		ISNULL(SUM(btsp.so_luong_ton), 0) AS ton_kho_thuc_te,
		COUNT(btsp.id) AS so_bien_the
	FROM dbo.san_pham sp
	LEFT JOIN dbo.bien_the_san_pham btsp ON btsp.id_san_pham = sp.id AND btsp.trang_thai = 1
	GROUP BY sp.id, sp.ten, sp.so_luong_ton;');

-- VIEW tồn kho theo kho (cho multi-warehouse - cải thiện)
IF OBJECT_ID(N'dbo.v_ton_kho_theo_kho', N'V') IS NOT NULL
    DROP VIEW dbo.v_ton_kho_theo_kho;
GO
CREATE VIEW dbo.v_ton_kho_theo_kho AS
SELECT sp.id AS san_pham_id, bt.id AS bien_the_id, 
       ISNULL(tkk.kho_hang_id, 0) AS kho_hang_id,
       ISNULL(SUM(tkk.so_luong), 0) AS so_luong
FROM dbo.bien_the_san_pham bt
JOIN dbo.san_pham sp ON sp.id = bt.id_san_pham
LEFT JOIN dbo.ton_kho_kho tkk ON tkk.bien_the_id = bt.id
GROUP BY sp.id, bt.id, ISNULL(tkk.kho_hang_id, 0);
GO

-- Full-Text Search cho sản phẩm (nếu cần search nâng cao - với error handling)
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name=N'ftc_datn')
        CREATE FULLTEXT CATALOG ftc_datn;

    IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes 
                   WHERE object_id = OBJECT_ID('dbo.san_pham'))
        CREATE FULLTEXT INDEX ON dbo.san_pham(ten LANGUAGE 1066, mo_ta LANGUAGE 1066, mo_ta_ngan LANGUAGE 1066)
        KEY INDEX PK_san_pham ON ftc_datn WITH CHANGE_TRACKING AUTO;
        
    PRINT N'🔍 Full-Text Search đã được cấu hình.';
END TRY
BEGIN CATCH
    PRINT N'⚠️ Full-Text Search không khả dụng: ' + ERROR_MESSAGE();
    PRINT N'💡 Có thể cần cài đặt Full-Text Search feature.';
END CATCH

	----------------------------------------------------------
	-- 2.4) STORED PROCEDURES HỖ TRỢ
	----------------------------------------------------------

-- Stored procedure xóa sản phẩm an toàn (cải thiện)
IF OBJECT_ID(N'dbo.DeleteProductSafe', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[DeleteProductSafe];
GO

CREATE PROCEDURE [dbo].[DeleteProductSafe]
    @SanPhamId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu sản phẩm đã xuất hiện trong chi tiết đơn hàng → không cho xóa cứng
    IF EXISTS (SELECT 1 FROM dbo.chi_tiet_don_hang WHERE san_pham_id = @SanPhamId)
    BEGIN
        -- Ẩn sản phẩm thay vì xóa
        UPDATE dbo.san_pham SET hoat_dong = 0 WHERE id = @SanPhamId;
        PRINT N'ℹ️ Sản phẩm đã từng bán. Đã chuyển trạng thái hoat_dong = 0.';
        RETURN;
    END

    BEGIN TRAN;
    BEGIN TRY
        DELETE FROM dbo.san_pham_tag WHERE id_san_pham = @SanPhamId;
        DELETE FROM dbo.san_pham_nhom WHERE id_san_pham = @SanPhamId;
        DELETE FROM dbo.san_pham_lien_quan WHERE id_san_pham = @SanPhamId OR id_san_pham_lien_quan = @SanPhamId;
        DELETE FROM dbo.san_pham_khuyen_mai WHERE id_san_pham = @SanPhamId;
        -- Các bảng ON DELETE CASCADE: ảnh, biến thể, cart items, review, v.v. sẽ tự dọn
        DELETE FROM dbo.san_pham WHERE id = @SanPhamId;

        COMMIT;
        PRINT N'✅ Đã xóa sản phẩm và dữ liệu liên quan.';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT N'❌ Lỗi khi xóa sản phẩm: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END
GO

-- Default cho cột loai trong san_pham_lien_quan
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints 
               WHERE parent_object_id=OBJECT_ID('dbo.san_pham_lien_quan') AND name='DF_splq_loai')
    ALTER TABLE dbo.san_pham_lien_quan 
    ADD CONSTRAINT DF_splq_loai DEFAULT (N'RELATED') FOR loai;
GO

-- Stored procedure upsert sản phẩm liên quan (tự reorder)
IF OBJECT_ID(N'dbo.UpsertSanPhamLienQuan', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[UpsertSanPhamLienQuan];
GO

CREATE PROCEDURE [dbo].[UpsertSanPhamLienQuan]
    @SanPhamId1 BIGINT,
    @SanPhamId2 BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Id1 BIGINT = CASE WHEN @SanPhamId1 < @SanPhamId2 THEN @SanPhamId1 ELSE @SanPhamId2 END;
    DECLARE @Id2 BIGINT = CASE WHEN @SanPhamId1 < @SanPhamId2 THEN @SanPhamId2 ELSE @SanPhamId1 END;

    IF @Id1 = @Id2 BEGIN PRINT N'❌ Không thể liên kết sản phẩm với chính nó.'; RETURN; END;
    IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE id = @Id1) OR 
       NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE id = @Id2)
    BEGIN PRINT N'❌ Một hoặc cả hai sản phẩm không tồn tại.'; RETURN; END;

    IF NOT EXISTS (SELECT 1 FROM dbo.san_pham_lien_quan WHERE id_san_pham=@Id1 AND id_san_pham_lien_quan=@Id2)
    BEGIN
        INSERT INTO dbo.san_pham_lien_quan (id_san_pham, id_san_pham_lien_quan, loai)
        VALUES (@Id1, @Id2, N'RELATED');
        PRINT N'✅ Đã thêm liên kết sản phẩm: ' + CAST(@Id1 AS NVARCHAR(20)) + N' ↔ ' + CAST(@Id2 AS NVARCHAR(20));
    END
    ELSE PRINT N'ℹ️ Liên kết sản phẩm đã tồn tại.';
END
GO

-- Trigger auto-reorder cho san_pham_lien_quan (chặn insert thủ công sai thứ tự)
IF OBJECT_ID('dbo.trg_splq_autoreorder','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_splq_autoreorder;
GO
CREATE TRIGGER dbo.trg_splq_autoreorder
ON dbo.san_pham_lien_quan
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT dbo.san_pham_lien_quan (id_san_pham, id_san_pham_lien_quan, loai, thu_tu, tu_dong, do_lien_quan, ngay_them)
    SELECT
        CASE WHEN i.id_san_pham < i.id_san_pham_lien_quan THEN i.id_san_pham ELSE i.id_san_pham_lien_quan END,
        CASE WHEN i.id_san_pham < i.id_san_pham_lien_quan THEN i.id_san_pham_lien_quan ELSE i.id_san_pham END,
        i.loai, i.thu_tu, i.tu_dong, i.do_lien_quan, ISNULL(i.ngay_them, SYSUTCDATETIME())
    FROM inserted i;
END
GO

	----------------------------------------------------------
	-- 3) INSERT SAMPLE DATA
	----------------------------------------------------------

	-- Insert vai tro
	IF NOT EXISTS (SELECT 1 FROM dbo.vai_tro WHERE ten_vai_tro = 'ADMIN')
		INSERT INTO dbo.vai_tro (ten_vai_tro, mo_ta, quyen_han, hoat_dong) 
		VALUES (N'ADMIN', N'Quản trị viên hệ thống', N'FULL_ACCESS', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.vai_tro WHERE ten_vai_tro = 'USER')
		INSERT INTO dbo.vai_tro (ten_vai_tro, mo_ta, quyen_han, hoat_dong) 
		VALUES (N'USER', N'Người dùng thông thường', N'BASIC_ACCESS', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.vai_tro WHERE ten_vai_tro = 'STAFF')
		INSERT INTO dbo.vai_tro (ten_vai_tro, mo_ta, quyen_han, hoat_dong) 
		VALUES (N'STAFF', N'Nhân viên', N'STAFF_ACCESS', 1);

	-- Insert danh muc (Mở rộng danh mục sản phẩm)
	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'ao-thiet-bi')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Áo thiết bị', N'ao-thiet-bi', N'Áo thiết bị thể thao chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'ao-thun')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Áo thun', N'ao-thun', N'Áo thun thể thao thoải mái', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'ao-khoac')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Áo khoác', N'ao-khoac', N'Áo khoác thể thao chống nước', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'quan-ao')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Quần áo', N'quan-ao', N'Quần áo thể thao đa dạng', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'quan-short')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Quần short', N'quan-short', N'Quần short thể thao năng động', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'quan-legging')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Quần legging', N'quan-legging', N'Quần legging thể thao ôm dáng', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'giay-dep')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Giày dép', N'giay-dep', N'Giày dép thể thao chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'giay-chay-bo')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Giày chạy bộ', N'giay-chay-bo', N'Giày chạy bộ chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'giay-bong-da')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Giày bóng đá', N'giay-bong-da', N'Giày bóng đá chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'giay-tennis')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Giày tennis', N'giay-tennis', N'Giày tennis chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'phu-kien')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Phụ kiện', N'phu-kien', N'Phụ kiện thể thao đa dạng', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'tui-xach')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Túi xách', N'tui-xach', N'Túi xách thể thao tiện lợi', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'do-boi')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Đồ bơi', N'do-boi', N'Đồ bơi chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'do-yoga')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Đồ yoga', N'do-yoga', N'Đồ yoga thoải mái', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'do-gym')
		INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Đồ gym', N'do-gym', N'Đồ tập gym chuyên nghiệp', 1, 1);

	-- Insert thuong hieu (Mở rộng thương hiệu)
	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'nike')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Nike', N'nike', N'Thương hiệu thể thao hàng đầu thế giới', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'adidas')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Adidas', N'adidas', N'Thương hiệu thể thao nổi tiếng toàn cầu', N'Đức', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'puma')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Puma', N'puma', N'Thương hiệu thể thao năng động và thời trang', N'Đức', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'vans')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Vans', N'vans', N'Thương hiệu giày skateboard và street style', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'under-armour')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Under Armour', N'under-armour', N'Thương hiệu thể thao công nghệ cao', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'new-balance')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'New Balance', N'new-balance', N'Thương hiệu giày thể thao chuyên nghiệp', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'converse')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Converse', N'converse', N'Thương hiệu giày cổ điển và thời trang', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'reebok')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Reebok', N'reebok', N'Thương hiệu thể thao lịch sử lâu đời', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'asics')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Asics', N'asics', N'Thương hiệu giày chạy bộ chuyên nghiệp', N'Nhật Bản', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'mizuno')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Mizuno', N'mizuno', N'Thương hiệu thể thao Nhật Bản chất lượng cao', N'Nhật Bản', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'wilson')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Wilson', N'wilson', N'Thương hiệu dụng cụ thể thao chuyên nghiệp', N'Mỹ', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'speedo')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Speedo', N'speedo', N'Thương hiệu đồ bơi chuyên nghiệp', N'Anh', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'lululemon')
		INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Lululemon', N'lululemon', N'Thương hiệu đồ yoga và fitness cao cấp', N'Canada', 1, 1);

	-- Insert danh muc mon the thao (Mở rộng môn thể thao)
	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-da')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Bóng đá', N'bong-da', N'Thiết bị bóng đá chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-ro')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Bóng rổ', N'bong-ro', N'Thiết bị bóng rổ chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'chay-bo')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Chạy bộ', N'chay-bo', N'Thiết bị chạy bộ và marathon', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'tennis')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Tennis', N'tennis', N'Thiết bị tennis chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-chuyen')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Bóng chuyền', N'bong-chuyen', N'Thiết bị bóng chuyền', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'cau-long')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Cầu lông', N'cau-long', N'Thiết bị cầu lông chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'boi-loi')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Bơi lội', N'boi-loi', N'Thiết bị bơi lội chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'yoga')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Yoga', N'yoga', N'Thiết bị yoga và thiền', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'gym')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Gym', N'gym', N'Thiết bị tập gym và fitness', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-ban')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Bóng bàn', N'bong-ban', N'Thiết bị bóng bàn', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'golf')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Golf', N'golf', N'Thiết bị golf chuyên nghiệp', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'skateboard')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Skateboard', N'skateboard', N'Thiết bị skateboard và street sport', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'dap-xe')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Đạp xe', N'dap-xe', N'Thiết bị đạp xe và cycling', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'boxing')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Boxing', N'boxing', N'Thiết bị boxing và võ thuật', 1, 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'dance')
		INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
		VALUES (N'Dance', N'dance', N'Thiết bị nhảy và khiêu vũ', 1, 1);

	-- Insert admin user
	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'admin@example.com')
	BEGIN
		DECLARE @adminRoleId BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'ADMIN');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, vai_tro_id, hoat_dong, email_verified) 
		VALUES (N'Administrator', N'admin@example.com', N'$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', @adminRoleId, 1, 1);
	END

	-- Insert sample user
	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'user@example.com')
	BEGIN
		DECLARE @userRoleId BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'USER');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, vai_tro_id, hoat_dong, email_verified) 
		VALUES (N'Test User', N'user@example.com', N'$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', @userRoleId, 1, 1);
	END

	-- Insert staff user
	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'staff@example.com')
	BEGIN
		DECLARE @staffRoleId BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'STAFF');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, vai_tro_id, hoat_dong, email_verified) 
		VALUES (N'Staff User', N'staff@example.com', N'$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', @staffRoleId, 1, 1);
	END

	-- Insert cau hinh
	IF NOT EXISTS (SELECT 1 FROM dbo.cau_hinh WHERE ten = 'SITE_NAME')
	BEGIN
		DECLARE @adminId5 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.cau_hinh (ten, gia_tri, mo_ta, loai, hoat_dong, nguoi_tao) 
		VALUES (N'SITE_NAME', N'Activewear Store', N'Tên website', N'SYSTEM', 1, @adminId5);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.cau_hinh WHERE ten = 'SITE_EMAIL')
	BEGIN
		DECLARE @adminId6 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.cau_hinh (ten, gia_tri, mo_ta, loai, hoat_dong, nguoi_tao) 
		VALUES (N'SITE_EMAIL', N'datnfpolysd45@gmail.com', N'Email liên hệ', N'SYSTEM', 1, @adminId6);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.cau_hinh WHERE ten = 'SITE_PHONE')
	BEGIN
		DECLARE @adminId7 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.cau_hinh (ten, gia_tri, mo_ta, loai, hoat_dong, nguoi_tao) 
		VALUES (N'SITE_PHONE', N'0123456789', N'Số điện thoại', N'SYSTEM', 1, @adminId7);
	END

	-- Insert banner
	IF NOT EXISTS (SELECT 1 FROM dbo.banner WHERE ten = 'Banner chính')
	BEGIN
		DECLARE @adminId BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.banner (ten, hinh_anh, mo_ta, vi_tri, thu_tu, hoat_dong, nguoi_tao) 
		VALUES (N'Banner chính', N'/images/banner-main.jpg', N'Banner chính trang chủ', N'MAIN', 1, 1, @adminId);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.banner WHERE ten = 'Banner phụ')
	BEGIN
		DECLARE @adminId2 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.banner (ten, hinh_anh, mo_ta, vi_tri, thu_tu, hoat_dong, nguoi_tao) 
		VALUES (N'Banner phụ', N'/images/banner-side.jpg', N'Banner phụ', N'SIDE', 1, 1, @adminId2);
	END

	-- Insert tag
	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'ban-chay')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Bán chạy', N'ban-chay', N'Sản phẩm bán chạy', N'#ff6b6b', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'moi-ve')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Mới về', N'moi-ve', N'Sản phẩm mới về', N'#4ecdc4', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'khuyen-mai')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Khuyến mãi', N'khuyen-mai', N'Sản phẩm khuyến mãi', N'#ffe66d', 1);

	-- Insert nhom san pham
	IF NOT EXISTS (SELECT 1 FROM dbo.nhom_san_pham WHERE slug = 'ao-thiet-bi-nam')
	BEGIN
		DECLARE @adminId10 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.nhom_san_pham (ten, slug, mo_ta, loai, hien_thi_trang_chu, hoat_dong, nguoi_tao) 
		VALUES (N'Áo thiết bị nam', N'ao-thiet-bi-nam', N'Nhóm áo thiết bị cho nam', N'GENDER', 1, 1, @adminId10);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.nhom_san_pham WHERE slug = 'ao-thiet-bi-nu')
	BEGIN
		DECLARE @adminId11 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.nhom_san_pham (ten, slug, mo_ta, loai, hien_thi_trang_chu, hoat_dong, nguoi_tao) 
		VALUES (N'Áo thiết bị nữ', N'ao-thiet-bi-nu', N'Nhóm áo thiết bị cho nữ', N'GENDER', 1, 1, @adminId11);
	END

	-- Insert khuyen mai
	IF NOT EXISTS (SELECT 1 FROM dbo.khuyen_mai WHERE ten = 'Giảm giá 10%')
	BEGIN
		DECLARE @adminId8 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.khuyen_mai (ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'Giảm giá 10%', N'Giảm giá 10% cho tất cả sản phẩm', N'PERCENTAGE', 10.00, 
				DATEADD(day, -30, SYSUTCDATETIME()), DATEADD(day, 30, SYSUTCDATETIME()), 1, @adminId8);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.khuyen_mai WHERE ten = 'Giảm 50k')
	BEGIN
		DECLARE @adminId9 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.khuyen_mai (ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'Giảm 50k', N'Giảm 50,000 VNĐ cho đơn hàng từ 500k', N'FIXED_AMOUNT', 50000.00, 
				DATEADD(day, -15, SYSUTCDATETIME()), DATEADD(day, 15, SYSUTCDATETIME()), 1, @adminId9);
	END

	-- Insert ma giam gia
	IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'WELCOME10')
	BEGIN
		DECLARE @adminId3 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'WELCOME10', N'Chào mừng 10%', N'Mã giảm giá chào mừng khách hàng mới', N'PERCENTAGE', 10.00, 
				DATEADD(day, -60, SYSUTCDATETIME()), DATEADD(day, 60, SYSUTCDATETIME()), 1, @adminId3);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'SAVE50K')
	BEGIN
		DECLARE @adminId4 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'SAVE50K', N'Tiết kiệm 50k', N'Mã giảm giá tiết kiệm', N'FIXED_AMOUNT', 50000.00, 
				DATEADD(day, -30, SYSUTCDATETIME()), DATEADD(day, 30, SYSUTCDATETIME()), 1, @adminId4);
	END

	-- Insert kho hang
	IF NOT EXISTS (SELECT 1 FROM dbo.kho_hang WHERE ten_kho = 'Kho Hà Nội')
	BEGIN
		DECLARE @adminId12 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.kho_hang (ten_kho, dia_chi, so_dien_thoai, nguoi_quan_ly, trang_thai, nguoi_tao) 
		VALUES (N'Kho Hà Nội', N'123 Đường ABC, Quận XYZ, Hà Nội', N'0123456789', N'Nguyễn Văn A', 1, @adminId12);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.kho_hang WHERE ten_kho = 'Kho TP.HCM')
	BEGIN
		DECLARE @adminId13 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.kho_hang (ten_kho, dia_chi, so_dien_thoai, nguoi_quan_ly, trang_thai, nguoi_tao) 
		VALUES (N'Kho TP.HCM', N'456 Đường DEF, Quận GHI, TP.HCM', N'0987654321', N'Trần Thị B', 1, @adminId13);
	END

	-- Insert van chuyen
	IF NOT EXISTS (SELECT 1 FROM dbo.van_chuyen WHERE ten_don_vi = 'Viettel Post')
	BEGIN
		DECLARE @adminId14 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.van_chuyen (ten_don_vi, mo_ta, gia_van_chuyen, thoi_gian_giao_hang, trang_thai, nguoi_tao) 
		VALUES (N'Viettel Post', N'Dịch vụ vận chuyển nhanh', 30000.00, N'1-2 ngày', 1, @adminId14);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.van_chuyen WHERE ten_don_vi = 'Giao Hàng Nhanh')
	BEGIN
		DECLARE @adminId15 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.van_chuyen (ten_don_vi, mo_ta, gia_van_chuyen, thoi_gian_giao_hang, trang_thai, nguoi_tao) 
		VALUES (N'Giao Hàng Nhanh', N'Dịch vụ giao hàng trong ngày', 50000.00, N'Same day', 1, @adminId15);
	END















































































	----------------------------------------------------------
	-- 7) INSERT ADDITIONAL SAMPLE DATA (Dữ liệu mẫu bổ sung)
	----------------------------------------------------------

	-- Thêm nhiều kho hàng hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.kho_hang WHERE ten_kho = 'Kho Đà Nẵng')
	BEGIN
		DECLARE @adminId16 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.kho_hang (ten_kho, dia_chi, so_dien_thoai, nguoi_quan_ly, trang_thai, nguoi_tao) 
		VALUES (N'Kho Đà Nẵng', N'789 Đường XYZ, Quận ABC, Đà Nẵng', N'0123456789', N'Lê Văn C', 1, @adminId16);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.kho_hang WHERE ten_kho = 'Kho Cần Thơ')
	BEGIN
		DECLARE @adminId17 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.kho_hang (ten_kho, dia_chi, so_dien_thoai, nguoi_quan_ly, trang_thai, nguoi_tao) 
		VALUES (N'Kho Cần Thơ', N'321 Đường DEF, Quận GHI, Cần Thơ', N'0987654321', N'Phạm Thị D', 1, @adminId17);
	END

	-- Thêm nhiều dịch vụ vận chuyển hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.van_chuyen WHERE ten_don_vi = 'J&T Express')
	BEGIN
		DECLARE @adminId18 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.van_chuyen (ten_don_vi, mo_ta, gia_van_chuyen, thoi_gian_giao_hang, trang_thai, nguoi_tao) 
		VALUES (N'J&T Express', N'Dịch vụ vận chuyển nhanh toàn quốc', 25000.00, N'2-3 ngày', 1, @adminId18);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.van_chuyen WHERE ten_don_vi = 'Shopee Express')
	BEGIN
		DECLARE @adminId19 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.van_chuyen (ten_don_vi, mo_ta, gia_van_chuyen, thoi_gian_giao_hang, trang_thai, nguoi_tao) 
		VALUES (N'Shopee Express', N'Dịch vụ vận chuyển Shopee', 20000.00, N'1-2 ngày', 1, @adminId19);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.van_chuyen WHERE ten_don_vi = 'Lazada Express')
	BEGIN
		DECLARE @adminId20 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.van_chuyen (ten_don_vi, mo_ta, gia_van_chuyen, thoi_gian_giao_hang, trang_thai, nguoi_tao) 
		VALUES (N'Lazada Express', N'Dịch vụ vận chuyển Lazada', 22000.00, N'2-3 ngày', 1, @adminId20);
	END

	-- Thêm nhiều khuyến mãi hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.khuyen_mai WHERE ten = 'Giảm giá 20%')
	BEGIN
		DECLARE @adminId21 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.khuyen_mai (ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'Giảm giá 20%', N'Giảm giá 20% cho đơn hàng từ 1 triệu', N'PERCENTAGE', 20.00, 
				DATEADD(day, -10, SYSUTCDATETIME()), DATEADD(day, 20, SYSUTCDATETIME()), 1, @adminId21);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.khuyen_mai WHERE ten = 'Giảm 100k')
	BEGIN
		DECLARE @adminId22 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.khuyen_mai (ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'Giảm 100k', N'Giảm 100,000 VNĐ cho đơn hàng từ 2 triệu', N'FIXED_AMOUNT', 100000.00, 
				DATEADD(day, -5, SYSUTCDATETIME()), DATEADD(day, 25, SYSUTCDATETIME()), 1, @adminId22);
	END

	-- Thêm nhiều mã giảm giá hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'SUMMER20')
	BEGIN
		DECLARE @adminId23 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'SUMMER20', N'Mùa hè 20%', N'Mã giảm giá mùa hè', N'PERCENTAGE', 20.00, 
				DATEADD(day, -30, SYSUTCDATETIME()), DATEADD(day, 30, SYSUTCDATETIME()), 1, @adminId23);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'NEWUSER15')
	BEGIN
		DECLARE @adminId24 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'NEWUSER15', N'Người dùng mới 15%', N'Mã giảm giá cho người dùng mới', N'PERCENTAGE', 15.00, 
				DATEADD(day, -60, SYSUTCDATETIME()), DATEADD(day, 60, SYSUTCDATETIME()), 1, @adminId24);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'VIP30')
	BEGIN
		DECLARE @adminId25 BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'admin@example.com');
		INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong, nguoi_tao) 
		VALUES (N'VIP30', N'VIP 30%', N'Mã giảm giá VIP', N'PERCENTAGE', 30.00, 
				DATEADD(day, -15, SYSUTCDATETIME()), DATEADD(day, 45, SYSUTCDATETIME()), 1, @adminId25);
	END

	-- Thêm nhiều tag hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'hot-trend')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Hot Trend', N'hot-trend', N'Sản phẩm hot trend', N'#ff4757', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'limited')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Limited Edition', N'limited', N'Sản phẩm phiên bản giới hạn', N'#ff6b6b', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'eco-friendly')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Eco Friendly', N'eco-friendly', N'Sản phẩm thân thiện môi trường', N'#2ed573', 1);

	IF NOT EXISTS (SELECT 1 FROM dbo.tag WHERE slug = 'premium')
		INSERT INTO dbo.tag (ten, slug, mo_ta, mau_sac, hoat_dong) 
		VALUES (N'Premium', N'premium', N'Sản phẩm cao cấp', N'#ffa502', 1);

	----------------------------------------------------------
	-- 8) INSERT SAMPLE USERS (Dữ liệu người dùng mẫu)
	----------------------------------------------------------

	-- Thêm nhiều admin hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'admin2@example.com')
	BEGIN
		DECLARE @adminRoleId2 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'ADMIN');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Nguyễn Văn Admin 2', N'admin2@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0987654321', N'123 Đường ABC, Quận 1, TP.HCM', @adminRoleId2, 1, 1, SYSUTCDATETIME());
	END

	-- Thêm nhiều staff hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'staff2@example.com')
	BEGIN
		DECLARE @staffRoleId2 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'STAFF');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Trần Thị Staff 2', N'staff2@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0123456789', N'456 Đường DEF, Quận 2, TP.HCM', @staffRoleId2, 1, 1, SYSUTCDATETIME());
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'staff3@example.com')
	BEGIN
		DECLARE @staffRoleId3 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'STAFF');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Lê Văn Staff 3', N'staff3@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0987654321', N'789 Đường GHI, Quận 3, TP.HCM', @staffRoleId3, 1, 1, SYSUTCDATETIME());
	END

	-- Thêm nhiều khách hàng hơn
	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'customer2@example.com')
	BEGIN
		DECLARE @customerRoleId2 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'USER');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Phạm Thị Customer 2', N'customer2@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0123456789', N'321 Đường JKL, Quận 4, TP.HCM', @customerRoleId2, 1, 1, SYSUTCDATETIME());
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'customer3@example.com')
	BEGIN
		DECLARE @customerRoleId3 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'USER');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Hoàng Văn Customer 3', N'customer3@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0987654321', N'654 Đường MNO, Quận 5, TP.HCM', @customerRoleId3, 1, 1, SYSUTCDATETIME());
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'customer4@example.com')
	BEGIN
		DECLARE @customerRoleId4 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'USER');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Vũ Thị Customer 4', N'customer4@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0123456789', N'987 Đường PQR, Quận 6, TP.HCM', @customerRoleId4, 1, 1, SYSUTCDATETIME());
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.nguoi_dung WHERE email = 'customer5@example.com')
	BEGIN
		DECLARE @customerRoleId5 BIGINT = (SELECT id FROM dbo.vai_tro WHERE ten_vai_tro = 'USER');
		INSERT INTO dbo.nguoi_dung (ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro_id, hoat_dong, email_verified, ngay_dang_ky) 
		VALUES (N'Đặng Văn Customer 5', N'customer5@example.com', N'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', N'0987654321', N'147 Đường STU, Quận 7, TP.HCM', @customerRoleId5, 1, 1, SYSUTCDATETIME());
	END

	----------------------------------------------------------
	-- INSERT NEW PRODUCTS (8 sản phẩm mới)
	----------------------------------------------------------

	-- Lấy ID của danh mục và thương hiệu
	DECLARE @danhMucQuanId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'quan-ao-the-thao');
	DECLARE @danhMucGiayId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-tennis');
	DECLARE @danhMucGiayChayBoId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-chay-bo');
	DECLARE @thuongHieu361Id BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = '361-degrees');
	DECLARE @thuongHieuLiNingId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'li-ning');
	DECLARE @thuongHieuAsicsId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'asics');
	DECLARE @monTheThaoTapLuyenId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'tap-luyen');
	DECLARE @monTheThaoCauLongId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'cau-long');
	DECLARE @monTheThaoTennisId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'tennis');
	DECLARE @monTheThaoChayBoId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'chay-bo');
	DECLARE @monTheThaoBongRoId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-ro');
	DECLARE @danhMucPhuKienId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'phu-kien');
	DECLARE @danhMucVayId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'vay');
	DECLARE @thuongHieuLeCoqId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'le-coq-sportif');
	DECLARE @monTheThaoGolfId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'golf');

	-- Sản phẩm 1: Quần nỉ 361º Nữ W562534009B-3C
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP001')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP001', 
			N'Quần nỉ 361º Nữ W562534009B-3C', 
			N'quan-ni-361-nu-w562534009b-3c', 
			N'Quần nỉ 361 được làm từ chất liệu nỉ cao cấp, mềm mịn, có khả năng giữ ấm tốt trong thời tiết lạnh. Lớp nỉ bên trong giúp giữ nhiệt hiệu quả, đồng thời mang lại cảm giác êm ái cho da, tạo sự thoải mái tối đa cho người mặc. Với khả năng co giãn nhẹ, quần nỉ 361 phù hợp cho các hoạt động thể thao nhẹ nhàng như chạy bộ, tập gym, hoặc thậm chí mặc ở nhà. Độ đàn hồi của quần giúp người mặc dễ dàng thực hiện các động tác mà không bị hạn chế.', 
			N'Quần nỉ 361º nữ với chất liệu nỉ cao cấp, mềm mịn, giữ ấm tốt. Phù hợp cho tập luyện và mặc hàng ngày.', 
			1168364.00, 
			1168364.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/q3s3090979fbd0515d99740f1813d1.jpg', 
			50, 
			N'50.8%Polyester, 40.8%Cotton, 8.4%Spandex', 
			N'Trung Quốc', 
			0.5, 
			N'LOOSE FIT', 
			@danhMucQuanId, 
			@thuongHieu361Id, 
			@monTheThaoTapLuyenId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 1
	DECLARE @sp1Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP001');
	IF @sp1Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp1Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XS-WHITE', N'XS', N'White', 10, 10, 1168364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-S-WHITE', N'S', N'White', 15, 15, 1168364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-M-WHITE', N'M', N'White', 15, 15, 1168364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-L-WHITE', N'L', N'White', 10, 10, 1168364.00);
	END

	-- Thêm ảnh cho sản phẩm 1
	IF @sp1Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp1Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'https://bizweb.dktcdn.net/100/340/361/products/q3s3090979fbd0515d99740f1813d1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'https://bizweb.dktcdn.net/100/340/361/products/q3s30910000753209e1a74a779ec2d.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'https://bizweb.dktcdn.net/100/340/361/products/q3s30909839a219f988414e1482204.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'https://bizweb.dktcdn.net/100/340/361/products/q3s309099c967f38b2bf9466f866c5.jpg', 0, 4);
	END

	-- Sản phẩm 2: Áo T-shirt Li-Ning Nam P-AAYV033-1V
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP002')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP002', 
			N'Áo T-shirt Li-Ning Nam P-AAYV033-1V', 
			N'ao-t-shirt-li-ning-nam-p-aayv033-1v', 
			N'Áo T-shirt Nam P-AAYV033-1V được thiết kế dành cho bộ môn cầu lông, sử dụng chất liệu vải dệt kim 100% polyester, mang lại cảm giác nhẹ, thoáng khí và thoải mái khi vận động. Công nghệ AT DRY giúp thấm hút mồ hôi nhanh, giữ cho cơ thể luôn khô ráo trong suốt quá trình thi đấu hoặc luyện tập. Thiết kế năng động, dễ phối đồ, phù hợp với phong cách thể thao hiện đại. Sản phẩm chính hãng, đảm bảo chất lượng.', 
			N'Áo T-shirt Li-Ning nam với công nghệ AT DRY, thấm hút mồ hôi nhanh. Phù hợp cho cầu lông và các môn thể thao khác.', 
			520364.00, 
			520364.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/xx01730e0e1025b4ac249a78bdea91.jpg', 
			60, 
			N'Vải dệt kim 100% Polyester', 
			N'Chính hãng', 
			0.3, 
			N'Regular Fit', 
			@danhMucQuanId, 
			@thuongHieuLiNingId, 
			@monTheThaoCauLongId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 2
	DECLARE @sp2Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP002');
	IF @sp2Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp2Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp2Id, N'SP002-S-NAVAL', N'S', N'Naval Academy', 10, 10, 520364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp2Id, N'SP002-M-NAVAL', N'M', N'Naval Academy', 15, 15, 520364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp2Id, N'SP002-L-NAVAL', N'L', N'Naval Academy', 15, 15, 520364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp2Id, N'SP002-XL-NAVAL', N'XL', N'Naval Academy', 12, 12, 520364.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp2Id, N'SP002-XXL-NAVAL', N'XXL', N'Naval Academy', 8, 8, 520364.00);
	END

	-- Thêm ảnh cho sản phẩm 2
	IF @sp2Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp2Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx01730e0e1025b4ac249a78bdea91.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx0173615a294de3ad94d4cba55223.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx01733feefaf6c30444fdf9089698.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx01731af1d9e3aade4468bbdc4e43.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx0173911906702dcb24f75ba6f7c3.jpg', 0, 5);
	END

	-- Sản phẩm 3: Áo T-shirt Li-Ning Nam P-AAYV043-1V
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP003')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP003', 
			N'Áo T-shirt Li-Ning Nam P-AAYV043-1V', 
			N'ao-t-shirt-li-ning-nam-p-aayv043-1v', 
			N'Áo T-shirt Nam P-AAYV043-1V thuộc dòng sản phẩm tập luyện, được làm từ chất liệu vải dệt kim cao cấp với sự kết hợp giữa viscose, polyamide, modal và elastane, mang lại cảm giác mềm mại, thoáng khí và co giãn tốt. Công nghệ AT DRY giúp thấm hút và làm khô mồ hôi nhanh chóng, giữ cho cơ thể luôn khô thoáng khi vận động. Thiết kế ôm vừa vặn, linh hoạt theo từng chuyển động. Phù hợp cho các buổi tập luyện hàng ngày với phong cách năng động, hiện đại.', 
			N'Áo T-shirt Li-Ning nam với công nghệ AT DRY, chất liệu cao cấp. Phù hợp cho tập luyện hàng ngày.', 
			589091.00, 
			589091.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/xx018036dd97f28f72a4ae4aa32c30-bf929644-e733-463f-9da3-d63f30c4f57b.jpg', 
			55, 
			N'Vải dệt kim 93% Polyester/7% Elastane', 
			N'Chính hãng', 
			0.3, 
			N'Regular Fit', 
			@danhMucQuanId, 
			@thuongHieuLiNingId, 
			@monTheThaoTapLuyenId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 3
	DECLARE @sp3Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP003');
	IF @sp3Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp3Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp3Id, N'SP003-S-BLACK', N'S', N'Black', 10, 10, 589091.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp3Id, N'SP003-M-BLACK', N'M', N'Black', 15, 15, 589091.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp3Id, N'SP003-L-BLACK', N'L', N'Black', 15, 15, 589091.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp3Id, N'SP003-XL-BLACK', N'XL', N'Black', 12, 12, 589091.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp3Id, N'SP003-XXL-BLACK', N'XXL', N'Black', 8, 8, 589091.00);
	END

	-- Thêm ảnh cho sản phẩm 3
	IF @sp3Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp3Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx018036dd97f28f72a4ae4aa32c30-bf929644-e733-463f-9da3-d63f30c4f57b.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx018090941f223b3714669bd09cb0-1467a38a-96ca-4df9-9a0a-0870d308b03f.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx01806d5a01c275f5d46e8a02a4cd-75ebbee3-4437-455a-b6f8-bd7613bf1b82.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx018040aaa8bf791ac4fa3a543f5a-46416abb-4543-4be0-8904-fa75b92b94fa.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx01810930d3de414a742408e87c5d-9f89f666-4f98-4a18-b606-f492b10c9e57.jpg', 0, 5);
	END

	-- Sản phẩm 4: Giày tennis/pickleball ASICS GEL-DEDICATE 8 Nữ
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP004')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP004', 
			N'Giày tennis/pickleball ASICS GEL-DEDICATE 8 Nữ', 
			N'giay-tennis-pickleball-asics-gel-dedicate-8-nu', 
			N'Giày tennis/pickleball ASICS GEL-DEDICATE 8 Nữ được thiết kế dành riêng cho phụ nữ, mang lại sự thoải mái và hiệu suất tối ưu trên sân tennis và pickleball. Với công nghệ GEL độc quyền của ASICS, giày cung cấp khả năng hấp thụ sốc vượt trội, giúp bảo vệ đôi chân trong những pha di chuyển mạnh. Thiết kế nhẹ nhàng, linh hoạt với đế ngoài có độ bám tốt, phù hợp cho mọi loại mặt sân. Chất liệu tổng hợp cao cấp đảm bảo độ bền và thoáng khí.', 
			N'Giày tennis/pickleball ASICS GEL-DEDICATE 8 dành cho nữ với công nghệ GEL, thoải mái và hiệu suất cao.', 
			1864473.00, 
			1864473.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-13.jpg', 
			25, 
			N'Tổng hợp', 
			N'Chính hãng', 
			0.8, 
			N'Regular Fit', 
			@danhMucGiayId, 
			@thuongHieuAsicsId, 
			@monTheThaoTennisId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 4
	DECLARE @sp4Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP004');
	IF @sp4Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp4Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-5.5-LICHEN', N'5.5', N'Lichen Rock / White', 3, 3, 1864473.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-6-LICHEN', N'6', N'Lichen Rock / White', 5, 5, 1864473.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-6.5-LICHEN', N'6.5', N'Lichen Rock / White', 4, 4, 1864473.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-7-LICHEN', N'7', N'Lichen Rock / White', 4, 4, 1864473.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-7.5-LICHEN', N'7.5', N'Lichen Rock / White', 3, 3, 1864473.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-8-LICHEN', N'8', N'Lichen Rock / White', 3, 3, 1864473.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp4Id, N'SP004-8.5-LICHEN', N'8.5', N'Lichen Rock / White', 2, 2, 1864473.00);
	END

	-- Thêm ảnh cho sản phẩm 4
	IF @sp4Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp4Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-13.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-8.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-15.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-14.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-12.jpg', 0, 5);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-9.jpg', 0, 6);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-10.jpg', 0, 7);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-11.jpg', 0, 8);
	END

	-- Sản phẩm 5: Giày chạy bộ ASICS DYNABLAST 5 Nam
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP005')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP005', 
			N'Giày chạy bộ ASICS DYNABLAST 5 Nam', 
			N'giay-chay-bo-asics-dynablast-5-nam', 
			N'Giày chạy bộ ASICS DYNABLAST 5 Nam được thiết kế dành riêng cho nam giới với công nghệ tiên tiến và chất liệu cao cấp. Với 100% Synthetic Fiber và 100% Rubber, giày mang lại độ bền cao và khả năng chống mài mòn tốt. Thiết kế động học với đế ngoài có độ bám tuyệt vời, phù hợp cho mọi loại địa hình chạy bộ. Công nghệ DYNABLAST của ASICS giúp tối ưu hóa năng lượng và giảm thiểu mệt mỏi trong quá trình chạy. Phù hợp cho cả chạy bộ đường dài và tập luyện hàng ngày.', 
			N'Giày chạy bộ ASICS DYNABLAST 5 nam với công nghệ tiên tiến, chất liệu cao cấp và thiết kế động học.', 
			2846291.00, 
			2846291.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-61.jpg', 
			20, 
			N'100% Synthetic Fiber/100% Rubber', 
			N'Chính hãng', 
			0.9, 
			N'Regular Fit', 
			@danhMucGiayChayBoId, 
			@thuongHieuAsicsId, 
			@monTheThaoChayBoId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 5
	DECLARE @sp5Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP005');
	IF @sp5Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp5Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp5Id, N'SP005-7.5-BLACK', N'7.5', N'Black/Winter Sea', 3, 3, 2846291.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp5Id, N'SP005-8-BLACK', N'8', N'Black/Winter Sea', 4, 4, 2846291.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp5Id, N'SP005-8.5-BLACK', N'8.5', N'Black/Winter Sea', 4, 4, 2846291.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp5Id, N'SP005-9-BLACK', N'9', N'Black/Winter Sea', 5, 5, 2846291.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp5Id, N'SP005-9.5-BLACK', N'9.5', N'Black/Winter Sea', 4, 4, 2846291.00);
	END

	-- Thêm ảnh cho sản phẩm 5
	IF @sp5Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp5Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-61.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-56.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-62.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-63.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-60.jpg', 0, 5);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-57.jpg', 0, 6);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'https://bizweb.dktcdn.net/100/340/361/products/cau-long-giay-58.jpg', 0, 7);
	END

	-- Sản phẩm 6: Áo T-shirt 361º Nam W552521106-2C
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP006')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP006', 
			N'Áo T-shirt 361º Nam W552521106-2C', 
			N'ao-t-shirt-361-nam-w552521106-2c', 
			N'Áo T-shirt 361º Nam W552521106-2C được thiết kế dành riêng cho nam giới với chất liệu 100% Polyester cao cấp. Áo mang lại cảm giác thoải mái, thoáng khí và dễ dàng vận động. Thiết kế hiện đại, phù hợp cho các hoạt động thể thao và mặc hàng ngày. Chất liệu Polyester có khả năng thấm hút mồ hôi tốt, giữ cho cơ thể luôn khô ráo trong quá trình vận động. Sản phẩm chính hãng 361º với chất lượng đảm bảo.', 
			N'Áo T-shirt 361º nam với chất liệu 100% Polyester, thoải mái và thoáng khí cho các hoạt động thể thao.', 
			542945.00, 
			775636.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/361q2s201206b1fe6e7ae5534ec388-bde6d97f-ce90-43a7-9c98-b130d507a3ff.jpg', 
			45, 
			N'100% Polyester', 
			N'Chính hãng', 
			0.3, 
			N'Regular Fit', 
			@danhMucQuanId, 
			@thuongHieu361Id, 
			@monTheThaoTapLuyenId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 6
	DECLARE @sp6Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP006');
	IF @sp6Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp6Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban, gia_khuyen_mai) 
		VALUES (@sp6Id, N'SP006-S-BLACK', N'S', N'Black', 8, 8, 775636.00, 542945.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban, gia_khuyen_mai) 
		VALUES (@sp6Id, N'SP006-M-BLACK', N'M', N'Black', 12, 12, 775636.00, 542945.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban, gia_khuyen_mai) 
		VALUES (@sp6Id, N'SP006-L-BLACK', N'L', N'Black', 10, 10, 775636.00, 542945.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban, gia_khuyen_mai) 
		VALUES (@sp6Id, N'SP006-XL-BLACK', N'XL', N'Black', 8, 8, 775636.00, 542945.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban, gia_khuyen_mai) 
		VALUES (@sp6Id, N'SP006-XXL-BLACK', N'XXL', N'Black', 7, 7, 775636.00, 542945.00);
	END

	-- Thêm ảnh cho sản phẩm 6
	IF @sp6Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp6Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp6Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q2s201206b1fe6e7ae5534ec388-bde6d97f-ce90-43a7-9c98-b130d507a3ff.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp6Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q2s20120300fbf67614ee4a00a3-4961a75b-2cde-4cf0-8934-627333260372.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp6Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q2s201208ca9c23bb80104e56be-28845c8a-ed19-4c21-b66b-6624e1c6b8f6.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp6Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q2s2012102e128180eac64db990-df57edca-cdab-4ba3-9cb2-027a019245cc.jpg', 0, 4);
	END

	-- Sản phẩm 7: Áo T-shirt Li-Ning Nam AHSV213-5V
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP007')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP007', 
			N'Áo T-shirt Li-Ning Nam AHSV213-5V', 
			N'ao-t-shirt-li-ning-nam-ahsv213-5v', 
			N'Áo phông form dáng suông vừa, kiểu dáng cổ điển, phù hợp với nhiều dáng người, dễ phối đồ. Chất liệu cao cấp thoáng khí, giữ form tốt, bền dáng, tích hợp công nghệ AT DRY FREEZE tạo cảm giác mát mẻ, thoải mái ngay cả khi thời tiết nóng bức hoặc khi tập luyện thể thao. Sản phẩm được thiết kế dành riêng cho bóng rổ với chất liệu Cotton 71% và Polyester 29% mang lại sự thoải mái tối đa.', 
			N'Áo T-shirt Li-Ning nam với công nghệ AT DRY FREEZE, chất liệu cao cấp. Phù hợp cho bóng rổ và các môn thể thao khác.', 
			834545.00, 
			834545.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/ahsv2135v2bb6a7139e37b4da8a291.jpg', 
			40, 
			N'Cotton 71% Polyester 29%', 
			N'Chính hãng', 
			0.3, 
			N'Regular Fit', 
			@danhMucQuanId, 
			@thuongHieuLiNingId, 
			@monTheThaoBongRoId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 7
	DECLARE @sp7Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP007');
	IF @sp7Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp7Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp7Id, N'SP007-XS-BLACK', N'XS', N'Black', 5, 5, 834545.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp7Id, N'SP007-S-BLACK', N'S', N'Black', 8, 8, 834545.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp7Id, N'SP007-M-BLACK', N'M', N'Black', 12, 12, 834545.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp7Id, N'SP007-L-BLACK', N'L', N'Black', 10, 10, 834545.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp7Id, N'SP007-XL-BLACK', N'XL', N'Black', 5, 5, 834545.00);
	END

	-- Thêm ảnh cho sản phẩm 7
	IF @sp7Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp7Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp7Id, N'https://bizweb.dktcdn.net/100/340/361/products/ahsv2135v2bb6a7139e37b4da8a291.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp7Id, N'https://bizweb.dktcdn.net/100/340/361/products/ahsv2135v5699fc3f85bc34b769e4b.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp7Id, N'https://bizweb.dktcdn.net/100/340/361/products/ahsv2135v30ca6bf6cc3854acaa1b6.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp7Id, N'https://bizweb.dktcdn.net/100/340/361/products/ahsv2135v484d740b53c4e44a7b1f1.jpg', 0, 4);
	END

	-- Sản phẩm 8: Quần short 361º Nam W552531702-4C
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP008')
	BEGIN
		INSERT INTO dbo.san_pham (
			ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
			so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
			id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
			hoat_dong, ngay_tao
		) VALUES (
			N'SP008', 
			N'Quần short 361º Nam W552531702-4C', 
			N'quan-short-361-nam-w552531702-4c', 
			N'Quần short 361º thường được làm từ các chất liệu hiệu suất cao như polyester, cotton pha hoặc vải tổng hợp thoáng khí, mang lại khả năng thấm hút mồ hôi nhanh và giúp da luôn khô thoáng trong suốt quá trình vận động. Những chất liệu này không chỉ nhẹ và mềm mại mà còn có độ bền cao, phù hợp với cường độ hoạt động thường xuyên. Thiết kế đơn giản, hiện đại mang phong cách thể thao mạnh mẽ, dễ dàng phối hợp với nhiều kiểu áo khác nhau. Các đường cắt may gọn gàng, tinh tế cùng với form dáng rộng rãi tạo cảm giác thoải mái, hỗ trợ vận động linh hoạt. Sản phẩm đặc biệt thích hợp cho việc tập luyện, dã ngoại, chơi thể thao hoặc các hoạt động ngoài trời.', 
			N'Quần short 361º nam với công nghệ +1 Ice, +1 Easy, chất liệu cao cấp. Phù hợp cho chạy bộ và các hoạt động thể thao.', 
			775636.00, 
			775636.00, 
			N'https://bizweb.dktcdn.net/100/340/361/products/361q3s206906b9edb056372a4e4c8b-a27be9cc-f084-43c6-936b-ed443df6b225.jpg', 
			35, 
			N'87.4% Polyamide 12.6% Spandex', 
			N'Chính hãng', 
			0.4, 
			N'LOOSE FIT', 
			@danhMucQuanId, 
			@thuongHieu361Id, 
			@monTheThaoChayBoId, 
			1, 
			SYSUTCDATETIME()
		);
	END

	-- Thêm biến thể cho sản phẩm 8
	DECLARE @sp8Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP008');
	IF @sp8Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp8Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp8Id, N'SP008-XS-EXCALIBUR', N'XS', N'Excalibur', 3, 3, 775636.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp8Id, N'SP008-S-EXCALIBUR', N'S', N'Excalibur', 8, 8, 775636.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp8Id, N'SP008-M-EXCALIBUR', N'M', N'Excalibur', 12, 12, 775636.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp8Id, N'SP008-L-EXCALIBUR', N'L', N'Excalibur', 8, 8, 775636.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp8Id, N'SP008-XL-EXCALIBUR', N'XL', N'Excalibur', 4, 4, 775636.00);
	END

	-- Thêm ảnh cho sản phẩm 8
	IF @sp8Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp8Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp8Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q3s206906b9edb056372a4e4c8b-a27be9cc-f084-43c6-936b-ed443df6b225.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp8Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q3s2069122d12222fb11040338a-6a9debf2-7ffc-40b4-bdc1-119c4468d02b.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp8Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q3s2069083affdf57b0204c1f9d-b898471e-ecc2-4a28-a045-28fa155a7ed7.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp8Id, N'https://bizweb.dktcdn.net/100/340/361/products/361q3s2069109a3038f1edc4476fbf-90341ed1-27dc-4d09-855e-41273d1734bf.jpg', 0, 4);
	END

-- Sản phẩm 9: Mũ thể thao 361º Unisex W512512005-2
IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP009')
BEGIN
	INSERT INTO dbo.san_pham (
		ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
		so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
		id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
		hoat_dong, ngay_tao
	) VALUES (
		N'SP009', 
		N'Mũ thể thao 361º Unisex W512512005-2', 
		N'mu-the-thao-361-unisex-w512512005-2', 
		N'Mũ thể thao 361º với thiết kế độc đáo và nổi bật, mang đến sự phong cách và cá nhân hóa cho người sử dụng. Tích hợp công nghệ chống mồ hôi, giúp duy trì sự thoải mái trong quá trình hoạt động thể thao. Sử dụng chất liệu chất lượng cao như vải thoáng khí, nhằm tối ưu hóa sự thoải mái và đảm bảo độ bền của sản phẩm. Có khả năng điều chỉnh kích thước, giúp phù hợp với nhiều kích cỡ đầu khác nhau và mang lại sự thoải mái tối đa. Thích hợp cho nhiều hoạt động thể thao khác nhau, từ chạy bộ đến đua xe đạp, bóng rổ và các môn thể thao khác.', 
		N'Mũ thể thao 361º unisex với thiết kế độc đáo, công nghệ chống mồ hôi và chất liệu thoáng khí cao cấp.', 
		382909.00, 
		382909.00, 
		N'https://bizweb.dktcdn.net/100/340/361/products/xx090793f38ef2858d5453c83d4258-f60f4c5e-604f-4894-a7bb-7fc07914b8c5.jpg', 
		25, 
		N'88%Polyamide 12%Spandex', 
		N'Trung Quốc', 
		0.1, 
		N'ONE SIZE', 
		@danhMucPhuKienId, 
		@thuongHieu361Id, 
		@monTheThaoBongRoId, 
		1, 
		SYSUTCDATETIME()
	);
END

-- Thêm biến thể cho sản phẩm 9
DECLARE @sp9Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP009');
IF @sp9Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp9Id)
BEGIN
	INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
	VALUES (@sp9Id, N'SP009-ONE-KHAKI', N'ONE SIZE', N'Khaki', 25, 25, 382909.00);
END

-- Thêm ảnh cho sản phẩm 9
IF @sp9Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp9Id)
BEGIN
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp9Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx090793f38ef2858d5453c83d4258-f60f4c5e-604f-4894-a7bb-7fc07914b8c5.jpg', 1, 1);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp9Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx09074902e854a933f4a84b797deb-210bc953-7232-4790-9f7a-b121580ef0b0.jpg', 0, 2);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp9Id, N'https://bizweb.dktcdn.net/100/340/361/products/xx09075a8201f475b0641c58109ab2-9b9aff40-3cd3-4dc2-97e9-aa694eca374f.jpg', 0, 3);
	END

-- Sản phẩm 10: Chân váy le coq golf Nữ GQ322LSK81-LBGE
IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE ma_san_pham = 'SP010')
BEGIN
	INSERT INTO dbo.san_pham (
		ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
		so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, 
		id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
		hoat_dong, ngay_tao
	) VALUES (
		N'SP010', 
		N'Chân váy le coq golf Nữ GQ322LSK81-LBGE', 
		N'chan-vay-le-coq-golf-nu-gq322lsk81-lbge', 
		N'Chân váy xếp ly nữ được thiết kế với đường xếp ly mềm mại, mang lại vẻ nữ tính và tạo điểm nhấn thanh lịch cho mỗi cú swing. Form dáng ôm sát nhẹ nhàng cùng đường eo thon gọn và chiều dài vừa phải giúp tôn dáng, đồng thời dễ dàng phối hợp với nhiều kiểu áo, mang đến phong cách năng động nhưng vẫn tinh tế. Sản phẩm được chế tác từ chất liệu polyspandex gân nhẹ, tạo độ co giãn linh hoạt và cảm giác thoải mái khi vận động. Túi đựng bóng đi kèm tăng tính tiện lợi cho các vòng golf, giúp người mặc tận hưởng sự thoải mái và sự tiện ích trong một thiết kế hiện đại.', 
		N'Chân váy le coq golf nữ với thiết kế xếp ly mềm mại, form dáng ôm sát thanh lịch. Chất liệu polyspandex co giãn linh hoạt.', 
		4899273.00, 
		4899273.00, 
		N'https://bizweb.dktcdn.net/100/340/361/products/dsc060408e2e0d08b89d4bd3bb8756.jpg', 
		15, 
		N'Nylon 89% Polyurethane 11%', 
		N'Việt Nam', 
		0.2, 
		N'REGULAR FIT', 
		@danhMucVayId, 
		@thuongHieuLeCoqId, 
		@monTheThaoGolfId, 
		1, 
		SYSUTCDATETIME()
	);
END

-- Thêm biến thể cho sản phẩm 10
DECLARE @sp10Id BIGINT = (SELECT id FROM dbo.san_pham WHERE ma_san_pham = 'SP010');
IF @sp10Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp10Id)
BEGIN
	INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
	VALUES (@sp10Id, N'SP010-61-LIGHTBEIGE', N'61', N'Light Beige', 5, 5, 4899273.00);
	INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
	VALUES (@sp10Id, N'SP010-64-LIGHTBEIGE', N'64', N'Light Beige', 5, 5, 4899273.00);
	INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
	VALUES (@sp10Id, N'SP010-67-LIGHTBEIGE', N'67', N'Light Beige', 5, 5, 4899273.00);
END

-- Thêm ảnh cho sản phẩm 10
IF @sp10Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp10Id)
BEGIN
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'https://bizweb.dktcdn.net/100/340/361/products/dsc060408e2e0d08b89d4bd3bb8756.jpg', 1, 1);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'https://bizweb.dktcdn.net/100/340/361/products/dsc06046df53fb905ca844db830181.jpg', 0, 2);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'https://bizweb.dktcdn.net/100/340/361/products/dsc060423508c10976a14f46ad43bc.jpg', 0, 3);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'https://bizweb.dktcdn.net/100/340/361/products/dsc06044959a00ae6eb4451497e349.jpg', 0, 4);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'https://bizweb.dktcdn.net/100/340/361/products/dsc06048675041cf3568415aa2f89f.jpg', 0, 5);
	INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'https://bizweb.dktcdn.net/100/340/361/products/dsc06050409593e96c474c59a4559e.jpg', 0, 6);
END

PRINT N'✅ Hoàn tất tạo/cập nhật schema + dữ liệu mẫu cho DATN.';
PRINT N'📊 Tổng cộng: ~38 bảng (32 core + 6 mở rộng), kèm view & stored procedures.';
PRINT N'🔧 Đã xử lý xung đột CASCADE PATH.';
PRINT N'🗑️ Đã xóa toàn bộ dữ liệu sản phẩm (sản phẩm, biến thể, ảnh, đơn hàng, đánh giá, yêu thích).';
PRINT N'🏪 Đã thêm nhiều kho hàng, vận chuyển, khuyến mãi.';
PRINT N'👥 Đã thêm nhiều người dùng (admin, staff, khách hàng).';
PRINT N'🔒 OTP: hash + salt + index + brute-force protection.';
PRINT N'💰 Chuẩn DECIMAL(19,4).';
PRINT N'⏰ UTC: dùng SYSUTCDATETIME().';
PRINT N'🛡️ CHECK constraints & index tối ưu.';
PRINT N'🔗 Đã thêm TRIGGER auto-update ngay_cap_nhat (tránh vòng lặp).';
PRINT N'🎯 Đã sửa lỗi UNIQUE NULL trong giỏ hàng.';
PRINT N'🌐 Chuẩn hóa NVARCHAR cho Unicode.';
PRINT N'🔍 Full-Text Search cho sản phẩm (với error handling).';
PRINT N'🛠️ Stored procedure xóa sản phẩm an toàn (ẩn thay vì xóa cứng).';
PRINT N'📈 Index covering cho báo cáo vận chuyển.';
PRINT N'🔄 SP upsert sản phẩm liên quan (tự reorder + DEFAULT loai).';
PRINT N'🛡️ Validation nới lỏng - để app validate chi tiết.';
PRINT N'🔧 Đã sửa 5 lỗi: SP duplicate, NOT NULL loai, block lặp, SKU trim, covering index.';
PRINT N'🛡️ Đã bỏ unique email gốc, chỉ dùng email_lc.';
PRINT N'🔄 Trigger auto-reorder cho san_pham_lien_quan.';
PRINT N'📝 Đã sửa dữ liệu mẫu cho hợp lý (Vans Old Skool, Túi Puma).';
PRINT N'🔧 Đã sửa lỗi filtered index non-deterministic function.';
PRINT N'📞 Đã siết CHECK số điện thoại (chỉ số và dấu +).';
PRINT N'🔗 Đã thêm FK cho san_pham.nguoi_tao/nguoi_cap_nhat.';
PRINT N'📊 Đã thêm index tối ưu truy vấn theo giá.';
PRINT N'🚀 Script idempotent - chạy được nhiều lần an toàn.';

----------------------------------------------------------
-- 4) PERFORMANCE INDEXES (Tối ưu hóa cho admin panel)
----------------------------------------------------------

-- Indexes cho bảng san_pham (tối ưu queries admin)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_san_pham_hoat_dong' AND object_id = OBJECT_ID('dbo.san_pham'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_san_pham_hoat_dong] ON [dbo].[san_pham] ([hoat_dong] ASC);
    PRINT N'✅ Tạo index IX_san_pham_hoat_dong';
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_san_pham_danh_muc' AND object_id = OBJECT_ID('dbo.san_pham'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_san_pham_danh_muc] ON [dbo].[san_pham] ([id_danh_muc] ASC);
    PRINT N'✅ Tạo index IX_san_pham_danh_muc';
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_san_pham_thuong_hieu' AND object_id = OBJECT_ID('dbo.san_pham'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_san_pham_thuong_hieu] ON [dbo].[san_pham] ([id_thuong_hieu] ASC);
    PRINT N'✅ Tạo index IX_san_pham_thuong_hieu';
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_san_pham_mon_the_thao' AND object_id = OBJECT_ID('dbo.san_pham'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_san_pham_mon_the_thao] ON [dbo].[san_pham] ([id_mon_the_thao] ASC);
    PRINT N'✅ Tạo index IX_san_pham_mon_the_thao';
END

-- Composite index cho search queries
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_san_pham_search' AND object_id = OBJECT_ID('dbo.san_pham'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_san_pham_search] ON [dbo].[san_pham] 
    ([hoat_dong] ASC, [id_danh_muc] ASC, [id_thuong_hieu] ASC, [id_mon_the_thao] ASC)
    INCLUDE ([ten], [gia], [so_luong_ton], [ngay_tao]);
    PRINT N'✅ Tạo composite index IX_san_pham_search';
END

-- Index cho text search
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_san_pham_ten' AND object_id = OBJECT_ID('dbo.san_pham'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_san_pham_ten] ON [dbo].[san_pham] ([ten] ASC);
    PRINT N'✅ Tạo index IX_san_pham_ten';
END

-- Indexes cho bảng danh_muc
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_danh_muc_hoat_dong' AND object_id = OBJECT_ID('dbo.danh_muc'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_danh_muc_hoat_dong] ON [dbo].[danh_muc] ([hoat_dong] ASC);
    PRINT N'✅ Tạo index IX_danh_muc_hoat_dong';
END

-- Indexes cho bảng thuong_hieu
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_thuong_hieu_hoat_dong' AND object_id = OBJECT_ID('dbo.thuong_hieu'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_thuong_hieu_hoat_dong] ON [dbo].[thuong_hieu] ([hoat_dong] ASC);
    PRINT N'✅ Tạo index IX_thuong_hieu_hoat_dong';
END

-- Indexes cho bảng danh_muc_mon_the_thao
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_danh_muc_mon_the_thao_hoat_dong' AND object_id = OBJECT_ID('dbo.danh_muc_mon_the_thao'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_danh_muc_mon_the_thao_hoat_dong] ON [dbo].[danh_muc_mon_the_thao] ([hoat_dong] ASC);
    PRINT N'✅ Tạo index IX_danh_muc_mon_the_thao_hoat_dong';
END

PRINT N'🚀 Đã tạo tất cả performance indexes cho admin panel!';
	GO
