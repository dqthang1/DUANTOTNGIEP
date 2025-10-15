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
	[ma_san_pham] [varchar](255) NULL,
	[ten] [nvarchar](255) NOT NULL,
	[slug] [nvarchar](255) NOT NULL,
	[mo_ta] [nvarchar](max) NULL,
	[mo_ta_ngan] [nvarchar](500) NULL,
	[gia] [decimal](15, 2) NULL,
	[gia_goc] [decimal](15, 2) NULL,
	[anh_chinh] [nvarchar](255) NULL,
	[so_luong_ton] [int] NOT NULL DEFAULT (0),
	[chat_lieu] [nvarchar](255) NULL,
	[xuat_xu] [nvarchar](255) NULL,
	[trong_luong] [decimal](10, 2) NULL,
	[kich_thuoc] [nvarchar](100) NULL,
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
 CONSTRAINT [UQ_san_pham_slug] UNIQUE NONCLUSTERED ([slug] ASC)
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
	[ma_sku] [nvarchar](100) NULL,
	[kich_co] [varchar](10) NULL,
	[mau_sac] [varchar](50) NULL,
	[so_luong] [int] NOT NULL DEFAULT (0),
	[gia_ban] [decimal](15, 2) NULL,
	[gia_khuyen_mai] [decimal](15, 2) NULL,
	[anh_bien_the] [nvarchar](255) NULL,
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
 CONSTRAINT [UQ_nguoi_dung_email] UNIQUE NONCLUSTERED ([email] ASC)
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
	[ngay_tao] [datetime2](7) NOT NULL DEFAULT (GETDATE()),
	[ngay_cap_nhat] [datetime2](7) NOT NULL DEFAULT (GETDATE()),
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
	[gia_ban] [decimal](15, 2) NOT NULL,
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
	[tong_tien] [decimal](15, 2) NOT NULL,
	[phi_van_chuyen] [decimal](15, 2) NOT NULL DEFAULT (0),
	[tong_thanh_toan] [decimal](15, 2) NOT NULL,
	[trang_thai] [nvarchar](50) NOT NULL DEFAULT (N'PENDING'),
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
	[gia_ban] [decimal](15, 2) NOT NULL,
	[thanh_tien] [decimal](15, 2) NOT NULL,
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
	[so_tien] [decimal](15, 2) NOT NULL,
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
	[trang_thai] [nvarchar](50) NOT NULL DEFAULT (N'PENDING'),
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
	[gia_tri] [decimal](10, 2) NOT NULL,
	[ngay_bat_dau] [datetime2](0) NOT NULL,
	[ngay_ket_thuc] [datetime2](0) NOT NULL,
	[so_luong_su_dung] [int] NOT NULL DEFAULT (0),
	[so_luong_toi_da] [int] NULL,
	[hoat_dong] [bit] NOT NULL DEFAULT (1),
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
	[gia_cu] [decimal](15, 2) NULL,
	[gia_moi] [decimal](15, 2) NOT NULL,
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
	[gia_tri] [decimal](10, 2) NOT NULL,
	[ngay_bat_dau] [datetime2](0) NOT NULL,
	[ngay_ket_thuc] [datetime2](0) NOT NULL,
	[so_luong_su_dung] [int] NOT NULL DEFAULT (0),
	[so_luong_toi_da] [int] NULL,
	[hoat_dong] [bit] NOT NULL DEFAULT (1),
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
	[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
	[ngay_cap_nhat] [datetime2](0) NULL,
 CONSTRAINT [PK_nhom_san_pham] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [UQ_nhom_san_pham_slug] UNIQUE NONCLUSTERED ([slug] ASC)
);
PRINT N'✅ Tạo dbo.nhom_san_pham';
END

-- 1.26 OTP Token
IF OBJECT_ID(N'dbo.otp_token',N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[otp_token](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[nguoi_dung_id] [bigint] NOT NULL,
	[token] [nvarchar](255) NOT NULL,
	[loai] [nvarchar](50) NOT NULL,
	[hoat_dong] [bit] NOT NULL DEFAULT (1),
	[ngay_het_han] [datetime2](0) NOT NULL,
	[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
 CONSTRAINT [PK_otp_token] PRIMARY KEY CLUSTERED ([id] ASC),
 CONSTRAINT [UQ_otp_token_token] UNIQUE NONCLUSTERED ([token] ASC)
);
PRINT N'✅ Tạo dbo.otp_token';
END

-- 1.27 Sản phẩm khuyến mãi
IF OBJECT_ID(N'dbo.san_pham_khuyen_mai',N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[san_pham_khuyen_mai](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[id_san_pham] [bigint] NOT NULL,
	[id_khuyen_mai] [bigint] NOT NULL,
	[gia_khuyen_mai] [decimal](15, 2) NULL,
	[ngay_bat_dau] [datetime2](0) NOT NULL,
	[ngay_ket_thuc] [datetime2](0) NOT NULL,
	[hoat_dong] [bit] NOT NULL DEFAULT (1),
	[nguoi_tao] [bigint] NULL,
	[ngay_tao] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
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
	[do_lien_quan] [decimal](5, 2) NULL,
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

-- Insert danh muc
IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'ao-thiet-bi')
    INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Áo thiết bị', N'ao-thiet-bi', N'Áo thiết bị thể thao', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'quan-ao')
    INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Quần áo', N'quan-ao', N'Quần áo thể thao', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'giay-dep')
    INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Giày dép', N'giay-dep', N'Giày dép thể thao', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc WHERE slug = 'phu-kien')
    INSERT INTO dbo.danh_muc (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Phụ kiện', N'phu-kien', N'Phụ kiện thể thao', 1, 1);

-- Insert thuong hieu
IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'nike')
    INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Nike', N'nike', N'Thương hiệu thể thao hàng đầu thế giới', N'Mỹ', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'adidas')
    INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Adidas', N'adidas', N'Thương hiệu thể thao nổi tiếng', N'Đức', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'puma')
    INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Puma', N'puma', N'Thương hiệu thể thao năng động', N'Đức', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.thuong_hieu WHERE slug = 'vans')
    INSERT INTO dbo.thuong_hieu (ten, slug, mo_ta, quoc_gia, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Vans', N'vans', N'Thương hiệu giày skateboard', N'Mỹ', 1, 1);

-- Insert danh muc mon the thao
IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-da')
    INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Bóng đá', N'bong-da', N'Thiết bị bóng đá', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-ro')
    INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Bóng rổ', N'bong-ro', N'Thiết bị bóng rổ', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'chay-bo')
    INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Chạy bộ', N'chay-bo', N'Thiết bị chạy bộ', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.danh_muc_mon_the_thao WHERE slug = 'tennis')
    INSERT INTO dbo.danh_muc_mon_the_thao (ten, slug, mo_ta, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Tennis', N'tennis', N'Thiết bị tennis', 1, 1);

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
    INSERT INTO dbo.cau_hinh (ten, gia_tri, mo_ta, loai, hoat_dong) 
    VALUES (N'SITE_NAME', N'Activewear Store', N'Tên website', N'SYSTEM', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.cau_hinh WHERE ten = 'SITE_EMAIL')
    INSERT INTO dbo.cau_hinh (ten, gia_tri, mo_ta, loai, hoat_dong) 
    VALUES (N'SITE_EMAIL', N'contact@activewearstore.com', N'Email liên hệ', N'SYSTEM', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.cau_hinh WHERE ten = 'SITE_PHONE')
    INSERT INTO dbo.cau_hinh (ten, gia_tri, mo_ta, loai, hoat_dong) 
    VALUES (N'SITE_PHONE', N'0123456789', N'Số điện thoại', N'SYSTEM', 1);

-- Insert banner
IF NOT EXISTS (SELECT 1 FROM dbo.banner WHERE ten = 'Banner chính')
    INSERT INTO dbo.banner (ten, hinh_anh, mo_ta, vi_tri, thu_tu, hoat_dong) 
    VALUES (N'Banner chính', N'/images/banner-main.jpg', N'Banner chính trang chủ', N'MAIN', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.banner WHERE ten = 'Banner phụ')
    INSERT INTO dbo.banner (ten, hinh_anh, mo_ta, vi_tri, thu_tu, hoat_dong) 
    VALUES (N'Banner phụ', N'/images/banner-side.jpg', N'Banner phụ', N'SIDE', 1, 1);

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
    INSERT INTO dbo.nhom_san_pham (ten, slug, mo_ta, loai, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Áo thiết bị nam', N'ao-thiet-bi-nam', N'Nhóm áo thiết bị cho nam', N'GENDER', 1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.nhom_san_pham WHERE slug = 'ao-thiet-bi-nu')
    INSERT INTO dbo.nhom_san_pham (ten, slug, mo_ta, loai, hien_thi_trang_chu, hoat_dong) 
    VALUES (N'Áo thiết bị nữ', N'ao-thiet-bi-nu', N'Nhóm áo thiết bị cho nữ', N'GENDER', 1, 1);

-- Insert khuyen mai
IF NOT EXISTS (SELECT 1 FROM dbo.khuyen_mai WHERE ten = 'Giảm giá 10%')
    INSERT INTO dbo.khuyen_mai (ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong) 
    VALUES (N'Giảm giá 10%', N'Giảm giá 10% cho tất cả sản phẩm', N'PERCENTAGE', 10.00, 
            DATEADD(day, -30, GETDATE()), DATEADD(day, 30, GETDATE()), 1);

IF NOT EXISTS (SELECT 1 FROM dbo.khuyen_mai WHERE ten = 'Giảm 50k')
    INSERT INTO dbo.khuyen_mai (ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong) 
    VALUES (N'Giảm 50k', N'Giảm 50,000 VNĐ cho đơn hàng từ 500k', N'FIXED_AMOUNT', 50000.00, 
            DATEADD(day, -15, GETDATE()), DATEADD(day, 15, GETDATE()), 1);

-- Insert ma giam gia
IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'WELCOME10')
    INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong) 
    VALUES (N'WELCOME10', N'Chào mừng 10%', N'Mã giảm giá chào mừng khách hàng mới', N'PERCENTAGE', 10.00, 
            DATEADD(day, -60, GETDATE()), DATEADD(day, 60, GETDATE()), 1);

IF NOT EXISTS (SELECT 1 FROM dbo.ma_giam_gia WHERE ma = 'SAVE50K')
    INSERT INTO dbo.ma_giam_gia (ma, ten, mo_ta, loai, gia_tri, ngay_bat_dau, ngay_ket_thuc, hoat_dong) 
    VALUES (N'SAVE50K', N'Tiết kiệm 50k', N'Mã giảm giá tiết kiệm', N'FIXED_AMOUNT', 50000.00, 
            DATEADD(day, -30, GETDATE()), DATEADD(day, 30, GETDATE()), 1);

----------------------------------------------------------
-- 4) INSERT SAMPLE PRODUCTS (10 sản phẩm mẫu)
----------------------------------------------------------

-- Lấy ID của danh mục và thương hiệu
DECLARE @aoThietBiId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'ao-thiet-bi');
DECLARE @quanAoId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'quan-ao');
DECLARE @giayDepId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'giay-dep');
DECLARE @phuKienId BIGINT = (SELECT id FROM dbo.danh_muc WHERE slug = 'phu-kien');

DECLARE @nikeId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'nike');
DECLARE @adidasId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'adidas');
DECLARE @pumaId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'puma');
DECLARE @vansId BIGINT = (SELECT id FROM dbo.thuong_hieu WHERE slug = 'vans');

DECLARE @bongDaId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'bong-da');
DECLARE @chayBoId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'chay-bo');
DECLARE @tennisId BIGINT = (SELECT id FROM dbo.danh_muc_mon_the_thao WHERE slug = 'tennis');

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
            @giayDepId, @vansId, @bongDaId, 1, 1, 0, 0);

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
            @phuKienId, @pumaId, @bongDaId, 1, 1, 0, 0);

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

----------------------------------------------------------
-- 5) INSERT PRODUCT IMAGES (Ảnh sản phẩm mẫu)
----------------------------------------------------------

-- Lấy ID của các sản phẩm
DECLARE @sp1Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-dau-bong-da-nike-2024');
DECLARE @sp2Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-chay-bo-adidas-ultraboost');
DECLARE @sp3Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-short-the-thao-puma');
DECLARE @sp4Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-thun-tennis-vans');
DECLARE @sp5Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-skateboard-vans-old-skool');
DECLARE @sp6Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'ao-hoodie-nike-sportswear');
DECLARE @sp7Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'quan-legging-the-thao-adidas');
DECLARE @sp8Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'bang-do-the-thao-nike');
DECLARE @sp9Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'tui-the-thao-puma-backpack');
DECLARE @sp10Id BIGINT = (SELECT id FROM dbo.san_pham WHERE slug = 'giay-tennis-adidas-gamecourt');

-- Thêm ảnh cho sản phẩm 1 (Áo đấu bóng đá Nike)
IF @sp1Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp1Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'/images/products/ao-dau-nike-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'/images/products/ao-dau-nike-2.jpg', 0, 2);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp1Id, N'/images/products/ao-dau-nike-3.jpg', 0, 3);
END

-- Thêm ảnh cho sản phẩm 2 (Giày chạy bộ Adidas)
IF @sp2Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp2Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'/images/products/giay-adidas-ultraboost-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'/images/products/giay-adidas-ultraboost-2.jpg', 0, 2);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp2Id, N'/images/products/giay-adidas-ultraboost-3.jpg', 0, 3);
END

-- Thêm ảnh cho sản phẩm 3 (Quần short thể thao Puma)
IF @sp3Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp3Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'/images/products/quan-short-puma-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp3Id, N'/images/products/quan-short-puma-2.jpg', 0, 2);
END

-- Thêm ảnh cho sản phẩm 4 (Áo thun tennis Vans)
IF @sp4Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp4Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'/images/products/ao-thun-vans-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp4Id, N'/images/products/ao-thun-vans-2.jpg', 0, 2);
END

-- Thêm ảnh cho sản phẩm 5 (Giày skateboard Vans)
IF @sp5Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp5Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'/images/products/giay-vans-oldskool-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'/images/products/giay-vans-oldskool-2.jpg', 0, 2);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp5Id, N'/images/products/giay-vans-oldskool-3.jpg', 0, 3);
END

-- Thêm ảnh cho sản phẩm 6 (Áo hoodie Nike)
IF @sp6Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp6Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp6Id, N'/images/products/hoodie-nike-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp6Id, N'/images/products/hoodie-nike-2.jpg', 0, 2);
END

-- Thêm ảnh cho sản phẩm 7 (Quần legging thể thao Adidas)
IF @sp7Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp7Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp7Id, N'/images/products/legging-adidas-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp7Id, N'/images/products/legging-adidas-2.jpg', 0, 2);
END

-- Thêm ảnh cho sản phẩm 8 (Băng đô thể thao Nike)
IF @sp8Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp8Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp8Id, N'/images/products/bang-do-nike-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp8Id, N'/images/products/bang-do-nike-2.jpg', 0, 2);
END

-- Thêm ảnh cho sản phẩm 9 (Túi thể thao Puma)
IF @sp9Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp9Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp9Id, N'/images/products/tui-puma-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp9Id, N'/images/products/tui-puma-2.jpg', 0, 2);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp9Id, N'/images/products/tui-puma-3.jpg', 0, 3);
END

-- Thêm ảnh cho sản phẩm 10 (Giày tennis Adidas)
IF @sp10Id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.anh_san_pham WHERE id_san_pham = @sp10Id)
BEGIN
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'/images/products/giay-tennis-adidas-1.jpg', 1, 1);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'/images/products/giay-tennis-adidas-2.jpg', 0, 2);
    INSERT INTO dbo.anh_san_pham (id_san_pham, url_anh, la_anh_chinh, thu_tu) VALUES (@sp10Id, N'/images/products/giay-tennis-adidas-3.jpg', 0, 3);
END

PRINT N'✅ Hoàn tất tạo/cập nhật schema + dữ liệu mẫu đầy đủ cho DATN.';
PRINT N'📊 Tổng cộng: 32 bảng, đầy đủ chức năng, tương thích mọi máy SQL Server.';
PRINT N'🔧 Đã sửa lỗi CASCADE PATH CONFLICT.';
PRINT N'🛍️ Đã thêm 10 sản phẩm mẫu đa dạng cho trang chủ.';
PRINT N'📸 Đã thêm ảnh sản phẩm cho tất cả sản phẩm mẫu.';
GO
