package com.example.demo.config;

import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {
    
    private final PasswordEncoder passwordEncoder;
    private final VaiTroRepository vaiTroRepository;
    private final UserRepository userRepository;
    private final DiaChiRepository diaChiRepository;
    
    @Override
    public void run(String... args) throws Exception {
        log.info("🚀 Khởi tạo dữ liệu mẫu...");
        
        // Tạo vai trò nếu chưa có
        createRolesIfNotExist();
        
        // Tạo tài khoản mẫu nếu chưa có
        createSampleAccounts();
        
        log.info("✅ Hoàn thành khởi tạo dữ liệu mẫu!");
    }
    
    private void createRolesIfNotExist() {
        log.info("📋 Tạo vai trò...");
        
        // Tạo vai trò ADMIN
        if (!vaiTroRepository.findByTenVaiTro("ADMIN").isPresent()) {
            VaiTro adminRole = new VaiTro();
            adminRole.setTenVaiTro("ADMIN");
            adminRole.setMoTa("Quản trị viên hệ thống");
            vaiTroRepository.save(adminRole);
            log.info("  ✅ Tạo vai trò ADMIN");
        }
        
        // Tạo vai trò USER
        if (!vaiTroRepository.findByTenVaiTro("USER").isPresent()) {
            VaiTro userRole = new VaiTro();
            userRole.setTenVaiTro("USER");
            userRole.setMoTa("Người dùng thông thường");
            vaiTroRepository.save(userRole);
            log.info("  ✅ Tạo vai trò USER");
        }
        
        // Tạo vai trò STAFF
        if (!vaiTroRepository.findByTenVaiTro("STAFF").isPresent()) {
            VaiTro staffRole = new VaiTro();
            staffRole.setTenVaiTro("STAFF");
            staffRole.setMoTa("Nhân viên cửa hàng");
            vaiTroRepository.save(staffRole);
            log.info("  ✅ Tạo vai trò STAFF");
        }
    }
    
    private void createSampleAccounts() {
        log.info("👥 Tạo tài khoản mẫu...");
        
        // Lấy các vai trò
        VaiTro adminRole = vaiTroRepository.findByTenVaiTro("ADMIN").orElse(null);
        VaiTro userRole = vaiTroRepository.findByTenVaiTro("USER").orElse(null);
        VaiTro staffRole = vaiTroRepository.findByTenVaiTro("STAFF").orElse(null);
        
        if (adminRole == null || userRole == null || staffRole == null) {
            log.error("❌ Không thể tạo tài khoản vì thiếu vai trò!");
            return;
        }
        
        // Tạo ADMIN accounts
        createAdminAccount("admin@datnfpolysd45.com", "Quản trị viên hệ thống", adminRole);
        createAdminAccount("admin2@datnfpolysd45.com", "Nguyễn Văn Admin", adminRole);
        
        // Tạo STAFF account
        createStaffAccount("staff@datnfpolysd45.com", "Trần Thị Nhân viên", staffRole);
        
        // Tạo USER accounts
        createUserAccount("customer@example.com", "Lê Văn Khách hàng", userRole, true);
        createUserAccount("user@example.com", "Phạm Thị Người dùng", userRole, true);
        createUserAccount("test@example.com", "Nguyễn Văn Test", userRole, false);
    }
    
    private void createAdminAccount(String email, String ten, VaiTro role) {
        if (!userRepository.findByEmail(email).isPresent()) {
            User user = new User();
            user.setTen(ten);
            user.setEmail(email);
            user.setMatKhau(passwordEncoder.encode("password"));
            user.setSoDienThoai("0123456789");
            user.setDiaChi("123 Đường ABC, Quận 1, TP.HCM");
            user.setGioiTinh("Nam");
            user.setNgaySinh(LocalDate.of(1990, 1, 1));
            user.setHoatDong(true);
            user.setEmailVerified(true);
            user.setNgayDangKy(LocalDateTime.now());
            user.setNgayCapNhat(LocalDateTime.now());
            user.setVaiTro(role);
            
            userRepository.save(user);
            log.info("  ✅ Tạo ADMIN: {} / password", email);
        } else {
            log.info("  ⚠️ ADMIN {} đã tồn tại", email);
        }
    }
    
    private void createStaffAccount(String email, String ten, VaiTro role) {
        if (!userRepository.findByEmail(email).isPresent()) {
            User user = new User();
            user.setTen(ten);
            user.setEmail(email);
            user.setMatKhau(passwordEncoder.encode("password"));
            user.setSoDienThoai("0369852147");
            user.setDiaChi("789 Đường DEF, Quận 3, TP.HCM");
            user.setGioiTinh("Nữ");
            user.setNgaySinh(LocalDate.of(1992, 3, 20));
            user.setHoatDong(true);
            user.setEmailVerified(true);
            user.setNgayDangKy(LocalDateTime.now());
            user.setNgayCapNhat(LocalDateTime.now());
            user.setVaiTro(role);
            
            userRepository.save(user);
            log.info("  ✅ Tạo STAFF: {} / password", email);
        } else {
            log.info("  ⚠️ STAFF {} đã tồn tại", email);
        }
    }
    
    private void createUserAccount(String email, String ten, VaiTro role, boolean createAddress) {
        if (!userRepository.findByEmail(email).isPresent()) {
            User user = new User();
            user.setTen(ten);
            user.setEmail(email);
            user.setMatKhau(passwordEncoder.encode("password"));
            user.setSoDienThoai("0901234567");
            user.setDiaChi("321 Đường GHI, Quận 4, TP.HCM");
            user.setGioiTinh("Nam");
            user.setNgaySinh(LocalDate.of(1995, 7, 10));
            user.setHoatDong(true);
            user.setEmailVerified(true);
            user.setNgayDangKy(LocalDateTime.now());
            user.setNgayCapNhat(LocalDateTime.now());
            user.setVaiTro(role);
            
            User savedUser = userRepository.save(user);
            log.info("  ✅ Tạo USER: {} / password", email);
            
            // Tạo địa chỉ mặc định nếu cần
            if (createAddress) {
                createDefaultAddress(savedUser);
            }
        } else {
            log.info("  ⚠️ USER {} đã tồn tại", email);
        }
    }
    
    private void createDefaultAddress(User user) {
        // Kiểm tra xem đã có địa chỉ mặc định chưa
        if (diaChiRepository.findByNguoiDungIdAndLaDiaChiMacDinhTrue(user.getId()).isEmpty()) {
            DiaChi diaChi = new DiaChi();
            diaChi.setTenNguoiNhan(user.getTen());
            diaChi.setSoDienThoai(user.getSoDienThoai());
            diaChi.setDiaChiChiTiet("321 Đường GHI, Phường 10");
            diaChi.setTinhThanh("TP.HCM");
            diaChi.setQuanHuyen("Quận 4");
            diaChi.setPhuongXa("Phường 10");
            diaChi.setLaDiaChiMacDinh(true);
            diaChi.setNgayTao(LocalDateTime.now());
            diaChi.setNguoiDung(user);
            
            diaChiRepository.save(diaChi);
            log.info("    📍 Tạo địa chỉ mặc định cho {}", user.getEmail());
        }
    }
}
