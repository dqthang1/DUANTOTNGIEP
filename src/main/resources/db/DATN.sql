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
	-- 4) INSERT SAMPLE PRODUCTS (50+ sản phẩm mẫu đa dạng)
	----------------------------------------------------------

	-- Lấy ID của danh mục và thương hiệu
	DECLARE @aoThietBiId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'ao-thiet-bi');
	DECLARE @aoThunId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'ao-thun');
	DECLARE @aoKhoacId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'ao-khoac');
	DECLARE @quanAoId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'quan-ao');
	DECLARE @quanShortId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'quan-short');
	DECLARE @quanLeggingId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'quan-legging');
	DECLARE @giayDepId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-dep');
	DECLARE @giayChayBoId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-chay-bo');
	DECLARE @giayBongDaid BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-bong-da');
	DECLARE @giayTennisId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-tennis');
	DECLARE @phuKienId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'phu-kien');
	DECLARE @tuiXachId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'tui-xach');
	DECLARE @doBoiId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'do-boi');
	DECLARE @doYogaId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'do-yoga');
	DECLARE @doGymId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'do-gym');

	DECLARE @nikeId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'nike');
	DECLARE @adidasId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'adidas');
	DECLARE @pumaId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'puma');
	DECLARE @vansId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'vans');
	DECLARE @underArmourId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'under-armour');
	DECLARE @newBalanceId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'new-balance');
	DECLARE @converseId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'converse');
	DECLARE @reebokId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'reebok');
	DECLARE @asicsId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'asics');
	DECLARE @mizunoId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'mizuno');
	DECLARE @wilsonId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'wilson');
	DECLARE @speedoId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'speedo');
	DECLARE @lululemonId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'lululemon');

	DECLARE @bongDaId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-da');
	DECLARE @bongRoId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-ro');
	DECLARE @chayBoId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'chay-bo');
	DECLARE @tennisId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'tennis');
	DECLARE @bongChuyenId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-chuyen');
	DECLARE @cauLongId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'cau-long');
	DECLARE @boiLoiId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'boi-loi');
	DECLARE @yogaId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'yoga');
	DECLARE @gymId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'gym');
	DECLARE @bongBanId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-ban');
	DECLARE @golfId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'golf');
	DECLARE @skateboardId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'skateboard');
	DECLARE @dapXeId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'dap-xe');
	DECLARE @boxingId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'boxing');
	DECLARE @danceId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'dance');

	-- 1. Áo đấu bóng đá Nike
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-dau-bong-da-nike-2024')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP001', N'Áo Đấu Bóng Đá Nike 2024', N'ao-dau-bong-da-nike-2024',
				N'Áo đấu bóng đá Nike với thiết kế hiện đại, chất liệu Dri-FIT thấm hút mồ hôi tốt, phù hợp cho các trận đấu chuyên nghiệp. Sản phẩm được thiết kế với công nghệ tiên tiến giúp vận động viên cảm thấy thoải mái trong suốt trận đấu.',
				N'Áo đấu bóng đá Nike với công nghệ Dri-FIT', 450000.00, 500000.00, N'/images/products/ao-dau-nike-1.jpg',
				50, N'100% Polyester Dri-FIT', N'Việt Nam', 0.25, N'L, XL, XXL', 1250, 89, 4.5, 23,
				@aoThietBiId, @nikeId, @bongDaId, 1, 1, 1, 1);

	-- 2. Giày chạy bộ Adidas
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-chay-bo-adidas-ultraboost')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP002', N'Giày Chạy Bộ Adidas Ultraboost 22', N'giay-chay-bo-adidas-ultraboost',
				N'Giày chạy bộ Adidas Ultraboost 22 với công nghệ Boost đệm êm, thiết kế Primeknit linh hoạt. Phù hợp cho chạy đường dài, marathon và tập luyện hàng ngày.',
				N'Giày chạy bộ Adidas với công nghệ Boost tiên tiến', 2200000.00, 2500000.00, N'/images/products/giay-adidas-ultraboost-1.jpg',
				30, N'Primeknit + Boost', N'Đức', 0.85, N'38-44', 2100, 156, 4.8, 67,
				@giayDepId, @adidasId, @chayBoId, 1, 1, 1, 0);

	-- 3. Quần short thể thao Puma
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'quan-short-the-thao-puma')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP003', N'Quần Short Thể Thao Puma', N'quan-short-the-thao-puma',
				N'Quần short thể thao Puma với thiết kế năng động, chất liệu Dry Cell thấm hút mồ hôi. Phù hợp cho tập gym, chạy bộ và các hoạt động thể thao.',
				N'Quần short thể thao Puma với công nghệ Dry Cell', 380000.00, 450000.00, N'/images/products/quan-short-puma-1.jpg',
				75, N'100% Polyester Dry Cell', N'Đức', 0.15, N'M, L, XL', 890, 234, 4.3, 45,
				@quanAoId, @pumaId, @chayBoId, 1, 0, 1, 0);

	-- 4. Áo thun tennis Vans
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-thun-tennis-vans')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP004', N'Áo Thun Tennis Vans', N'ao-thun-tennis-vans',
				N'Áo thun tennis Vans với thiết kế trẻ trung, chất liệu cotton mềm mại. Phù hợp cho chơi tennis và các hoạt động thể thao khác.',
				N'Áo thun tennis Vans với thiết kế trẻ trung', 280000.00, 320000.00, N'/images/products/ao-thun-vans-1.jpg',
				60, N'100% Cotton', N'Mỹ', 0.18, N'S, M, L, XL', 567, 123, 4.2, 28,
				@quanAoId, @vansId, @tennisId, 1, 0, 0, 1);

	-- 5. Giày skateboard Vans
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-skateboard-vans-old-skool')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP005', N'Giày Skateboard Vans Old Skool', N'giay-skateboard-vans-old-skool',
				N'Giày skateboard Vans Old Skool - biểu tượng của văn hóa skate. Thiết kế cổ điển với độ bền cao, phù hợp cho skateboard và street style.',
				N'Giày skateboard Vans Old Skool - biểu tượng street style', 1200000.00, 1500000.00, N'/images/products/giay-vans-oldskool-1.jpg',
				40, N'Canvas + Suede', N'Mỹ', 0.75, N'36-43', 1456, 98, 4.6, 52,
				@giayDepId, @vansId, NULL, 1, 1, 0, 0);

	-- 6. Áo hoodie Nike
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-hoodie-nike-sportswear')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP006', N'Áo Hoodie Nike Sportswear', N'ao-hoodie-nike-sportswear',
				N'Áo hoodie Nike Sportswear với thiết kế thời trang, chất liệu cotton blend ấm áp. Phù hợp cho mùa đông và street style.',
				N'Áo hoodie Nike Sportswear thời trang và ấm áp', 680000.00, 750000.00, N'/images/products/hoodie-nike-1.jpg',
				45, N'80% Cotton, 20% Polyester', N'Việt Nam', 0.65, N'S, M, L, XL', 1123, 167, 4.4, 41,
				@quanAoId, @nikeId, @chayBoId, 1, 1, 0, 1);

	-- 7. Quần legging thể thao Adidas
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'quan-legging-the-thao-adidas')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP007', N'Quần Legging Thể Thao Adidas', N'quan-legging-the-thao-adidas',
				N'Quần legging thể thao Adidas với thiết kế ôm dáng, chất liệu AEROREADY thấm hút mồ hôi. Phù hợp cho yoga, gym và chạy bộ.',
				N'Quần legging Adidas với công nghệ AEROREADY', 520000.00, 580000.00, N'/images/products/legging-adidas-1.jpg',
				55, N'Polyester + Elastane', N'Đức', 0.22, N'XS, S, M, L', 876, 145, 4.5, 38,
				@quanAoId, @adidasId, @chayBoId, 1, 0, 1, 0);

	-- 8. Băng đô thể thao Nike
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'bang-do-the-thao-nike')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP008', N'Băng Đô Thể Thao Nike', N'bang-do-the-thao-nike',
				N'Băng đô thể thao Nike với thiết kế thoải mái, chất liệu Dri-FIT thấm hút mồ hôi. Giúp giữ tóc gọn gàng trong khi tập luyện.',
				N'Băng đô Nike Dri-FIT giữ tóc gọn gàng khi tập luyện', 180000.00, 220000.00, N'/images/products/bang-do-nike-1.jpg',
				80, N'100% Polyester Dri-FIT', N'Việt Nam', 0.05, N'One Size', 445, 89, 4.1, 22,
				@phuKienId, @nikeId, @chayBoId, 1, 0, 0, 1);

	-- 9. Túi thể thao Puma
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'tui-the-thao-puma-backpack')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP009', N'Túi Thể Thao Puma Backpack', N'tui-the-thao-puma-backpack',
				N'Túi thể thao Puma Backpack với thiết kế đa năng, nhiều ngăn tiện lợi. Phù hợp cho đi tập gym, du lịch và sinh hoạt hàng ngày.',
				N'Túi thể thao Puma Backpack đa năng và tiện lợi', 420000.00, 480000.00, N'/images/products/tui-puma-1.jpg',
				35, N'Polyester + Nylon', N'Đức', 0.85, N'One Size', 634, 112, 4.3, 29,
				@phuKienId, @pumaId, NULL, 1, 1, 0, 0);

	-- 10. Giày tennis Adidas
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-tennis-adidas-gamecourt')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP010', N'Giày Tennis Adidas Gamecourt', N'giay-tennis-adidas-gamecourt',
				N'Giày tennis Adidas Gamecourt với thiết kế chuyên nghiệp, đế cao su bền bỉ. Phù hợp cho chơi tennis và các môn thể thao sân cứng.',
				N'Giày tennis Adidas Gamecourt chuyên nghiệp', 1600000.00, 1800000.00, N'/images/products/giay-tennis-adidas-1.jpg',
				25, N'Synthetic + Rubber', N'Đức', 0.78, N'38-44', 987, 76, 4.7, 34,
				@giayDepId, @adidasId, @tennisId, 1, 1, 1, 1);

	-- 11. Giày bóng đá Nike Mercurial
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-bong-da-nike-mercurial')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP011', N'Giày Bóng Đá Nike Mercurial Vapor 15', N'giay-bong-da-nike-mercurial',
				N'Giày bóng đá Nike Mercurial Vapor 15 với công nghệ Flyknit và đế FG. Thiết kế tối ưu cho tốc độ và kiểm soát bóng, phù hợp cho sân cỏ tự nhiên.',
				N'Giày bóng đá Nike Mercurial với công nghệ Flyknit', 2800000.00, 3200000.00, N'/images/products/giay-bong-da-nike-mercurial-1.jpg',
				40, N'Flyknit + TPU', N'Việt Nam', 0.45, N'38-44', 2100, 45, 4.6, 28,
				@giayBongDaid, @nikeId, @bongDaId, 1, 1, 1, 1);

	-- 12. Giày chạy bộ New Balance 1080
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-chay-bo-new-balance-1080')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP012', N'Giày Chạy Bộ New Balance 1080v12', N'giay-chay-bo-new-balance-1080',
				N'Giày chạy bộ New Balance 1080v12 với công nghệ Fresh Foam X đệm êm. Thiết kế tối ưu cho chạy đường dài và marathon.',
				N'Giày chạy bộ New Balance với Fresh Foam X', 2400000.00, 2800000.00, N'/images/products/giay-chay-bo-new-balance-1080-1.jpg',
				35, N'Fresh Foam X + Mesh', N'Mỹ', 0.68, N'38-44', 1850, 67, 4.7, 42,
				@giayChayBoId, @newBalanceId, @chayBoId, 1, 1, 0, 1);

	-- 13. Giày basketball Nike Air Jordan
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-basketball-nike-air-jordan')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP013', N'Giày Basketball Nike Air Jordan 1', N'giay-basketball-nike-air-jordan',
				N'Giày basketball Nike Air Jordan 1 - biểu tượng của bóng rổ. Thiết kế cổ điển với công nghệ Air-Sole đệm êm.',
				N'Giày basketball Nike Air Jordan 1 cổ điển', 3500000.00, 4000000.00, N'/images/products/giay-basketball-nike-air-jordan-1.jpg',
				25, N'Leather + Air-Sole', N'Mỹ', 0.72, N'38-44', 3200, 23, 4.8, 15,
				@giayDepId, @nikeId, @bongRoId, 1, 1, 1, 0);

	-- 14. Giày training Reebok Nano
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-training-reebok-nano')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP014', N'Giày Training Reebok Nano X2', N'giay-training-reebok-nano',
				N'Giày training Reebok Nano X2 với thiết kế ổn định cho CrossFit và tập luyện cường độ cao. Đế FlexWeave linh hoạt.',
				N'Giày training Reebok Nano X2 cho CrossFit', 1800000.00, 2200000.00, N'/images/products/giay-training-reebok-nano-1.jpg',
				50, N'FlexWeave + Floatride', N'Mỹ', 0.58, N'38-44', 1450, 89, 4.4, 36,
				@giayDepId, @reebokId, @gymId, 1, 0, 1, 1);

	-- 15. Giày cầu lông Mizuno Wave
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-cau-long-mizuno-wave')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP015', N'Giày Cầu Lông Mizuno Wave Lightning Z6', N'giay-cau-long-mizuno-wave',
				N'Giày cầu lông Mizuno Wave Lightning Z6 với công nghệ Wave đệm êm và đế cao su bền bỉ. Phù hợp cho cầu lông chuyên nghiệp.',
				N'Giày cầu lông Mizuno Wave Lightning Z6', 1600000.00, 1900000.00, N'/images/products/giay-cau-long-mizuno-wave-1.jpg',
				30, N'Synthetic + Wave', N'Nhật Bản', 0.52, N'38-44', 1200, 34, 4.5, 19,
				@giayDepId, @mizunoId, @cauLongId, 1, 1, 0, 1);

	-- 16. Giày golf Adidas CodeChaos
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-golf-adidas-codechaos')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP016', N'Giày Golf Adidas CodeChaos 22', N'giay-golf-adidas-codechaos',
				N'Giày golf Adidas CodeChaos 22 với thiết kế hiện đại và đế spikeless. Phù hợp cho sân golf và tập luyện.',
				N'Giày golf Adidas CodeChaos 22 spikeless', 2200000.00, 2600000.00, N'/images/products/giay-golf-adidas-codechaos-1.jpg',
				20, N'Primeknit + Boost', N'Đức', 0.65, N'38-44', 890, 12, 4.3, 8,
				@giayDepId, @adidasId, @golfId, 1, 1, 0, 1);

	-- 17. Giày cycling Shimano
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-cycling-shimano')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP017', N'Giày Cycling Shimano RC7', N'giay-cycling-shimano',
				N'Giày cycling Shimano RC7 với đế carbon cứng và hệ thống khóa SPD. Tối ưu cho đạp xe đường dài và racing.',
				N'Giày cycling Shimano RC7 với đế carbon', 1800000.00, 2200000.00, N'/images/products/giay-cycling-shimano-1.jpg',
				15, N'Carbon + Synthetic', N'Nhật Bản', 0.48, N'38-44', 650, 8, 4.6, 5,
				@giayDepId, @asicsId, @dapXeId, 1, 0, 0, 1);

	-- 18. Giày boxing Nike HyperKO
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'giay-boxing-nike-hyperko')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP018', N'Giày Boxing Nike HyperKO 2', N'giay-boxing-nike-hyperko',
				N'Giày boxing Nike HyperKO 2 với thiết kế nhẹ và đế cao su bám dính. Phù hợp cho boxing và kickboxing.',
				N'Giày boxing Nike HyperKO 2 nhẹ và bám dính', 1200000.00, 1500000.00, N'/images/products/giay-boxing-nike-hyperko-1.jpg',
				25, N'Synthetic + Rubber', N'Mỹ', 0.35, N'38-44', 780, 15, 4.4, 12,
				@giayDepId, @nikeId, @boxingId, 1, 0, 0, 1);

	-- 19. Quần jogger Adidas Tiro
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'quan-jogger-adidas-tiro')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP019', N'Quần Jogger Adidas Tiro 21', N'quan-jogger-adidas-tiro',
				N'Quần jogger Adidas Tiro 21 với thiết kế thoải mái và chất liệu AEROREADY. Phù hợp cho tập luyện và sinh hoạt hàng ngày.',
				N'Quần jogger Adidas Tiro 21 thoải mái', 450000.00, 550000.00, N'/images/products/quan-jogger-adidas-tiro-1.jpg',
				60, N'Polyester + Elastane', N'Đức', 0.28, N'S, M, L, XL', 1350, 78, 4.3, 31,
				@quanAoId, @adidasId, @chayBoId, 1, 1, 1, 0);

	-- 20. Áo tập gym Under Armour
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-tap-gym-under-armour')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP020', N'Áo Tập Gym Under Armour Tech 2.0', N'ao-tap-gym-under-armour',
				N'Áo tập gym Under Armour Tech 2.0 với công nghệ Moisture Transport. Thấm hút mồ hôi tốt cho tập luyện cường độ cao.',
				N'Áo tập gym Under Armour Tech 2.0', 380000.00, 450000.00, N'/images/products/ao-tap-gym-under-armour-1.jpg',
				70, N'Polyester + Moisture Transport', N'Mỹ', 0.22, N'S, M, L, XL, XXL', 1680, 95, 4.5, 47,
				@quanAoId, @underArmourId, @gymId, 1, 1, 1, 1);

	-- 21. Quần short bóng rổ Nike Dri-FIT
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'quan-short-bong-ro-nike-dri-fit')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP021', N'Quần Short Bóng Rổ Nike Dri-FIT', N'quan-short-bong-ro-nike-dri-fit',
				N'Quần short bóng rổ Nike Dri-FIT với thiết kế thoải mái và chất liệu thấm hút mồ hôi. Phù hợp cho chơi bóng rổ và tập luyện.',
				N'Quần short bóng rổ Nike Dri-FIT', 320000.00, 380000.00, N'/images/products/quan-short-bong-ro-nike-dri-fit-1.jpg',
				55, N'100% Polyester Dri-FIT', N'Việt Nam', 0.18, N'S, M, L, XL', 1120, 67, 4.2, 28,
				@quanShortId, @nikeId, @bongRoId, 1, 0, 1, 0);

	-- 22. Áo khoác chống nước Puma
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-khoac-chong-nuoc-puma')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP022', N'Áo Khoác Chống Nước Puma Storm', N'ao-khoac-chong-nuoc-puma',
				N'Áo khoác chống nước Puma Storm với công nghệ Dry Cell. Bảo vệ khỏi mưa và gió, phù hợp cho tập luyện ngoài trời.',
				N'Áo khoác chống nước Puma Storm', 650000.00, 750000.00, N'/images/products/ao-khoac-chong-nuoc-puma-1.jpg',
				40, N'Polyester + Dry Cell', N'Đức', 0.45, N'S, M, L, XL', 980, 34, 4.4, 18,
				@aoKhoacId, @pumaId, @chayBoId, 1, 1, 0, 1);

	-- 23. Áo polo tennis Lacoste
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-polo-tennis-lacoste')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP023', N'Áo Polo Tennis Lacoste Classic', N'ao-polo-tennis-lacoste',
				N'Áo polo tennis Lacoste Classic với thiết kế cổ điển và chất liệu cotton pique. Phù hợp cho chơi tennis và thời trang.',
				N'Áo polo tennis Lacoste Classic', 520000.00, 620000.00, N'/images/products/ao-polo-tennis-lacoste-1.jpg',
				45, N'100% Cotton Pique', N'Pháp', 0.25, N'S, M, L, XL', 1450, 42, 4.6, 24,
				@quanAoId, @nikeId, @tennisId, 1, 1, 0, 0);

	-- 24. Bộ đồ yoga Lululemon
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'bo-do-yoga-lululemon')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP024', N'Bộ Đồ Yoga Lululemon Align', N'bo-do-yoga-lululemon',
				N'Bộ đồ yoga Lululemon Align với thiết kế ôm dáng và chất liệu Nulu mềm mại. Phù hợp cho yoga và thiền.',
				N'Bộ đồ yoga Lululemon Align mềm mại', 1200000.00, 1400000.00, N'/images/products/bo-do-yoga-lululemon-1.jpg',
				30, N'Nulu + Lycra', N'Canada', 0.35, N'XS, S, M, L', 2100, 28, 4.8, 16,
				@doYogaId, @lululemonId, @yogaId, 1, 1, 1, 1);

	-- 25. Quần dài thể thao Adidas
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'quan-dai-the-thao-adidas')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP025', N'Quần Dài Thể Thao Adidas Tiro 21', N'quan-dai-the-thao-adidas',
				N'Quần dài thể thao Adidas Tiro 21 với thiết kế thoải mái và chất liệu AEROREADY. Phù hợp cho tập luyện và sinh hoạt.',
				N'Quần dài thể thao Adidas Tiro 21', 480000.00, 580000.00, N'/images/products/quan-dai-the-thao-adidas-1.jpg',
				50, N'Polyester + Elastane', N'Đức', 0.32, N'S, M, L, XL', 1250, 56, 4.3, 22,
				@quanAoId, @adidasId, @chayBoId, 1, 0, 1, 0);

	-- 26. Áo nén Under Armour
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'ao-nen-under-armour')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP026', N'Áo Nén Under Armour HeatGear', N'ao-nen-under-armour',
				N'Áo nén Under Armour HeatGear với công nghệ Compression Zone. Hỗ trợ cơ bắp và thấm hút mồ hôi tốt.',
				N'Áo nén Under Armour HeatGear compression', 350000.00, 420000.00, N'/images/products/ao-nen-under-armour-1.jpg',
				65, N'Polyester + Elastane', N'Mỹ', 0.15, N'S, M, L, XL', 980, 38, 4.4, 19,
				@quanAoId, @underArmourId, @gymId, 1, 0, 0, 1);

	-- 27. Găng tay tập gym Nike
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'gang-tay-tap-gym-nike')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP027', N'Găng Tay Tập Gym Nike SuperRep', N'gang-tay-tap-gym-nike',
				N'Găng tay tập gym Nike SuperRep với thiết kế bảo vệ lòng bàn tay và thấm hút mồ hôi. Phù hợp cho tập tạ và CrossFit.',
				N'Găng tay tập gym Nike SuperRep', 180000.00, 220000.00, N'/images/products/gang-tay-tap-gym-nike-1.jpg',
				80, N'Leather + Mesh', N'Việt Nam', 0.08, N'One Size', 750, 45, 4.2, 23,
				@phuKienId, @nikeId, @gymId, 1, 0, 1, 0);

	-- 28. Tất thể thao Adidas (3-pack)
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'tat-the-thao-adidas-3pack')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP028', N'Tất Thể Thao Adidas 3-Pack', N'tat-the-thao-adidas-3pack',
				N'Tất thể thao Adidas 3-pack với thiết kế thoải mái và thấm hút mồ hôi. Phù hợp cho chạy bộ và tập luyện.',
				N'Tất thể thao Adidas 3-pack', 120000.00, 150000.00, N'/images/products/tat-the-thao-adidas-3pack-1.jpg',
				100, N'Cotton + Polyester', N'Đức', 0.12, N'38-44', 890, 67, 4.1, 35,
				@phuKienId, @adidasId, @chayBoId, 1, 0, 1, 0);

	-- 29. Mũ lưỡi trai Nike Dri-FIT
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'mu-luoi-trai-nike-dri-fit')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP029', N'Mũ Lưỡi Trai Nike Dri-FIT', N'mu-luoi-trai-nike-dri-fit',
				N'Mũ lưỡi trai Nike Dri-FIT với thiết kế thoải mái và chất liệu thấm hút mồ hôi. Phù hợp cho tập luyện ngoài trời.',
				N'Mũ lưỡi trai Nike Dri-FIT', 150000.00, 180000.00, N'/images/products/mu-luoi-trai-nike-dri-fit-1.jpg',
				90, N'100% Polyester Dri-FIT', N'Việt Nam', 0.06, N'One Size', 650, 52, 4.0, 26,
				@phuKienId, @nikeId, @chayBoId, 1, 0, 0, 1);

	-- 30. Thảm yoga Nike
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'tham-yoga-nike')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP030', N'Thảm Yoga Nike Studio', N'tham-yoga-nike',
				N'Thảm yoga Nike Studio với thiết kế chống trượt và dễ dàng cuộn gọn. Phù hợp cho yoga và pilates.',
				N'Thảm yoga Nike Studio chống trượt', 280000.00, 350000.00, N'/images/products/tham-yoga-nike-1.jpg',
				40, N'TPE + Natural Rubber', N'Việt Nam', 0.85, N'183x61cm', 420, 28, 4.3, 14,
				@phuKienId, @nikeId, @yogaId, 1, 1, 0, 1);

	-- 31. Bình nước thể thao Puma
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'binh-nuoc-the-thao-puma')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP031', N'Bình Nước Thể Thao Puma 750ml', N'binh-nuoc-the-thao-puma',
				N'Bình nước thể thao Puma 750ml với thiết kế chống rò rỉ và dễ dàng sử dụng. Phù hợp cho tập luyện và thể thao.',
				N'Bình nước thể thao Puma 750ml', 120000.00, 150000.00, N'/images/products/binh-nuoc-the-thao-puma-1.jpg',
				60, N'BPA-Free Plastic', N'Đức', 0.15, N'750ml', 380, 41, 4.0, 20,
				@phuKienId, @pumaId, @gymId, 1, 0, 0, 0);

	-- 32. Đai lưng tập gym
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'dai-lung-tap-gym')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP032', N'Đai Lưng Tập Gym Nike Pro', N'dai-lung-tap-gym',
				N'Đai lưng tập gym Nike Pro với thiết kế hỗ trợ lưng và thắt lưng có thể điều chỉnh. Phù hợp cho tập tạ nặng.',
				N'Đai lưng tập gym Nike Pro', 250000.00, 300000.00, N'/images/products/dai-lung-tap-gym-1.jpg',
				35, N'Leather + Nylon', N'Việt Nam', 0.25, N'One Size', 320, 18, 4.5, 9,
				@phuKienId, @nikeId, @gymId, 1, 0, 0, 0);

	-- 33. Vợt tennis Wilson Pro Staff
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'vot-tennis-wilson-pro-staff')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP033', N'Vợt Tennis Wilson Pro Staff 97', N'vot-tennis-wilson-pro-staff',
				N'Vợt tennis Wilson Pro Staff 97 với thiết kế cân bằng và công nghệ Countervail. Phù hợp cho người chơi chuyên nghiệp.',
				N'Vợt tennis Wilson Pro Staff 97', 3500000.00, 4200000.00, N'/images/products/vot-tennis-wilson-pro-staff-1.jpg',
				15, N'Graphite + Countervail', N'Mỹ', 0.32, N'97 sq in', 680, 8, 4.7, 5,
				@phuKienId, @wilsonId, @tennisId, 1, 1, 0, 1);

	-- 34. Bóng bóng đá Adidas FIFA Quality
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'bong-bong-da-adidas-fifa')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP034', N'Bóng Bóng Đá Adidas FIFA Quality', N'bong-bong-da-adidas-fifa',
				N'Bóng bóng đá Adidas FIFA Quality với thiết kế chính thức và chất liệu cao cấp. Phù hợp cho thi đấu chuyên nghiệp.',
				N'Bóng bóng đá Adidas FIFA Quality', 450000.00, 550000.00, N'/images/products/bong-bong-da-adidas-fifa-1.jpg',
				25, N'Polyurethane + Butyl', N'Đức', 0.42, N'Size 5', 520, 15, 4.6, 8,
				@phuKienId, @adidasId, @bongDaId, 1, 1, 1, 0);

	-- 35. Dây nhảy tập luyện
	IF NOT EXISTS (SELECT 1 FROM dbo.san_pham WHERE slug = 'day-nhay-tap-luyen')
		INSERT INTO dbo.san_pham (ma_san_pham, ten, slug, mo_ta, mo_ta_ngan, gia, gia_goc, anh_chinh, 
								so_luong_ton, chat_lieu, xuat_xu, trong_luong, kich_thuoc, luot_xem, da_ban, 
								diem_trung_binh, so_danh_gia, id_danh_muc, id_thuong_hieu, id_mon_the_thao, 
								hoat_dong, noi_bat, ban_chay, moi_ve)
		VALUES (N'SP035', N'Dây Nhảy Tập Luyện Nike Speed Rope', N'day-nhay-tap-luyen',
				N'Dây nhảy tập luyện Nike Speed Rope với thiết kế nhẹ và tay cầm chống trượt. Phù hợp cho cardio và CrossFit.',
				N'Dây nhảy tập luyện Nike Speed Rope', 180000.00, 220000.00, N'/images/products/day-nhay-tap-luyen-1.jpg',
				50, N'PVC + Aluminum', N'Việt Nam', 0.12, N'3m', 290, 25, 4.2, 12,
				@phuKienId, @nikeId, @gymId, 1, 0, 0, 1);

	----------------------------------------------------------
	-- 5) INSERT PRODUCT VARIANTS (Biến thể sản phẩm)
	----------------------------------------------------------

	-- Lấy ID của các sản phẩm để thêm biến thể
	DECLARE @sp1Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-dau-bong-da-nike-2024');
	DECLARE @imgSp2Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-chay-bo-adidas-ultraboost');
	DECLARE @imgSp3Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-short-the-thao-puma');
	DECLARE @imgSp4Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-thun-tennis-vans');
	DECLARE @imgSp5Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-skateboard-vans-old-skool');
	DECLARE @imgSp6Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-hoodie-nike-sportswear');
	DECLARE @imgSp7Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-legging-the-thao-adidas');
	DECLARE @imgSp8Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'bang-do-the-thao-nike');
	DECLARE @imgSp9Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'tui-the-thao-puma-backpack');
	DECLARE @imgSp10Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-tennis-adidas-gamecourt');

	-- Thêm biến thể cho sản phẩm 1 (Áo đấu bóng đá Nike) - Size
	IF @sp1Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp1Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@sp1Id, N'SP001-L', N'L', 15, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@sp1Id, N'SP001-XL', N'XL', 20, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@sp1Id, N'SP001-XXL', N'XXL', 15, 450000.00);
	END

	-- Thêm biến thể cho sản phẩm 2 (Giày chạy bộ Adidas) - Size
	IF @imgSp2Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp2Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-38', N'38', 5, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-39', N'39', 8, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-40', N'40', 10, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-41', N'41', 7, 2200000.00);
	END

	-- Thêm biến thể cho sản phẩm 3 (Quần short thể thao Puma) - Size và Màu
	IF @imgSp3Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp3Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp3Id, N'SP003-M-BLACK', N'M', N'Đen', 20, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp3Id, N'SP003-M-WHITE', N'M', N'Trắng', 15, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp3Id, N'SP003-L-BLACK', N'L', N'Đen', 25, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp3Id, N'SP003-L-WHITE', N'L', N'Trắng', 15, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp3Id, N'SP003-XL-BLACK', N'XL', N'Đen', 10, 380000.00);
	END

	-- Thêm biến thể cho sản phẩm 4 (Áo thun tennis Vans) - Size và Màu
	IF @imgSp4Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp4Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp4Id, N'SP004-S-BLACK', N'S', N'Đen', 10, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp4Id, N'SP004-S-WHITE', N'S', N'Trắng', 8, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp4Id, N'SP004-M-BLACK', N'M', N'Đen', 15, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp4Id, N'SP004-M-WHITE', N'M', N'Trắng', 12, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp4Id, N'SP004-L-BLACK', N'L', N'Đen', 10, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp4Id, N'SP004-L-WHITE', N'L', N'Trắng', 5, 280000.00);
	END

	-- Thêm biến thể cho sản phẩm 5 (Giày skateboard Vans) - Size và Màu
	IF @imgSp5Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp5Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp5Id, N'SP005-36-BLACK', N'36', N'Đen', 8, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp5Id, N'SP005-36-WHITE', N'36', N'Trắng', 5, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp5Id, N'SP005-37-BLACK', N'37', N'Đen', 10, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp5Id, N'SP005-37-WHITE', N'37', N'Trắng', 7, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp5Id, N'SP005-38-BLACK', N'38', N'Đen', 8, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp5Id, N'SP005-38-WHITE', N'38', N'Trắng', 2, 1200000.00);
	END

	-- Thêm biến thể cho sản phẩm 6 (Áo hoodie Nike) - Size và Màu
	IF @imgSp6Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp6Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-S-BLACK', N'S', N'Đen', 10, 680000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-S-GREY', N'S', N'Xám', 8, 680000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-M-BLACK', N'M', N'Đen', 15, 680000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-M-GREY', N'M', N'Xám', 12, 680000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-L-BLACK', N'L', N'Đen', 8, 680000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-L-GREY', N'L', N'Xám', 5, 680000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp6Id, N'SP006-XL-BLACK', N'XL', N'Đen', 3, 680000.00);
	END

	-- Thêm biến thể cho sản phẩm 7 (Quần legging Adidas) - Size
	IF @imgSp7Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp7Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-XS', N'XS', 10, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-S', N'S', 15, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-M', N'M', 20, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-L', N'L', 10, 520000.00);
	END

	-- Thêm biến thể cho sản phẩm 8 (Băng đô Nike) - Màu
	IF @imgSp8Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp8Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp8Id, N'SP008-BLACK', N'Đen', 30, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp8Id, N'SP008-WHITE', N'Trắng', 25, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp8Id, N'SP008-BLUE', N'Xanh', 15, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp8Id, N'SP008-RED', N'Đỏ', 10, 180000.00);
	END

	-- Thêm biến thể cho sản phẩm 9 (Túi Puma) - Màu
	IF @imgSp9Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp9Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp9Id, N'SP009-BLACK', N'Đen', 15, 420000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp9Id, N'SP009-GREY', N'Xám', 12, 420000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, mau_sac, so_luong, gia_ban) 
		VALUES (@imgSp9Id, N'SP009-BLUE', N'Xanh', 8, 420000.00);
	END

	-- Thêm biến thể cho sản phẩm 10 (Giày tennis Adidas) - Size
	IF @imgSp10Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @imgSp10Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-38', N'38', 5, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-39', N'39', 8, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-40', N'40', 7, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, so_luong, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-41', N'41', 5, 1600000.00);
	END

	----------------------------------------------------------
	-- 5.1) ENHANCE EXISTING PRODUCT VARIANTS (Bổ sung biến thể cho sản phẩm hiện có)
	----------------------------------------------------------

	-- Bổ sung biến thể cho SP001 (Áo đấu Nike) - Thêm màu sắc
	IF @sp1Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE ma_sku = 'SP001-L-RED')
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-L-RED', N'L', N'Đỏ', 20, 20, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-L-BLUE', N'L', N'Xanh', 18, 18, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-L-WHITE', N'L', N'Trắng', 15, 15, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XL-RED', N'XL', N'Đỏ', 25, 25, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XL-BLUE', N'XL', N'Xanh', 22, 22, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XL-WHITE', N'XL', N'Trắng', 20, 20, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XXL-RED', N'XXL', N'Đỏ', 15, 15, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XXL-BLUE', N'XXL', N'Xanh', 12, 12, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp1Id, N'SP001-XXL-WHITE', N'XXL', N'Trắng', 10, 10, 450000.00);
	END

	-- Bổ sung biến thể cho SP002 (Giày Adidas) - Thêm size và màu
	IF @imgSp2Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE ma_sku = 'SP002-42-BLACK')
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-42-BLACK', N'42', N'Đen', 8, 8, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-42-BLUE', N'42', N'Xanh', 6, 6, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-43-BLACK', N'43', N'Đen', 10, 10, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-43-BLUE', N'43', N'Xanh', 8, 8, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-44-BLACK', N'44', N'Đen', 7, 7, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp2Id, N'SP002-44-BLUE', N'44', N'Xanh', 5, 5, 2200000.00);
	END

	-- Bổ sung biến thể cho SP007 (Quần legging Adidas) - Thêm màu sắc
	IF @imgSp7Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE ma_sku = 'SP007-XS-BLACK')
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-XS-BLACK', N'XS', N'Đen', 15, 15, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-XS-BLUE', N'XS', N'Xanh', 12, 12, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-XS-GREY', N'XS', N'Xám', 10, 10, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-S-BLACK', N'S', N'Đen', 20, 20, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-S-BLUE', N'S', N'Xanh', 18, 18, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-S-GREY', N'S', N'Xám', 15, 15, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-M-BLACK', N'M', N'Đen', 25, 25, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-M-BLUE', N'M', N'Xanh', 22, 22, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-M-GREY', N'M', N'Xám', 20, 20, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-L-BLACK', N'L', N'Đen', 18, 18, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-L-BLUE', N'L', N'Xanh', 15, 15, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp7Id, N'SP007-L-GREY', N'L', N'Xám', 12, 12, 520000.00);
	END

	-- Bổ sung biến thể cho SP010 (Giày tennis Adidas) - Thêm size và màu
	IF @imgSp10Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE ma_sku = 'SP010-42-BLACK')
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-42-BLACK', N'42', N'Đen', 6, 6, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-42-WHITE', N'42', N'Trắng', 4, 4, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-43-BLACK', N'43', N'Đen', 8, 8, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-43-WHITE', N'43', N'Trắng', 6, 6, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-44-BLACK', N'44', N'Đen', 5, 5, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@imgSp10Id, N'SP010-44-WHITE', N'44', N'Trắng', 3, 3, 1600000.00);
	END

	----------------------------------------------------------
	-- 5.2) INSERT VARIANTS FOR NEW PRODUCTS (Biến thể cho sản phẩm mới)
	----------------------------------------------------------

	-- Lấy ID của các sản phẩm mới
	DECLARE @sp11Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-bong-da-nike-mercurial');
	DECLARE @sp12Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-chay-bo-new-balance-1080');
	DECLARE @sp13Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-basketball-nike-air-jordan');
	DECLARE @sp14Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-training-reebok-nano');
	DECLARE @sp15Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-cau-long-mizuno-wave');
	DECLARE @sp16Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-golf-adidas-codechaos');
	DECLARE @sp17Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-cycling-shimano');
	DECLARE @sp18Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-boxing-nike-hyperko');
	DECLARE @sp19Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-jogger-adidas-tiro');
	DECLARE @sp20Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-tap-gym-under-armour');
	DECLARE @sp21Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-short-bong-ro-nike-dri-fit');
	DECLARE @sp22Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-khoac-chong-nuoc-puma');
	DECLARE @sp23Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-polo-tennis-lacoste');
	DECLARE @sp24Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'bo-do-yoga-lululemon');
	DECLARE @sp25Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-dai-the-thao-adidas');
	DECLARE @sp26Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-nen-under-armour');
	DECLARE @sp27Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'gang-tay-tap-gym-nike');
	DECLARE @sp28Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'tat-the-thao-adidas-3pack');
	DECLARE @sp29Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'mu-luoi-trai-nike-dri-fit');
	DECLARE @sp30Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'tham-yoga-nike');
	DECLARE @sp31Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'binh-nuoc-the-thao-puma');
	DECLARE @sp32Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'dai-lung-tap-gym');
	DECLARE @sp33Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'vot-tennis-wilson-pro-staff');
	DECLARE @sp34Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'bong-bong-da-adidas-fifa');
	DECLARE @sp35Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'day-nhay-tap-luyen');

	-- Biến thể cho SP011 (Giày bóng đá Nike Mercurial) - Size và màu
	IF @sp11Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp11Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-38-BLACK', N'38', N'Đen', 8, 8, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-38-WHITE', N'38', N'Trắng', 6, 6, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-39-BLACK', N'39', N'Đen', 10, 10, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-39-WHITE', N'39', N'Trắng', 8, 8, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-40-BLACK', N'40', N'Đen', 12, 12, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-40-WHITE', N'40', N'Trắng', 10, 10, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-41-BLACK', N'41', N'Đen', 10, 10, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-41-WHITE', N'41', N'Trắng', 8, 8, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-42-BLACK', N'42', N'Đen', 8, 8, 2800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp11Id, N'SP011-42-WHITE', N'42', N'Trắng', 6, 6, 2800000.00);
	END

	-- Biến thể cho SP012 (Giày chạy bộ New Balance) - Size và màu
	IF @sp12Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp12Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-38-BLACK', N'38', N'Đen', 6, 6, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-38-BLUE', N'38', N'Xanh', 4, 4, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-39-BLACK', N'39', N'Đen', 8, 8, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-39-BLUE', N'39', N'Xanh', 6, 6, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-40-BLACK', N'40', N'Đen', 10, 10, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-40-BLUE', N'40', N'Xanh', 8, 8, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-41-BLACK', N'41', N'Đen', 8, 8, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-41-BLUE', N'41', N'Xanh', 6, 6, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-42-BLACK', N'42', N'Đen', 6, 6, 2400000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp12Id, N'SP012-42-BLUE', N'42', N'Xanh', 4, 4, 2400000.00);
	END

	-- Biến thể cho SP013 (Giày basketball Nike Air Jordan) - Size và màu
	IF @sp13Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp13Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-38-BLACK', N'38', N'Đen', 4, 4, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-38-WHITE', N'38', N'Trắng', 3, 3, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-39-BLACK', N'39', N'Đen', 5, 5, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-39-WHITE', N'39', N'Trắng', 4, 4, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-40-BLACK', N'40', N'Đen', 6, 6, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-40-WHITE', N'40', N'Trắng', 5, 5, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-41-BLACK', N'41', N'Đen', 5, 5, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-41-WHITE', N'41', N'Trắng', 4, 4, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-42-BLACK', N'42', N'Đen', 4, 4, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp13Id, N'SP013-42-WHITE', N'42', N'Trắng', 3, 3, 3500000.00);
	END

	-- Biến thể cho SP014 (Giày training Reebok Nano) - Size và màu
	IF @sp14Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp14Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-38-BLACK', N'38', N'Đen', 8, 8, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-38-GREY', N'38', N'Xám', 6, 6, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-39-BLACK', N'39', N'Đen', 10, 10, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-39-GREY', N'39', N'Xám', 8, 8, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-40-BLACK', N'40', N'Đen', 12, 12, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-40-GREY', N'40', N'Xám', 10, 10, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-41-BLACK', N'41', N'Đen', 10, 10, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-41-GREY', N'41', N'Xám', 8, 8, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-42-BLACK', N'42', N'Đen', 8, 8, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp14Id, N'SP014-42-GREY', N'42', N'Xám', 6, 6, 1800000.00);
	END

	-- Biến thể cho SP015 (Giày cầu lông Mizuno) - Size và màu
	IF @sp15Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp15Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-38-BLACK', N'38', N'Đen', 6, 6, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-38-WHITE', N'38', N'Trắng', 4, 4, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-39-BLACK', N'39', N'Đen', 8, 8, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-39-WHITE', N'39', N'Trắng', 6, 6, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-40-BLACK', N'40', N'Đen', 10, 10, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-40-WHITE', N'40', N'Trắng', 8, 8, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-41-BLACK', N'41', N'Đen', 8, 8, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-41-WHITE', N'41', N'Trắng', 6, 6, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-42-BLACK', N'42', N'Đen', 6, 6, 1600000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp15Id, N'SP015-42-WHITE', N'42', N'Trắng', 4, 4, 1600000.00);
	END

	-- Biến thể cho SP016 (Giày golf Adidas) - Size và màu
	IF @sp16Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp16Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-38-BLACK', N'38', N'Đen', 4, 4, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-38-WHITE', N'38', N'Trắng', 3, 3, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-39-BLACK', N'39', N'Đen', 5, 5, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-39-WHITE', N'39', N'Trắng', 4, 4, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-40-BLACK', N'40', N'Đen', 6, 6, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-40-WHITE', N'40', N'Trắng', 5, 5, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-41-BLACK', N'41', N'Đen', 5, 5, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-41-WHITE', N'41', N'Trắng', 4, 4, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-42-BLACK', N'42', N'Đen', 4, 4, 2200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp16Id, N'SP016-42-WHITE', N'42', N'Trắng', 3, 3, 2200000.00);
	END

	-- Biến thể cho SP017 (Giày cycling Shimano) - Size và màu
	IF @sp17Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp17Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-38-BLACK', N'38', N'Đen', 3, 3, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-38-WHITE', N'38', N'Trắng', 2, 2, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-39-BLACK', N'39', N'Đen', 4, 4, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-39-WHITE', N'39', N'Trắng', 3, 3, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-40-BLACK', N'40', N'Đen', 5, 5, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-40-WHITE', N'40', N'Trắng', 4, 4, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-41-BLACK', N'41', N'Đen', 4, 4, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-41-WHITE', N'41', N'Trắng', 3, 3, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-42-BLACK', N'42', N'Đen', 3, 3, 1800000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp17Id, N'SP017-42-WHITE', N'42', N'Trắng', 2, 2, 1800000.00);
	END

	-- Biến thể cho SP018 (Giày boxing Nike) - Size và màu
	IF @sp18Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp18Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-38-BLACK', N'38', N'Đen', 5, 5, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-38-RED', N'38', N'Đỏ', 3, 3, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-39-BLACK', N'39', N'Đen', 6, 6, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-39-RED', N'39', N'Đỏ', 4, 4, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-40-BLACK', N'40', N'Đen', 7, 7, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-40-RED', N'40', N'Đỏ', 5, 5, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-41-BLACK', N'41', N'Đen', 6, 6, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-41-RED', N'41', N'Đỏ', 4, 4, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-42-BLACK', N'42', N'Đen', 5, 5, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp18Id, N'SP018-42-RED', N'42', N'Đỏ', 3, 3, 1200000.00);
	END

	-- Biến thể cho SP019 (Quần jogger Adidas) - Size và màu
	IF @sp19Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp19Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-S-BLACK', N'S', N'Đen', 15, 15, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-S-GREY', N'S', N'Xám', 12, 12, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-M-BLACK', N'M', N'Đen', 20, 20, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-M-GREY', N'M', N'Xám', 18, 18, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-L-BLACK', N'L', N'Đen', 18, 18, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-L-GREY', N'L', N'Xám', 15, 15, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-XL-BLACK', N'XL', N'Đen', 12, 12, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp19Id, N'SP019-XL-GREY', N'XL', N'Xám', 10, 10, 450000.00);
	END

	-- Biến thể cho SP020 (Áo tập gym Under Armour) - Size và màu
	IF @sp20Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp20Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-S-BLACK', N'S', N'Đen', 18, 18, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-S-BLUE', N'S', N'Xanh', 15, 15, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-M-BLACK', N'M', N'Đen', 22, 22, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-M-BLUE', N'M', N'Xanh', 20, 20, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-L-BLACK', N'L', N'Đen', 20, 20, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-L-BLUE', N'L', N'Xanh', 18, 18, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-XL-BLACK', N'XL', N'Đen', 15, 15, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-XL-BLUE', N'XL', N'Xanh', 12, 12, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-XXL-BLACK', N'XXL', N'Đen', 10, 10, 380000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp20Id, N'SP020-XXL-BLUE', N'XXL', N'Xanh', 8, 8, 380000.00);
	END

	-- Biến thể cho SP021-SP035 (các sản phẩm còn lại) - Size và màu
	-- SP021 (Quần short bóng rổ Nike)
	IF @sp21Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp21Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-S-BLACK', N'S', N'Đen', 12, 12, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-S-WHITE', N'S', N'Trắng', 10, 10, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-M-BLACK', N'M', N'Đen', 15, 15, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-M-WHITE', N'M', N'Trắng', 12, 12, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-L-BLACK', N'L', N'Đen', 18, 18, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-L-WHITE', N'L', N'Trắng', 15, 15, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-XL-BLACK', N'XL', N'Đen', 10, 10, 320000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp21Id, N'SP021-XL-WHITE', N'XL', N'Trắng', 8, 8, 320000.00);
	END

	-- SP022 (Áo khoác chống nước Puma)
	IF @sp22Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp22Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-S-BLACK', N'S', N'Đen', 8, 8, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-S-BLUE', N'S', N'Xanh', 6, 6, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-M-BLACK', N'M', N'Đen', 10, 10, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-M-BLUE', N'M', N'Xanh', 8, 8, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-L-BLACK', N'L', N'Đen', 12, 12, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-L-BLUE', N'L', N'Xanh', 10, 10, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-XL-BLACK', N'XL', N'Đen', 8, 8, 650000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp22Id, N'SP022-XL-BLUE', N'XL', N'Xanh', 6, 6, 650000.00);
	END

	-- SP023 (Áo polo tennis Lacoste)
	IF @sp23Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp23Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-S-WHITE', N'S', N'Trắng', 8, 8, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-S-BLUE', N'S', N'Xanh', 6, 6, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-M-WHITE', N'M', N'Trắng', 10, 10, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-M-BLUE', N'M', N'Xanh', 8, 8, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-L-WHITE', N'L', N'Trắng', 12, 12, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-L-BLUE', N'L', N'Xanh', 10, 10, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-XL-WHITE', N'XL', N'Trắng', 8, 8, 520000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp23Id, N'SP023-XL-BLUE', N'XL', N'Xanh', 6, 6, 520000.00);
	END

	-- SP024 (Bộ đồ yoga Lululemon)
	IF @sp24Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp24Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-XS-BLACK', N'XS', N'Đen', 5, 5, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-XS-PINK', N'XS', N'Hồng', 3, 3, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-S-BLACK', N'S', N'Đen', 8, 8, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-S-PINK', N'S', N'Hồng', 6, 6, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-M-BLACK', N'M', N'Đen', 10, 10, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-M-PINK', N'M', N'Hồng', 8, 8, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-L-BLACK', N'L', N'Đen', 7, 7, 1200000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp24Id, N'SP024-L-PINK', N'L', N'Hồng', 5, 5, 1200000.00);
	END

	-- SP025 (Quần dài thể thao Adidas)
	IF @sp25Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp25Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-S-BLACK', N'S', N'Đen', 12, 12, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-S-GREY', N'S', N'Xám', 10, 10, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-M-BLACK', N'M', N'Đen', 15, 15, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-M-GREY', N'M', N'Xám', 12, 12, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-L-BLACK', N'L', N'Đen', 18, 18, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-L-GREY', N'L', N'Xám', 15, 15, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-XL-BLACK', N'XL', N'Đen', 10, 10, 480000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp25Id, N'SP025-XL-GREY', N'XL', N'Xám', 8, 8, 480000.00);
	END

	-- SP026 (Áo nén Under Armour)
	IF @sp26Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp26Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-S-BLACK', N'S', N'Đen', 15, 15, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-S-BLUE', N'S', N'Xanh', 12, 12, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-M-BLACK', N'M', N'Đen', 18, 18, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-M-BLUE', N'M', N'Xanh', 15, 15, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-L-BLACK', N'L', N'Đen', 20, 20, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-L-BLUE', N'L', N'Xanh', 18, 18, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-XL-BLACK', N'XL', N'Đen', 12, 12, 350000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp26Id, N'SP026-XL-BLUE', N'XL', N'Xanh', 10, 10, 350000.00);
	END

	-- SP027-SP035 (Phụ kiện - One Size hoặc ít biến thể)
	-- SP027 (Găng tay tập gym Nike) - One Size
	IF @sp27Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp27Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp27Id, N'SP027-OS-BLACK', N'One Size', N'Đen', 25, 25, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp27Id, N'SP027-OS-BLUE', N'One Size', N'Xanh', 20, 20, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp27Id, N'SP027-OS-RED', N'One Size', N'Đỏ', 15, 15, 180000.00);
	END

	-- SP028 (Tất thể thao Adidas) - Size
	IF @sp28Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp28Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp28Id, N'SP028-38-39', N'38-39', N'Trắng', 20, 20, 120000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp28Id, N'SP028-40-41', N'40-41', N'Trắng', 25, 25, 120000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp28Id, N'SP028-42-43', N'42-43', N'Trắng', 30, 30, 120000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp28Id, N'SP028-44-45', N'44-45', N'Trắng', 25, 25, 120000.00);
	END

	-- SP029 (Mũ lưỡi trai Nike) - One Size
	IF @sp29Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp29Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp29Id, N'SP029-OS-BLACK', N'One Size', N'Đen', 30, 30, 150000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp29Id, N'SP029-OS-WHITE', N'One Size', N'Trắng', 25, 25, 150000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp29Id, N'SP029-OS-BLUE', N'One Size', N'Xanh', 20, 20, 150000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp29Id, N'SP029-OS-RED', N'One Size', N'Đỏ', 15, 15, 150000.00);
	END

	-- SP030 (Thảm yoga Nike) - One Size
	IF @sp30Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp30Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp30Id, N'SP030-OS-PURPLE', N'One Size', N'Tím', 15, 15, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp30Id, N'SP030-OS-BLUE', N'One Size', N'Xanh', 12, 12, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp30Id, N'SP030-OS-PINK', N'One Size', N'Hồng', 10, 10, 280000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp30Id, N'SP030-OS-GREY', N'One Size', N'Xám', 8, 8, 280000.00);
	END

	-- SP031 (Bình nước thể thao Puma) - One Size
	IF @sp31Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp31Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp31Id, N'SP031-OS-BLACK', N'One Size', N'Đen', 20, 20, 120000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp31Id, N'SP031-OS-WHITE', N'One Size', N'Trắng', 18, 18, 120000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp31Id, N'SP031-OS-BLUE', N'One Size', N'Xanh', 15, 15, 120000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp31Id, N'SP031-OS-RED', N'One Size', N'Đỏ', 12, 12, 120000.00);
	END

	-- SP032 (Đai lưng tập gym Nike) - One Size
	IF @sp32Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp32Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp32Id, N'SP032-OS-BLACK', N'One Size', N'Đen', 12, 12, 250000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp32Id, N'SP032-OS-BROWN', N'One Size', N'Nâu', 8, 8, 250000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp32Id, N'SP032-OS-GREY', N'One Size', N'Xám', 10, 10, 250000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp32Id, N'SP032-OS-RED', N'One Size', N'Đỏ', 5, 5, 250000.00);
	END

	-- SP033 (Vợt tennis Wilson) - One Size
	IF @sp33Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp33Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp33Id, N'SP033-OS-BLACK', N'One Size', N'Đen', 5, 5, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp33Id, N'SP033-OS-WHITE', N'One Size', N'Trắng', 4, 4, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp33Id, N'SP033-OS-BLUE', N'One Size', N'Xanh', 3, 3, 3500000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp33Id, N'SP033-OS-RED', N'One Size', N'Đỏ', 3, 3, 3500000.00);
	END

	-- SP034 (Bóng bóng đá Adidas) - One Size
	IF @sp34Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp34Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp34Id, N'SP034-OS-WHITE', N'One Size', N'Trắng', 8, 8, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp34Id, N'SP034-OS-BLACK', N'One Size', N'Đen', 6, 6, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp34Id, N'SP034-OS-BLUE', N'One Size', N'Xanh', 5, 5, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp34Id, N'SP034-OS-RED', N'One Size', N'Đỏ', 4, 4, 450000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp34Id, N'SP034-OS-YELLOW', N'One Size', N'Vàng', 2, 2, 450000.00);
	END

	-- SP035 (Dây nhảy tập luyện Nike) - One Size
	IF @sp35Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.bien_the_san_pham WHERE id_san_pham = @sp35Id)
	BEGIN
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp35Id, N'SP035-OS-BLACK', N'One Size', N'Đen', 15, 15, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp35Id, N'SP035-OS-BLUE', N'One Size', N'Xanh', 12, 12, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp35Id, N'SP035-OS-RED', N'One Size', N'Đỏ', 10, 10, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp35Id, N'SP035-OS-GREEN', N'One Size', N'Xanh lá', 8, 8, 180000.00);
		INSERT INTO dbo.bien_the_san_pham (id_san_pham, ma_sku, kich_co, mau_sac, so_luong, so_luong_ton, gia_ban) 
		VALUES (@sp35Id, N'SP035-OS-PINK', N'One Size', N'Hồng', 5, 5, 180000.00);
	END

	----------------------------------------------------------
	-- 6) INSERT PRODUCT IMAGES (Ảnh sản phẩm mẫu)
	----------------------------------------------------------

	-- Lấy ID của sản phẩm 1 (chỉ sản phẩm này chưa được khai báo)
	DECLARE @imgSp1Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-dau-bong-da-nike-2024');

	-- Thêm ảnh cho sản phẩm 1 (Áo đấu bóng đá Nike) - 5 ảnh
	IF @imgSp1Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp1Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp1Id, N'/images/products/ao-dau-nike-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp1Id, N'/images/products/ao-dau-nike-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp1Id, N'/images/products/ao-dau-nike-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp1Id, N'/images/products/ao-dau-nike-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp1Id, N'/images/products/ao-dau-nike-5.jpg', 0, 5);
	END

	-- Thêm ảnh cho sản phẩm 2 (Giày chạy bộ Adidas) - 5 ảnh
	IF @imgSp2Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp2Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp2Id, N'/images/products/giay-adidas-ultraboost-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp2Id, N'/images/products/giay-adidas-ultraboost-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp2Id, N'/images/products/giay-adidas-ultraboost-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp2Id, N'/images/products/giay-adidas-ultraboost-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp2Id, N'/images/products/giay-adidas-ultraboost-5.jpg', 0, 5);
	END

	-- Thêm ảnh cho sản phẩm 3 (Quần short thể thao Puma) - 4 ảnh
	IF @imgSp3Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp3Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp3Id, N'/images/products/quan-short-puma-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp3Id, N'/images/products/quan-short-puma-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp3Id, N'/images/products/quan-short-puma-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp3Id, N'/images/products/quan-short-puma-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho sản phẩm 4 (Áo thun tennis Vans) - 4 ảnh
	IF @imgSp4Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp4Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp4Id, N'/images/products/ao-thun-vans-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp4Id, N'/images/products/ao-thun-vans-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp4Id, N'/images/products/ao-thun-vans-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp4Id, N'/images/products/ao-thun-vans-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho sản phẩm 5 (Giày skateboard Vans) - 5 ảnh
	IF @imgSp5Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp5Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp5Id, N'/images/products/giay-vans-oldskool-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp5Id, N'/images/products/giay-vans-oldskool-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp5Id, N'/images/products/giay-vans-oldskool-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp5Id, N'/images/products/giay-vans-oldskool-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp5Id, N'/images/products/giay-vans-oldskool-5.jpg', 0, 5);
	END

	-- Thêm ảnh cho sản phẩm 6 (Áo hoodie Nike) - 4 ảnh
	IF @imgSp6Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp6Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp6Id, N'/images/products/hoodie-nike-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp6Id, N'/images/products/hoodie-nike-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp6Id, N'/images/products/hoodie-nike-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp6Id, N'/images/products/hoodie-nike-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho sản phẩm 7 (Quần legging thể thao Adidas) - 4 ảnh
	IF @imgSp7Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp7Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp7Id, N'/images/products/legging-adidas-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp7Id, N'/images/products/legging-adidas-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp7Id, N'/images/products/legging-adidas-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp7Id, N'/images/products/legging-adidas-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho sản phẩm 8 (Băng đô thể thao Nike) - 3 ảnh
	IF @imgSp8Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp8Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp8Id, N'/images/products/bang-do-nike-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp8Id, N'/images/products/bang-do-nike-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp8Id, N'/images/products/bang-do-nike-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho sản phẩm 9 (Túi thể thao Puma) - 5 ảnh
	IF @imgSp9Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp9Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp9Id, N'/images/products/tui-puma-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp9Id, N'/images/products/tui-puma-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp9Id, N'/images/products/tui-puma-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp9Id, N'/images/products/tui-puma-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp9Id, N'/images/products/tui-puma-5.jpg', 0, 5);
	END

	-- Thêm ảnh cho sản phẩm 10 (Giày tennis Adidas) - 5 ảnh
	IF @imgSp10Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @imgSp10Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp10Id, N'/images/products/giay-tennis-adidas-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp10Id, N'/images/products/giay-tennis-adidas-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp10Id, N'/images/products/giay-tennis-adidas-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp10Id, N'/images/products/giay-tennis-adidas-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@imgSp10Id, N'/images/products/giay-tennis-adidas-5.jpg', 0, 5);
	END

	----------------------------------------------------------
	-- 6.1) INSERT IMAGES FOR NEW PRODUCTS (Ảnh cho sản phẩm mới)
	----------------------------------------------------------

	-- Thêm ảnh cho SP011 (Giày bóng đá Nike Mercurial) - 4 ảnh
	IF @sp11Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp11Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp11Id, N'/images/products/giay-bong-da-nike-mercurial-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp11Id, N'/images/products/giay-bong-da-nike-mercurial-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp11Id, N'/images/products/giay-bong-da-nike-mercurial-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp11Id, N'/images/products/giay-bong-da-nike-mercurial-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP012 (Giày chạy bộ New Balance) - 4 ảnh
	IF @sp12Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp12Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp12Id, N'/images/products/giay-chay-bo-new-balance-1080-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp12Id, N'/images/products/giay-chay-bo-new-balance-1080-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp12Id, N'/images/products/giay-chay-bo-new-balance-1080-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp12Id, N'/images/products/giay-chay-bo-new-balance-1080-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP013 (Giày basketball Nike Air Jordan) - 5 ảnh
	IF @sp13Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp13Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp13Id, N'/images/products/giay-basketball-nike-air-jordan-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp13Id, N'/images/products/giay-basketball-nike-air-jordan-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp13Id, N'/images/products/giay-basketball-nike-air-jordan-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp13Id, N'/images/products/giay-basketball-nike-air-jordan-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp13Id, N'/images/products/giay-basketball-nike-air-jordan-5.jpg', 0, 5);
	END

	-- Thêm ảnh cho SP014 (Giày training Reebok Nano) - 4 ảnh
	IF @sp14Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp14Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp14Id, N'/images/products/giay-training-reebok-nano-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp14Id, N'/images/products/giay-training-reebok-nano-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp14Id, N'/images/products/giay-training-reebok-nano-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp14Id, N'/images/products/giay-training-reebok-nano-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP015 (Giày cầu lông Mizuno) - 4 ảnh
	IF @sp15Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp15Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp15Id, N'/images/products/giay-cau-long-mizuno-wave-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp15Id, N'/images/products/giay-cau-long-mizuno-wave-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp15Id, N'/images/products/giay-cau-long-mizuno-wave-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp15Id, N'/images/products/giay-cau-long-mizuno-wave-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP016 (Giày golf Adidas) - 4 ảnh
	IF @sp16Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp16Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp16Id, N'/images/products/giay-golf-adidas-codechaos-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp16Id, N'/images/products/giay-golf-adidas-codechaos-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp16Id, N'/images/products/giay-golf-adidas-codechaos-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp16Id, N'/images/products/giay-golf-adidas-codechaos-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP017 (Giày cycling Shimano) - 3 ảnh
	IF @sp17Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp17Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp17Id, N'/images/products/giay-cycling-shimano-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp17Id, N'/images/products/giay-cycling-shimano-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp17Id, N'/images/products/giay-cycling-shimano-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP018 (Giày boxing Nike) - 4 ảnh
	IF @sp18Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp18Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp18Id, N'/images/products/giay-boxing-nike-hyperko-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp18Id, N'/images/products/giay-boxing-nike-hyperko-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp18Id, N'/images/products/giay-boxing-nike-hyperko-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp18Id, N'/images/products/giay-boxing-nike-hyperko-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP019 (Quần jogger Adidas) - 4 ảnh
	IF @sp19Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp19Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp19Id, N'/images/products/quan-jogger-adidas-tiro-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp19Id, N'/images/products/quan-jogger-adidas-tiro-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp19Id, N'/images/products/quan-jogger-adidas-tiro-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp19Id, N'/images/products/quan-jogger-adidas-tiro-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP020 (Áo tập gym Under Armour) - 4 ảnh
	IF @sp20Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp20Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp20Id, N'/images/products/ao-tap-gym-under-armour-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp20Id, N'/images/products/ao-tap-gym-under-armour-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp20Id, N'/images/products/ao-tap-gym-under-armour-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp20Id, N'/images/products/ao-tap-gym-under-armour-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP021 (Quần short bóng rổ Nike) - 4 ảnh
	IF @sp21Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp21Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp21Id, N'/images/products/quan-short-bong-ro-nike-dri-fit-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp21Id, N'/images/products/quan-short-bong-ro-nike-dri-fit-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp21Id, N'/images/products/quan-short-bong-ro-nike-dri-fit-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp21Id, N'/images/products/quan-short-bong-ro-nike-dri-fit-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP022 (Áo khoác chống nước Puma) - 4 ảnh
	IF @sp22Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp22Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp22Id, N'/images/products/ao-khoac-chong-nuoc-puma-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp22Id, N'/images/products/ao-khoac-chong-nuoc-puma-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp22Id, N'/images/products/ao-khoac-chong-nuoc-puma-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp22Id, N'/images/products/ao-khoac-chong-nuoc-puma-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP023 (Áo polo tennis Lacoste) - 4 ảnh
	IF @sp23Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp23Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp23Id, N'/images/products/ao-polo-tennis-lacoste-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp23Id, N'/images/products/ao-polo-tennis-lacoste-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp23Id, N'/images/products/ao-polo-tennis-lacoste-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp23Id, N'/images/products/ao-polo-tennis-lacoste-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP024 (Bộ đồ yoga Lululemon) - 5 ảnh
	IF @sp24Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp24Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp24Id, N'/images/products/bo-do-yoga-lululemon-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp24Id, N'/images/products/bo-do-yoga-lululemon-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp24Id, N'/images/products/bo-do-yoga-lululemon-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp24Id, N'/images/products/bo-do-yoga-lululemon-4.jpg', 0, 4);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp24Id, N'/images/products/bo-do-yoga-lululemon-5.jpg', 0, 5);
	END

	-- Thêm ảnh cho SP025 (Quần dài thể thao Adidas) - 4 ảnh
	IF @sp25Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp25Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp25Id, N'/images/products/quan-dai-the-thao-adidas-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp25Id, N'/images/products/quan-dai-the-thao-adidas-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp25Id, N'/images/products/quan-dai-the-thao-adidas-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp25Id, N'/images/products/quan-dai-the-thao-adidas-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP026 (Áo nén Under Armour) - 4 ảnh
	IF @sp26Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp26Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp26Id, N'/images/products/ao-nen-under-armour-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp26Id, N'/images/products/ao-nen-under-armour-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp26Id, N'/images/products/ao-nen-under-armour-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp26Id, N'/images/products/ao-nen-under-armour-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP027 (Găng tay tập gym Nike) - 3 ảnh
	IF @sp27Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp27Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp27Id, N'/images/products/gang-tay-tap-gym-nike-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp27Id, N'/images/products/gang-tay-tap-gym-nike-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp27Id, N'/images/products/gang-tay-tap-gym-nike-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP028 (Tất thể thao Adidas) - 3 ảnh
	IF @sp28Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp28Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp28Id, N'/images/products/tat-the-thao-adidas-3pack-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp28Id, N'/images/products/tat-the-thao-adidas-3pack-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp28Id, N'/images/products/tat-the-thao-adidas-3pack-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP029 (Mũ lưỡi trai Nike) - 3 ảnh
	IF @sp29Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp29Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp29Id, N'/images/products/mu-luoi-trai-nike-dri-fit-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp29Id, N'/images/products/mu-luoi-trai-nike-dri-fit-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp29Id, N'/images/products/mu-luoi-trai-nike-dri-fit-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP030 (Thảm yoga Nike) - 4 ảnh
	IF @sp30Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp30Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp30Id, N'/images/products/tham-yoga-nike-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp30Id, N'/images/products/tham-yoga-nike-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp30Id, N'/images/products/tham-yoga-nike-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp30Id, N'/images/products/tham-yoga-nike-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP031 (Bình nước thể thao Puma) - 3 ảnh
	IF @sp31Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp31Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp31Id, N'/images/products/binh-nuoc-the-thao-puma-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp31Id, N'/images/products/binh-nuoc-the-thao-puma-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp31Id, N'/images/products/binh-nuoc-the-thao-puma-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP032 (Đai lưng tập gym Nike) - 3 ảnh
	IF @sp32Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp32Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp32Id, N'/images/products/dai-lung-tap-gym-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp32Id, N'/images/products/dai-lung-tap-gym-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp32Id, N'/images/products/dai-lung-tap-gym-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP033 (Vợt tennis Wilson) - 4 ảnh
	IF @sp33Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp33Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp33Id, N'/images/products/vot-tennis-wilson-pro-staff-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp33Id, N'/images/products/vot-tennis-wilson-pro-staff-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp33Id, N'/images/products/vot-tennis-wilson-pro-staff-3.jpg', 0, 3);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp33Id, N'/images/products/vot-tennis-wilson-pro-staff-4.jpg', 0, 4);
	END

	-- Thêm ảnh cho SP034 (Bóng bóng đá Adidas) - 3 ảnh
	IF @sp34Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp34Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp34Id, N'/images/products/bong-bong-da-adidas-fifa-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp34Id, N'/images/products/bong-bong-da-adidas-fifa-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp34Id, N'/images/products/bong-bong-da-adidas-fifa-3.jpg', 0, 3);
	END

	-- Thêm ảnh cho SP035 (Dây nhảy tập luyện Nike) - 3 ảnh
	IF @sp35Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp35Id)
	BEGIN
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp35Id, N'/images/products/day-nhay-tap-luyen-1.jpg', 1, 1);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp35Id, N'/images/products/day-nhay-tap-luyen-2.jpg', 0, 2);
		INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp35Id, N'/images/products/day-nhay-tap-luyen-3.jpg', 0, 3);
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
	-- 9) INSERT SAMPLE ORDERS (Dữ liệu đơn hàng mẫu)
	----------------------------------------------------------

	-- Lấy ID của khách hàng và sản phẩm
	DECLARE @customer1Id BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'user@example.com');
	DECLARE @customer2Id BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'customer2@example.com');
	DECLARE @customer3Id BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'customer3@example.com');
	DECLARE @customer4Id BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'customer4@example.com');
	DECLARE @customer5Id BIGINT = (SELECT id FROM dbo.nguoi_dung WHERE email = 'customer5@example.com');

	DECLARE @orderSp1Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-dau-bong-da-nike-2024');
	DECLARE @orderSp2Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-chay-bo-adidas-ultraboost');
	DECLARE @orderSp3Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'bang-do-the-thao-nike');
	DECLARE @orderSp4Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-skateboard-vans-old-skool');
	DECLARE @orderSp5Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-tennis-adidas-gamecourt');

	-- Thêm đơn hàng với trạng thái khác nhau
	IF NOT EXISTS (SELECT 1 FROM dbo.don_hang WHERE ma_don_hang = 'DH001')
	BEGIN
		INSERT INTO dbo.don_hang (ma_don_hang, nguoi_dung_id, ten_nguoi_nhan, so_dien_thoai, dia_chi_giao_hang, tong_tien, phi_van_chuyen, tong_thanh_toan, trang_thai, phuong_thuc_thanh_toan, ghi_chu, ngay_dat_hang) 
		VALUES (N'DH001', @customer1Id, N'Nguyễn Văn A', N'0123456789', N'123 Đường ABC, Quận 1, TP.HCM', 450000.00, 30000.00, 480000.00, N'CHO_XAC_NHAN', N'COD', N'Giao hàng trong giờ hành chính', DATEADD(day, -5, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.don_hang WHERE ma_don_hang = 'DH002')
	BEGIN
		INSERT INTO dbo.don_hang (ma_don_hang, nguoi_dung_id, ten_nguoi_nhan, so_dien_thoai, dia_chi_giao_hang, tong_tien, phi_van_chuyen, tong_thanh_toan, trang_thai, phuong_thuc_thanh_toan, ghi_chu, ngay_dat_hang) 
		VALUES (N'DH002', @customer2Id, N'Trần Thị B', N'0987654321', N'456 Đường DEF, Quận 2, TP.HCM', 320000.00, 25000.00, 345000.00, N'DA_XAC_NHAN', N'BANK_TRANSFER', N'Thanh toán chuyển khoản', DATEADD(day, -4, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.don_hang WHERE ma_don_hang = 'DH003')
	BEGIN
		INSERT INTO dbo.don_hang (ma_don_hang, nguoi_dung_id, ten_nguoi_nhan, so_dien_thoai, dia_chi_giao_hang, tong_tien, phi_van_chuyen, tong_thanh_toan, trang_thai, phuong_thuc_thanh_toan, ghi_chu, ngay_dat_hang) 
		VALUES (N'DH003', @customer3Id, N'Lê Văn C', N'0123456789', N'789 Đường GHI, Quận 3, TP.HCM', 280000.00, 20000.00, 300000.00, N'DANG_GIAO', N'CREDIT_CARD', N'Thanh toán thẻ tín dụng', DATEADD(day, -3, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.don_hang WHERE ma_don_hang = 'DH004')
	BEGIN
		INSERT INTO dbo.don_hang (ma_don_hang, nguoi_dung_id, ten_nguoi_nhan, so_dien_thoai, dia_chi_giao_hang, tong_tien, phi_van_chuyen, tong_thanh_toan, trang_thai, phuong_thuc_thanh_toan, ghi_chu, ngay_dat_hang) 
		VALUES (N'DH004', @customer4Id, N'Phạm Thị D', N'0987654321', N'321 Đường JKL, Quận 4, TP.HCM', 650000.00, 35000.00, 685000.00, N'DA_GIAO', N'COD', N'Đã giao hàng thành công', DATEADD(day, -2, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.don_hang WHERE ma_don_hang = 'DH005')
	BEGIN
		INSERT INTO dbo.don_hang (ma_don_hang, nguoi_dung_id, ten_nguoi_nhan, so_dien_thoai, dia_chi_giao_hang, tong_tien, phi_van_chuyen, tong_thanh_toan, trang_thai, phuong_thuc_thanh_toan, ghi_chu, ngay_dat_hang) 
		VALUES (N'DH005', @customer5Id, N'Hoàng Văn E', N'0123456789', N'654 Đường MNO, Quận 5, TP.HCM', 420000.00, 30000.00, 450000.00, N'DA_HUY', N'BANK_TRANSFER', N'Khách hàng hủy đơn', DATEADD(day, -1, SYSUTCDATETIME()));
	END

	-- Thêm chi tiết đơn hàng
	IF NOT EXISTS (SELECT 1 FROM dbo.chi_tiet_don_hang WHERE don_hang_id = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH001'))
	BEGIN
		DECLARE @dh1Id BIGINT = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH001');
		INSERT INTO dbo.chi_tiet_don_hang (don_hang_id, san_pham_id, ten_san_pham, so_luong, gia_ban, thanh_tien) 
		VALUES (@dh1Id, @orderSp1Id, N'Áo Đấu Bóng Đá Nike 2024', 1, 450000.00, 450000.00);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.chi_tiet_don_hang WHERE don_hang_id = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH002'))
	BEGIN
		DECLARE @dh2Id BIGINT = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH002');
		INSERT INTO dbo.chi_tiet_don_hang (don_hang_id, san_pham_id, ten_san_pham, so_luong, gia_ban, thanh_tien) 
		VALUES (@dh2Id, @orderSp2Id, N'Áo Thun Vans Classic', 2, 160000.00, 320000.00);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.chi_tiet_don_hang WHERE don_hang_id = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH003'))
	BEGIN
		DECLARE @dh3Id BIGINT = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH003');
		INSERT INTO dbo.chi_tiet_don_hang (don_hang_id, san_pham_id, ten_san_pham, so_luong, gia_ban, thanh_tien) 
		VALUES (@dh3Id, @orderSp3Id, N'Băng Đô Nike Dri-FIT', 1, 280000.00, 280000.00);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.chi_tiet_don_hang WHERE don_hang_id = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH004'))
	BEGIN
		DECLARE @dh4Id BIGINT = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH004');
		INSERT INTO dbo.chi_tiet_don_hang (don_hang_id, san_pham_id, ten_san_pham, so_luong, gia_ban, thanh_tien) 
		VALUES (@dh4Id, @orderSp4Id, N'Giày Adidas Ultraboost 22', 1, 650000.00, 650000.00);
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.chi_tiet_don_hang WHERE don_hang_id = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH005'))
	BEGIN
		DECLARE @dh5Id BIGINT = (SELECT id FROM dbo.don_hang WHERE ma_don_hang = 'DH005');
		INSERT INTO dbo.chi_tiet_don_hang (don_hang_id, san_pham_id, ten_san_pham, so_luong, gia_ban, thanh_tien) 
		VALUES (@dh5Id, @orderSp5Id, N'Giày Tennis Adidas Barricade', 1, 420000.00, 420000.00);
	END

	----------------------------------------------------------
	-- 10) INSERT SAMPLE REVIEWS & WISHLISTS (Đánh giá & yêu thích)
	----------------------------------------------------------

	-- Thêm đánh giá sản phẩm
	IF NOT EXISTS (SELECT 1 FROM dbo.danh_gia WHERE nguoi_dung_id = @customer1Id AND san_pham_id = @orderSp1Id)
	BEGIN
		INSERT INTO dbo.danh_gia (nguoi_dung_id, san_pham_id, diem, noi_dung, trang_thai, ngay_tao) 
		VALUES (@customer1Id, @orderSp1Id, 5, N'Sản phẩm chất lượng tốt, giao hàng nhanh', N'DA_DUYET', DATEADD(day, -4, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_gia WHERE nguoi_dung_id = @customer2Id AND san_pham_id = @orderSp2Id)
	BEGIN
		INSERT INTO dbo.danh_gia (nguoi_dung_id, san_pham_id, diem, noi_dung, trang_thai, ngay_tao) 
		VALUES (@customer2Id, @orderSp2Id, 4, N'Áo đẹp, chất liệu tốt', N'DA_DUYET', DATEADD(day, -3, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_gia WHERE nguoi_dung_id = @customer3Id AND san_pham_id = @orderSp3Id)
	BEGIN
		INSERT INTO dbo.danh_gia (nguoi_dung_id, san_pham_id, diem, noi_dung, trang_thai, ngay_tao) 
		VALUES (@customer3Id, @orderSp3Id, 5, N'Băng đô rất tốt, thấm mồ hôi', N'DA_DUYET', DATEADD(day, -2, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_gia WHERE nguoi_dung_id = @customer4Id AND san_pham_id = @orderSp4Id)
	BEGIN
		INSERT INTO dbo.danh_gia (nguoi_dung_id, san_pham_id, diem, noi_dung, trang_thai, ngay_tao) 
		VALUES (@customer4Id, @orderSp4Id, 5, N'Giày chạy bộ rất thoải mái', N'DA_DUYET', DATEADD(day, -1, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.danh_gia WHERE nguoi_dung_id = @customer5Id AND san_pham_id = @orderSp5Id)
	BEGIN
		INSERT INTO dbo.danh_gia (nguoi_dung_id, san_pham_id, diem, noi_dung, trang_thai, ngay_tao) 
		VALUES (@customer5Id, @orderSp5Id, 4, N'Giày tennis tốt, phù hợp chơi tennis', N'DA_DUYET', SYSUTCDATETIME());
	END

	-- Thêm sản phẩm yêu thích
	IF NOT EXISTS (SELECT 1 FROM dbo.yeu_thich WHERE nguoi_dung_id = @customer1Id AND san_pham_id = @orderSp2Id)
	BEGIN
		INSERT INTO dbo.yeu_thich (nguoi_dung_id, san_pham_id, ngay_them) 
		VALUES (@customer1Id, @orderSp2Id, DATEADD(day, -5, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.yeu_thich WHERE nguoi_dung_id = @customer1Id AND san_pham_id = @orderSp3Id)
	BEGIN
		INSERT INTO dbo.yeu_thich (nguoi_dung_id, san_pham_id, ngay_them) 
		VALUES (@customer1Id, @orderSp3Id, DATEADD(day, -4, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.yeu_thich WHERE nguoi_dung_id = @customer2Id AND san_pham_id = @orderSp1Id)
	BEGIN
		INSERT INTO dbo.yeu_thich (nguoi_dung_id, san_pham_id, ngay_them) 
		VALUES (@customer2Id, @orderSp1Id, DATEADD(day, -3, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.yeu_thich WHERE nguoi_dung_id = @customer2Id AND san_pham_id = @orderSp4Id)
	BEGIN
		INSERT INTO dbo.yeu_thich (nguoi_dung_id, san_pham_id, ngay_them) 
		VALUES (@customer2Id, @orderSp4Id, DATEADD(day, -2, SYSUTCDATETIME()));
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.yeu_thich WHERE nguoi_dung_id = @customer3Id AND san_pham_id = @orderSp5Id)
	BEGIN
		INSERT INTO dbo.yeu_thich (nguoi_dung_id, san_pham_id, ngay_them) 
		VALUES (@customer3Id, @orderSp5Id, DATEADD(day, -1, SYSUTCDATETIME()));
	END

PRINT N'✅ Hoàn tất tạo/cập nhật schema + dữ liệu mẫu cho DATN.';
PRINT N'📊 Tổng cộng: ~38 bảng (32 core + 6 mở rộng), kèm view & stored procedures.';
PRINT N'🔧 Đã xử lý xung đột CASCADE PATH.';
PRINT N'🛍️ Đã thêm 35 sản phẩm + ảnh mẫu + biến thể đầy đủ.';
PRINT N'🏪 Đã thêm nhiều kho hàng, vận chuyển, khuyến mãi.';
PRINT N'👥 Đã thêm nhiều người dùng (admin, staff, khách hàng).';
PRINT N'📦 Đã thêm đơn hàng mẫu với trạng thái khác nhau.';
PRINT N'⭐ Đã thêm đánh giá sản phẩm và danh sách yêu thích.';
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
