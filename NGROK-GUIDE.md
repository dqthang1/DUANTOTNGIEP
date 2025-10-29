# 🌐 Ngrok Setup Guide - Activewear Store

## 📋 Tổng quan
Hướng dẫn sử dụng ngrok để expose ứng dụng Spring Boot ra internet, cho phép test từ bất kỳ đâu.

## 🚀 Cách sử dụng

### 1. Chạy nhanh (Khuyến nghị)
```bash
start-ngrok.bat
```
Script này sẽ:
- Khởi động Spring Boot
- Chạy ngrok tunnel
- Tự động lấy URL ngrok
- Cập nhật cấu hình ứng dụng
- Mở trang test

### 2. Chạy từng bước
```bash
# Bước 1: Chạy Spring Boot
mvn spring-boot:run

# Bước 2: Chạy ngrok (terminal mới)
ngrok.exe http 8080

# Bước 3: Lấy URL ngrok
get-ngrok-url.bat

# Bước 4: Cập nhật URL (nếu cần)
update-ngrok-url.bat
```

## 🔧 Các script có sẵn

| Script | Mô tả |
|--------|-------|
| `start-ngrok.bat` | Chạy tất cả (Spring Boot + ngrok + auto config) |
| `run-with-ngrok.bat` | Chạy Spring Boot và ngrok song song |
| `get-ngrok-url.bat` | Lấy URL ngrok hiện tại |
| `update-ngrok-url.bat` | Cập nhật URL ngrok vào config |
| `run-and-test.bat` | Chạy local (không ngrok) |

## 📱 Test từ xa

### 1. Lấy URL ngrok
```bash
get-ngrok-url.bat
```
Kết quả sẽ như: `https://abc123.ngrok.io`

### 2. Chia sẻ URL
- Gửi URL cho người khác để test
- URL sẽ hoạt động từ bất kỳ đâu trên internet
- Không cần cài đặt gì thêm

### 3. Test các tính năng
- **Đăng ký:** `https://abc123.ngrok.io/register`
- **Đăng nhập:** `https://abc123.ngrok.io/login`
- **Admin:** `https://abc123.ngrok.io/admin/dashboard`
- **API:** `https://abc123.ngrok.io/api/check-email`

## ⚙️ Cấu hình

### Application Properties
File `application.properties` sẽ được tự động cập nhật:
```properties
# URL chính
app.url=https://your-ngrok-url.ngrok.io

# VNPay return URL
vnpay.returnUrl=https://your-ngrok-url.ngrok.io/payment/vnpay-return
```

### Email Configuration
Email OTP sẽ hoạt động với ngrok URL:
- Link xác nhận sẽ dùng ngrok URL
- Email templates sẽ hiển thị đúng URL

## 🔍 Troubleshooting

### Lỗi thường gặp

1. **Ngrok không chạy**
   ```bash
   # Kiểm tra ngrok có chạy không
   curl http://localhost:4040/api/tunnels
   ```

2. **URL không cập nhật**
   ```bash
   # Cập nhật thủ công
   update-ngrok-url.bat
   ```

3. **Spring Boot không start**
   ```bash
   # Kiểm tra port 8080 có bị chiếm không
   netstat -ano | findstr :8080
   ```

### Reset cấu hình
```bash
# Khôi phục config gốc
copy "src\main\resources\application.properties.backup" "src\main\resources\application.properties"
```

## 📊 Monitoring

### Ngrok Dashboard
- Truy cập: http://localhost:4040
- Xem traffic, requests, response time
- Debug các vấn đề kết nối

### Logs
- Spring Boot logs: Console window
- Ngrok logs: Ngrok window
- Application logs: `logs/` folder

## 🔒 Bảo mật

### Lưu ý quan trọng
- Ngrok URL là public, ai cũng có thể truy cập
- Không sử dụng cho production
- Chỉ dùng cho testing và demo
- URL sẽ thay đổi mỗi lần restart ngrok (trừ khi có tài khoản ngrok)

### Tài khoản ngrok (Tùy chọn)
- Đăng ký tại: https://ngrok.com
- Có thể sử dụng custom domain
- URL cố định
- Nhiều tính năng hơn

## 🎯 Test Cases

### 1. Đăng ký tài khoản
- Test với email mới
- Kiểm tra email validation real-time
- Test OTP verification

### 2. Đăng nhập
- Test với tài khoản có sẵn
- Test phân quyền admin/user

### 3. Tính năng khác
- Cart, checkout
- Admin panel
- API endpoints

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs
2. Restart các service
3. Kiểm tra firewall
4. Đảm bảo port 8080 và 4040 không bị block

---
**Lưu ý:** Ngrok URL sẽ thay đổi mỗi lần restart ngrok (trừ khi có tài khoản ngrok pro).
