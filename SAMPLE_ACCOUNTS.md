# 🔐 Tài Khoản Mẫu - Sample Accounts

## 📋 Danh Sách Tài Khoản

### 👑 **ADMIN ACCOUNTS** (Quản trị viên)

| Email | Mật khẩu | Vai trò | Mô tả |
|-------|----------|---------|-------|
| `admin@activewearstore.com` | `password` | ADMIN | Quản trị viên chính |
| `admin2@activewearstore.com` | `password` | ADMIN | Quản trị viên phụ |

**Quyền hạn:**
- ✅ Truy cập Admin Panel (`/admin`)
- ✅ Quản lý sản phẩm (CRUD)
- ✅ Quản lý danh mục môn thể thao
- ✅ Quản lý banner
- ✅ Xem thống kê dashboard
- ✅ Quản lý đơn hàng
- ✅ Quản lý người dùng

---

### 👨‍💼 **STAFF ACCOUNTS** (Nhân viên)

| Email | Mật khẩu | Vai trò | Mô tả |
|-------|----------|---------|-------|
| `staff@activewearstore.com` | `password` | STAFF | Nhân viên cửa hàng |

**Quyền hạn:**
- ✅ Truy cập một số chức năng admin
- ✅ Quản lý sản phẩm (hạn chế)
- ✅ Xem đơn hàng
- ✅ Hỗ trợ khách hàng

---

### 👤 **USER ACCOUNTS** (Khách hàng)

| Email | Mật khẩu | Vai trò | Mô tả |
|-------|----------|---------|-------|
| `customer@example.com` | `password` | USER | Khách hàng VIP |
| `user@example.com` | `password` | USER | Khách hàng thường |
| `test@example.com` | `password` | USER | Tài khoản test |

**Quyền hạn:**
- ✅ Xem sản phẩm
- ✅ Tìm kiếm và lọc sản phẩm
- ✅ Thêm vào giỏ hàng
- ✅ Thanh toán và đặt hàng
- ✅ Quản lý đơn hàng cá nhân
- ✅ Quản lý địa chỉ giao hàng
- ✅ Yêu thích sản phẩm

---

## 🚀 Hướng Dẫn Sử Dụng

### 1. **Chạy Script Tạo Tài Khoản**

```sql
-- Chạy file SQL để tạo tài khoản mẫu
-- File: src/main/resources/db/sample_accounts.sql
```

### 2. **Đăng Nhập**

#### **Admin Panel:**
1. Truy cập: `http://localhost:8080/admin`
2. Đăng nhập với tài khoản admin
3. Sử dụng các chức năng quản lý

#### **User Interface:**
1. Truy cập: `http://localhost:8080`
2. Click "Đăng nhập" hoặc truy cập `/login`
3. Nhập email và mật khẩu
4. Sử dụng các tính năng mua sắm

### 3. **Test Các Tính Năng**

#### **Với Admin Account:**
- ✅ Dashboard: `http://localhost:8080/admin`
- ✅ Quản lý sản phẩm: `http://localhost:8080/admin/products`
- ✅ Thêm sản phẩm mới: `http://localhost:8080/admin/products/create`
- ✅ Quản lý môn thể thao: `http://localhost:8080/admin/sports`
- ✅ Quản lý banner: `http://localhost:8080/admin/banners`

#### **Với User Account:**
- ✅ Trang chủ: `http://localhost:8080`
- ✅ Danh sách sản phẩm: `http://localhost:8080/products`
- ✅ Giỏ hàng: `http://localhost:8080/cart`
- ✅ Đơn hàng: `http://localhost:8080/orders`
- ✅ Checkout: `http://localhost:8080/checkout`

---

## 🔧 Cấu Hình Bảo Mật

### **Mật Khẩu Mặc Định**
- Tất cả tài khoản đều có mật khẩu: `password`
- Mật khẩu đã được mã hóa bằng **BCrypt**
- Hash: `$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi`

### **Bảo Mật**
- ✅ Mật khẩu được mã hóa
- ✅ Session management
- ✅ CSRF protection (đã disable cho API)
- ✅ Authentication required cho admin
- ✅ Authorization based on roles

---

## 📊 Thông Tin Bổ Sung

### **Dữ Liệu Mẫu Đã Tạo:**
- ✅ **3 Vai trò:** ADMIN, USER, STAFF
- ✅ **6 Tài khoản** với đầy đủ thông tin
- ✅ **Địa chỉ mặc định** cho một số user
- ✅ **Giỏ hàng** sẽ được tạo tự động khi cần

### **Database Schema:**
- Bảng `nguoi_dung` - Thông tin người dùng
- Bảng `vai_tro` - Vai trò trong hệ thống
- Bảng `dia_chi` - Địa chỉ giao hàng
- Bảng `gio_hang` - Giỏ hàng (tạo tự động)

---

## ⚠️ Lưu Ý Quan Trọng

1. **Môi trường Production:**
   - ❌ **KHÔNG** sử dụng mật khẩu `password` trong production
   - ❌ **KHÔNG** sử dụng email mẫu trong production
   - ✅ Thay đổi tất cả mật khẩu mặc định

2. **Bảo mật:**
   - ✅ Thường xuyên cập nhật mật khẩu
   - ✅ Sử dụng mật khẩu mạnh
   - ✅ Kiểm tra logs đăng nhập

3. **Testing:**
   - ✅ Sử dụng các tài khoản này chỉ để test
   - ✅ Xóa dữ liệu test trước khi deploy production

---

## 🆘 Troubleshooting

### **Lỗi Đăng Nhập:**
1. Kiểm tra email có đúng không
2. Kiểm tra mật khẩu có đúng không
3. Kiểm tra tài khoản có bị khóa không
4. Kiểm tra database connection

### **Lỗi Phân Quyền:**
1. Kiểm tra vai trò trong database
2. Kiểm tra SecurityConfig
3. Kiểm tra session

### **Lỗi Database:**
1. Chạy lại script `sample_accounts.sql`
2. Kiểm tra foreign key constraints
3. Kiểm tra table permissions

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. **Logs** trong console
2. **Database** connection
3. **Application properties**
4. **Security configuration**

---

**🎉 Chúc bạn test thành công!**
