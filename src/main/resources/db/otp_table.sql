-- =========================================================
-- OTP Verification Table for SQL Server
-- Tích hợp vào database DATN hiện tại
-- =========================================================

USE DATN;
GO

-- Tạo bảng OTP Verification (tương thích với SQL Server)
IF OBJECT_ID(N'dbo.otp_verification',N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[otp_verification](
    [id] [bigint] IDENTITY(1,1) NOT NULL,
    [email] [nvarchar](255) NOT NULL,
    [otp_code] [nvarchar](6) NOT NULL,
    [type] [nvarchar](50) NOT NULL DEFAULT (N'REGISTRATION'),
    [expires_at] [datetime2](0) NOT NULL,
    [is_used] [bit] NOT NULL DEFAULT (0),
    [attempts] [int] NOT NULL DEFAULT (0),
    [max_attempts] [int] NOT NULL DEFAULT (3),
    [created_at] [datetime2](0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    [used_at] [datetime2](0) NULL,
 CONSTRAINT [PK_otp_verification] PRIMARY KEY CLUSTERED ([id] ASC)
);
PRINT N'✅ Tạo dbo.otp_verification';
END

-- Tạo indexes để tối ưu hiệu suất
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_otp_verification_email_type' AND object_id = OBJECT_ID('dbo.otp_verification'))
    CREATE NONCLUSTERED INDEX [IX_otp_verification_email_type] ON [dbo].[otp_verification] ([email], [type]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_otp_verification_expires_at' AND object_id = OBJECT_ID('dbo.otp_verification'))
    CREATE NONCLUSTERED INDEX [IX_otp_verification_expires_at] ON [dbo].[otp_verification] ([expires_at]);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_otp_verification_created_at' AND object_id = OBJECT_ID('dbo.otp_verification'))
    CREATE NONCLUSTERED INDEX [IX_otp_verification_created_at] ON [dbo].[otp_verification] ([created_at]);

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
    WHERE [expires_at] < GETDATE();
    
    -- Xóa các OTP đã sử dụng cũ hơn 7 ngày
    DELETE FROM [dbo].[otp_verification] 
    WHERE [is_used] = 1 AND [used_at] < DATEADD(day, -7, GETDATE());
    
    -- Xóa các OTP chưa sử dụng cũ hơn 24 giờ
    DELETE FROM [dbo].[otp_verification] 
    WHERE [is_used] = 0 AND [created_at] < DATEADD(hour, -24, GETDATE());
    
    PRINT N'✅ Đã cleanup OTP cũ thành công';
END
GO

-- Tạo stored procedure để lấy thống kê OTP
IF OBJECT_ID(N'dbo.GetOtpStats', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[GetOtpStats];
GO

CREATE PROCEDURE [dbo].[GetOtpStats]
    @Days INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CAST([created_at] AS DATE) as [date],
        [type],
        COUNT(*) as [total_otps],
        SUM(CASE WHEN [is_used] = 1 THEN 1 ELSE 0 END) as [used_otps],
        SUM(CASE WHEN [is_used] = 0 AND [expires_at] < GETDATE() THEN 1 ELSE 0 END) as [expired_otps],
        CASE 
            WHEN COUNT(*) > 0 THEN 
                ROUND((CAST(SUM(CASE WHEN [is_used] = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 2)
            ELSE 0 
        END as [success_rate]
    FROM [dbo].[otp_verification] 
    WHERE [created_at] >= DATEADD(day, -@Days, GETDATE())
    GROUP BY CAST([created_at] AS DATE), [type]
    ORDER BY [date] DESC, [type];
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
        [otp_code],
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
        AND [expires_at] > GETDATE() 
        AND [attempts] < [max_attempts]
    ORDER BY [created_at] DESC;
END
GO

-- Tạo stored procedure để tăng số lần thử
IF OBJECT_ID(N'dbo.IncrementOtpAttempts', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[IncrementOtpAttempts];
GO

CREATE PROCEDURE [dbo].[IncrementOtpAttempts]
    @Id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE [dbo].[otp_verification]
    SET [attempts] = [attempts] + 1
    WHERE [id] = @Id;
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
    SET [is_used] = 1, [used_at] = GETDATE()
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
        AND [created_at] > DATEADD(hour, -@Hours, GETDATE());
END
GO

PRINT N'✅ Hoàn tất tạo bảng OTP Verification và các stored procedures';
PRINT N'📊 Bảng: otp_verification với đầy đủ indexes';
PRINT N'🔧 Stored Procedures: CleanupExpiredOtps, GetOtpStats, GetActiveOtp, IncrementOtpAttempts, MarkOtpAsUsed, CountRecentOtps';
PRINT N'⚡ Tối ưu cho SQL Server với datetime2 và nvarchar';
GO
