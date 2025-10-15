# 🚀 QUICK START - Hướng Dẫn Nhanh

## 📋 Tài Khoản Mẫu

### 👑 **ADMIN** (Truy cập Admin Panel)
```
Email: admin@activewearstore.com
Mật khẩu: password
URL: http://localhost:8080/admin
```

### 👤 **USER** (Khách hàng)
```
Email: customer@example.com
Mật khẩu: password
URL: http://localhost:8080
```

---

## 🎯 Các Tính Năng Chính

### **1. Admin Panel** (`/admin`)
- ✅ Dashboard với thống kê
- ✅ Quản lý sản phẩm (CRUD)
- ✅ Quản lý danh mục môn thể thao
- ✅ Quản lý banner
- ✅ Upload hình ảnh

### **2. User Interface** (`/`)
- ✅ Trang chủ với sản phẩm nổi bật
- ✅ Tìm kiếm và lọc sản phẩm
- ✅ Chi tiết sản phẩm với gallery
- ✅ Giỏ hàng và checkout
- ✅ Quản lý đơn hàng
- ✅ Yêu thích sản phẩm

---

## 🔧 Cách Chạy

### **1. Khởi động ứng dụng:**
```bash
mvn spring-boot:run
```

### **2. Truy cập:**
- **Admin:** http://localhost:8080/admin
- **User:** http://localhost:8080

### **3. Đăng nhập:**
- Sử dụng tài khoản mẫu ở trên
- Tất cả đều có mật khẩu: `password`

---

## 📱 Test Các Tính Năng

### **Admin:**
1. Đăng nhập admin → Dashboard
2. Tạo sản phẩm mới → Upload hình ảnh
3. Quản lý danh mục môn thể thao
4. Tạo banner quảng cáo

### **User:**
1. Đăng nhập user → Trang chủ
2. Tìm kiếm sản phẩm → Lọc theo giá/danh mục
3. Xem chi tiết sản phẩm → Thêm vào yêu thích
4. Thêm vào giỏ hàng → Checkout

---

## 🎨 Giao Diện

- ✅ **Responsive** - Hoạt động tốt trên mobile
- ✅ **Bootstrap 5** - UI hiện đại
- ✅ **Font Awesome** - Icons đẹp
- ✅ **Thymeleaf** - Template engine

---

## 🔐 Bảo Mật

- ✅ **Spring Security** - Authentication & Authorization
- ✅ **BCrypt** - Mã hóa mật khẩu
- ✅ **CSRF Protection** - Bảo vệ form
- ✅ **Role-based Access** - Phân quyền theo vai trò

---

## 📊 Database

- ✅ **SQL Server** - Hệ quản trị cơ sở dữ liệu
- ✅ **JPA/Hibernate** - ORM
- ✅ **Auto-generated** - Tài khoản mẫu tự động tạo
- ✅ **Relationships** - Liên kết đầy đủ giữa các bảng

---

## 🆘 Troubleshooting

### **Lỗi đăng nhập:**
- Kiểm tra email/mật khẩu
- Kiểm tra database connection
- Kiểm tra logs trong console

### **Lỗi 404:**
- Kiểm tra URL có đúng không
- Kiểm tra controller mapping

### **Lỗi database:**
- Kiểm tra SQL Server đang chạy
- Kiểm tra connection string trong `application.properties`

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Kiểm tra logs trong console
2. Kiểm tra database connection
3. Kiểm tra file `application.properties`
4. Restart ứng dụng

---

**🎉 Chúc bạn test thành công!**
