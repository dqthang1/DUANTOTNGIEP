# 🚀 Hướng dẫn Setup OTP Verification System

## 📋 Tổng quan
Hệ thống OTP (One-Time Password) đã được tích hợp vào ứng dụng Activewear Store để xác thực email khi đăng ký tài khoản.

## 🗄️ Database Setup

### 1. Chạy script SQL
```sql
-- Chạy file này trong SQL Server Management Studio
-- Desktop/GioHangThanhToan/demo/src/main/resources/db/otp_table.sql
```

### 2. Kiểm tra bảng đã được tạo
```sql
-- Kiểm tra bảng OTP
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'otp_verification';

-- Kiểm tra stored procedures
SELECT name FROM sys.procedures WHERE name LIKE '%Otp%';
```

## ⚙️ Application Configuration

### 1. Email Configuration (application.properties)
```properties
# Email Configuration
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
spring.mail.properties.mail.smtp.starttls.required=true
```

### 2. Database Configuration
```properties
# Database Configuration (SQL Server)
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=DATN;trustServerCertificate=true
spring.datasource.username=your-username
spring.datasource.password=your-password
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver
```

## 🔄 Quy trình hoạt động

### 1. Đăng ký tài khoản
1. User điền form đăng ký
2. Hệ thống tạo user với `emailVerified = false`
3. Gửi OTP qua email
4. Redirect đến trang xác nhận OTP

### 2. Xác nhận OTP
1. User nhập mã OTP 6 chữ số
2. Hệ thống kiểm tra:
   - Mã OTP có đúng không
   - Còn hạn sử dụng không (10 phút)
   - Chưa vượt quá số lần thử (3 lần)
3. Nếu đúng: kích hoạt tài khoản và redirect đến login
4. Nếu sai: hiển thị lỗi và cho phép thử lại

### 3. Resend OTP
- User có thể gửi lại OTP sau 60 giây
- Rate limiting: tối đa 3 OTP/giờ cho mỗi email

## 🛡️ Tính năng bảo mật

### 1. Rate Limiting
- **3 OTP/giờ** cho mỗi email
- **3 lần thử** cho mỗi OTP
- **10 phút** thời gian hết hạn

### 2. Auto Cleanup
- Tự động xóa OTP đã hết hạn
- Xóa OTP đã sử dụng cũ hơn 7 ngày
- Xóa OTP chưa sử dụng cũ hơn 24 giờ

### 3. Database Security
- Indexes tối ưu cho performance
- Stored procedures cho các thao tác phức tạp
- Tương thích với SQL Server

## 📱 UI/UX Features

### 1. Trang xác nhận OTP
- **Real-time timer** hiển thị thời gian còn lại
- **Auto-focus** vào input OTP
- **Paste support** cho mã OTP
- **Loading states** cho các thao tác
- **Responsive design** cho mọi thiết bị

### 2. Email Template
- **HTML email** đẹp mắt với branding
- **Thông tin bảo mật** và hướng dẫn
- **Responsive design** cho email client

## 🔧 API Endpoints

### 1. Registration Flow
```
POST /register
- Tạo user mới
- Gửi OTP
- Redirect đến /otp-verification

GET /otp-verification?email=user@example.com
- Hiển thị trang xác nhận OTP
```

### 2. OTP Verification
```
POST /verify-otp
- Xác nhận OTP
- Kích hoạt tài khoản nếu thành công
- Redirect đến /login

POST /resend-otp
- Gửi lại OTP mới
- Rate limiting check
```

## 🧪 Testing

### 1. Test OTP Generation
```java
@Autowired
private OtpService otpService;

@Test
public void testSendOtp() {
    boolean result = otpService.sendRegistrationOtp("test@example.com");
    assertTrue(result);
}
```

### 2. Test OTP Verification
```java
@Test
public void testVerifyOtp() {
    boolean result = otpService.verifyRegistrationOtp("test@example.com", "123456");
    // Assert based on your test data
}
```

## 📊 Monitoring

### 1. OTP Statistics
```sql
-- Xem thống kê OTP
EXEC GetOtpStats @Days = 30;

-- Xem OTP active
EXEC GetActiveOtp @Email = 'user@example.com', @Type = 'REGISTRATION';

-- Đếm OTP gần đây
EXEC CountRecentOtps @Email = 'user@example.com', @Hours = 1;
```

### 2. Cleanup Manual
```sql
-- Cleanup OTP cũ thủ công
EXEC CleanupExpiredOtps;
```

## 🚨 Troubleshooting

### 1. Email không gửi được
- Kiểm tra email configuration
- Kiểm tra Gmail App Password (nếu dùng Gmail)
- Kiểm tra firewall/antivirus

### 2. OTP không lưu được
- Kiểm tra database connection
- Kiểm tra bảng otp_verification đã được tạo
- Kiểm tra logs trong console

### 3. OTP không xác nhận được
- Kiểm tra thời gian server
- Kiểm tra timezone configuration
- Kiểm tra OTP có hết hạn chưa

## 📝 Logs

### 1. Application Logs
```
INFO  - Registration OTP sent to user@example.com
INFO  - Email verified successfully for user user@example.com
WARN  - Too many OTP requests for email user@example.com in the last hour
```

### 2. Database Logs
```sql
-- Xem OTP logs
SELECT * FROM otp_verification ORDER BY created_at DESC;

-- Xem failed attempts
SELECT * FROM otp_verification WHERE attempts >= max_attempts;
```

## 🎯 Next Steps

1. **Setup email configuration** với SMTP server thực
2. **Test toàn bộ flow** từ đăng ký đến xác nhận
3. **Monitor logs** để đảm bảo hoạt động ổn định
4. **Setup scheduled cleanup** nếu cần
5. **Customize email template** theo brand của bạn

## 📞 Support

Nếu gặp vấn đề, hãy kiểm tra:
1. **Database connection** và permissions
2. **Email configuration** và credentials
3. **Application logs** để xem lỗi chi tiết
4. **Network connectivity** đến SMTP server

---
✅ **Hệ thống OTP đã sẵn sàng sử dụng!**
