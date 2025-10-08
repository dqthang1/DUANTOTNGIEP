# 🛒 Dự Án Tốt Nghiệp - Giỏ Hàng & Thanh Toán

## 📋 Mô tả dự án

Dự án E-commerce hoàn chỉnh với hệ thống giỏ hàng và thanh toán VNPay, được phát triển bằng Spring Boot.

## 🚀 Tính năng chính

### 🛒 Giỏ hàng
- ✅ Thêm/sửa/xóa sản phẩm trong giỏ hàng
- ✅ Cập nhật số lượng sản phẩm
- ✅ Tính toán tổng tiền tự động
- ✅ Lưu trữ giỏ hàng theo session

### 💳 Thanh toán
- ✅ Thanh toán COD (Cash on Delivery)
- ✅ Thanh toán VNPay (Online)
- ✅ Tích hợp API VNPay sandbox
- ✅ Xử lý kết quả thanh toán
- ✅ Gửi email xác nhận đơn hàng

### 🏠 Quản lý địa chỉ
- ✅ Tích hợp API tỉnh thành Việt Nam
- ✅ Dropdown cascade: Tỉnh → Quận/Huyện → Phường/Xã
- ✅ Thêm/sửa/xóa địa chỉ giao hàng
- ✅ Đặt địa chỉ mặc định

### 📦 Quản lý đơn hàng
- ✅ Tạo đơn hàng từ giỏ hàng
- ✅ Theo dõi trạng thái đơn hàng
- ✅ Hủy đơn hàng (khi chưa xác nhận)
- ✅ Gửi email thông báo

### 👤 Xác thực người dùng
- ✅ Đăng ký/Đăng nhập
- ✅ Phân quyền Admin/User
- ✅ Bảo mật với Spring Security

## 🛠️ Công nghệ sử dụng

### Backend
- **Spring Boot 3.5.6** - Framework chính
- **Spring Security** - Bảo mật
- **Spring Data JPA** - ORM
- **SQL Server** - Database
- **JavaMail** - Gửi email
- **Thymeleaf** - Template engine

### Frontend
- **HTML5/CSS3** - Giao diện
- **Bootstrap 5** - UI Framework
- **JavaScript ES6+** - Logic frontend
- **Fetch API** - AJAX requests

### Payment
- **VNPay API** - Thanh toán online
- **HMAC SHA512** - Bảo mật checksum

### External APIs
- **provinces.open-api.vn** - API tỉnh thành Việt Nam

## 📁 Cấu trúc dự án

```
src/
├── main/
│   ├── java/com/example/demo/
│   │   ├── config/          # Cấu hình
│   │   ├── controller/      # REST APIs & Web routing
│   │   ├── entity/          # Database models
│   │   ├── repository/      # Data access layer
│   │   └── service/         # Business logic
│   └── resources/
│       ├── static/js/       # JavaScript files
│       ├── templates/       # HTML templates
│       └── db/             # Database schema
└── test/                   # Unit tests
```

## 🚀 Hướng dẫn cài đặt

### 1. Yêu cầu hệ thống
- Java 17+
- Maven 3.6+
- SQL Server 2019+
- Git

### 2. Clone repository
```bash
git clone https://github.com/lthe205/DuAnTotNghiep.git
cd DuAnTotNghiep
git checkout cart-payment
```

### 3. Cấu hình database
- Tạo database `DATN` trong SQL Server
- Chạy script `src/main/resources/db/DATN.sql`
- Cập nhật thông tin database trong `application.properties`

### 4. Cấu hình email
Cập nhật thông tin email trong `application.properties`:
```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
```

### 5. Cấu hình VNPay
Cập nhật thông tin VNPay trong `application.properties`:
```properties
vnpay.tmnCode=YOUR_TMN_CODE
vnpay.secretKey=YOUR_SECRET_KEY
vnpay.payUrl=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
```

### 6. Chạy ứng dụng
```bash
./mvnw.cmd spring-boot:run
```

### 7. Truy cập ứng dụng
- **URL:** http://localhost:8080
- **Admin:** admin@example.com / admin123
- **User:** user@example.com / admin123

## 📊 Database Schema

### Bảng chính
- `user` - Người dùng
- `product` - Sản phẩm
- `cart` - Giỏ hàng
- `cart_item` - Item trong giỏ hàng
- `don_hang` - Đơn hàng
- `order_item` - Item trong đơn hàng
- `dia_chi` - Địa chỉ giao hàng
- `thanh_toan` - Thanh toán

## 🔄 Quy trình thanh toán

### COD (Cash on Delivery)
1. Tạo đơn hàng → `CHO_XAC_NHAN`
2. Admin xác nhận → `DANG_CHUAN_BI`
3. Gửi email xác nhận

### VNPay
1. Tạo đơn hàng → `CHO_XAC_NHAN`
2. Chuyển hướng đến VNPay
3. Thanh toán thành công → `DANG_CHUAN_BI`
4. Gửi email xác nhận

## 📧 Email Templates

- **order-confirmation.html** - Xác nhận đơn hàng
- **order-cancellation.html** - Hủy đơn hàng

## 🌐 API Endpoints

### Giỏ hàng
- `GET /api/cart` - Lấy giỏ hàng
- `POST /api/cart/add` - Thêm sản phẩm
- `PUT /api/cart/update` - Cập nhật số lượng
- `DELETE /api/cart/remove` - Xóa sản phẩm

### Đơn hàng
- `GET /api/orders` - Lấy danh sách đơn hàng
- `POST /api/orders/create` - Tạo đơn hàng
- `POST /api/orders/{id}/cancel` - Hủy đơn hàng

### Thanh toán
- `POST /payment/vnpay/create` - Tạo URL thanh toán VNPay
- `GET /payment/vnpay-return` - Xử lý kết quả thanh toán

### Địa chỉ
- `GET /api/addresses` - Lấy danh sách địa chỉ
- `POST /api/addresses` - Thêm địa chỉ mới
- `GET /api/address/provinces` - Lấy danh sách tỉnh thành

## 👥 Tác giả

**Lê Thế** - Sinh viên thực hiện phần Giỏ hàng & Thanh toán

## 📝 License

Dự án được phát triển cho mục đích học tập và tốt nghiệp.

## 🔗 Links

- **Repository:** https://github.com/lthe205/DuAnTotNghiep
- **Branch:** cart-payment
- **VNPay Documentation:** https://sandbox.vnpayment.vn/apis/
- **Provinces API:** https://provinces.open-api.vn/

---

**🎉 Cảm ơn bạn đã quan tâm đến dự án!**
