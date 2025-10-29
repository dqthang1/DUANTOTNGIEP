package com.example.demo.controller;

import com.example.demo.entity.DiaChi;
import com.example.demo.entity.User;
import com.example.demo.repository.DiaChiRepository;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/profile")
@RequiredArgsConstructor
@Slf4j
public class ProfileController {
    
    private final UserService userService;
    private final DiaChiRepository diaChiRepository;
    private final PasswordEncoder passwordEncoder;
    
    /**
     * Hiển thị trang profile
     */
    @GetMapping
    public String profile(Model model, Authentication authentication) {
        if (authentication == null) {
            return "redirect:/login";
        }
        
        User user = getCurrentUser(authentication);
        addUserAttributesToModel(model, user);
        
        // Load user addresses
        List<DiaChi> addresses = diaChiRepository.findByUserIdOrderByDefaultAndDate(user.getId());
        model.addAttribute("addresses", addresses);
        
        return "profile";
    }
    
    /**
     * Cập nhật thông tin cá nhân
     */
    @PostMapping("/update")
    public String updateProfile(
            @RequestParam String ten,
            @RequestParam String email,
            @RequestParam(required = false) String soDienThoai,
            @RequestParam(required = false) String diaChi,
            @RequestParam(required = false) String ngaySinh,
            @RequestParam(required = false) String gioiTinh,
            Authentication authentication,
            RedirectAttributes redirectAttributes) {
        
        try {
            User user = getCurrentUser(authentication);
            
            // Validate email uniqueness (if changed)
            if (!user.getEmail().equals(email)) {
                Optional<User> existingUser = userService.findByEmail(email);
                if (existingUser.isPresent() && !existingUser.get().getId().equals(user.getId())) {
                    redirectAttributes.addFlashAttribute("error", "Email này đã được sử dụng bởi tài khoản khác");
                    return "redirect:/profile";
                }
            }
            
            // Update user information
            user.setTen(ten);
            user.setEmail(email);
            user.setSoDienThoai(soDienThoai);
            user.setDiaChi(diaChi);
            
            if (ngaySinh != null && !ngaySinh.isEmpty()) {
                try {
                    LocalDate birthDate = LocalDate.parse(ngaySinh, DateTimeFormatter.ISO_LOCAL_DATE);
                    user.setNgaySinh(birthDate);
                } catch (Exception e) {
                    log.warn("Invalid date format: {}", ngaySinh);
                }
            }
            
            if (gioiTinh != null && !gioiTinh.isEmpty()) {
                user.setGioiTinh(gioiTinh);
            }
            
            userService.save(user);
            redirectAttributes.addFlashAttribute("success", "Cập nhật thông tin thành công!");
            
        } catch (Exception e) {
            log.error("Error updating profile", e);
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra khi cập nhật thông tin");
        }
        
        return "redirect:/profile";
    }
    
    /**
     * Đổi mật khẩu
     */
    @PostMapping("/change-password")
    public String changePassword(
            @RequestParam String currentPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword,
            Authentication authentication,
            RedirectAttributes redirectAttributes) {
        
        try {
            User user = getCurrentUser(authentication);
            
            // Validate current password
            if (!passwordEncoder.matches(currentPassword, user.getMatKhau())) {
                redirectAttributes.addFlashAttribute("error", "Mật khẩu hiện tại không đúng");
                return "redirect:/profile";
            }
            
            // Validate new password
            if (!newPassword.equals(confirmPassword)) {
                redirectAttributes.addFlashAttribute("error", "Mật khẩu mới và xác nhận mật khẩu không khớp");
                return "redirect:/profile";
            }
            
            if (newPassword.length() < 6) {
                redirectAttributes.addFlashAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự");
                return "redirect:/profile";
            }
            
            // Update password
            user.setMatKhau(passwordEncoder.encode(newPassword));
            userService.save(user);
            
            redirectAttributes.addFlashAttribute("success", "Đổi mật khẩu thành công!");
            
        } catch (Exception e) {
            log.error("Error changing password", e);
            redirectAttributes.addFlashAttribute("error", "Có lỗi xảy ra khi đổi mật khẩu");
        }
        
        return "redirect:/profile";
    }
    
    /**
     * API: Lấy thông tin user
     */
    @GetMapping("/api/user")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUserInfo(Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", user.getId());
            userInfo.put("ten", user.getTen());
            userInfo.put("email", user.getEmail());
            userInfo.put("soDienThoai", user.getSoDienThoai());
            userInfo.put("diaChi", user.getDiaChi());
            userInfo.put("ngaySinh", user.getNgaySinh());
            userInfo.put("gioiTinh", user.getGioiTinh());
            userInfo.put("ngayDangKy", user.getNgayDangKy());
            userInfo.put("emailVerified", user.getEmailVerified());
            
            return ResponseEntity.ok(Map.of("success", true, "user", userInfo));
        } catch (Exception e) {
            log.error("Error getting user info", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * API: Cập nhật avatar
     */
    @PostMapping("/api/avatar")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateAvatar(
            @RequestParam("avatarFile") MultipartFile avatarFile,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            
            // Validate file
            if (avatarFile.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Vui lòng chọn file ảnh"));
            }
            
            // Check file type
            String contentType = avatarFile.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Chỉ được upload file ảnh"));
            }
            
            // Check file size (max 5MB)
            if (avatarFile.getSize() > 5 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "File ảnh không được vượt quá 5MB"));
            }
            
            // Generate unique filename
            String originalFilename = avatarFile.getOriginalFilename();
            String fileExtension = originalFilename != null ? 
                originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
            String newFilename = "avatar_" + user.getId() + "_" + UUID.randomUUID().toString() + fileExtension;
            
            // Create upload directory if not exists
            Path uploadDir = Paths.get("src/main/resources/static/images/avatars");
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            
            // Save file
            Path filePath = uploadDir.resolve(newFilename);
            Files.copy(avatarFile.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Update user avatar path
            String avatarPath = "/images/avatars/" + newFilename;
            user.setHinhDaiDien(avatarPath);
            userService.save(user);
            
            return ResponseEntity.ok(Map.of(
                "success", true, 
                "message", "Cập nhật avatar thành công",
                "avatarPath", avatarPath
            ));
        } catch (IOException e) {
            log.error("Error saving avatar file", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Lỗi khi lưu file ảnh"));
        } catch (Exception e) {
            log.error("Error updating avatar", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * API: Xóa tài khoản
     */
    @DeleteMapping("/api/delete-account")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteAccount(
            @RequestParam String password,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            
            // Verify password
            if (!passwordEncoder.matches(password, user.getMatKhau())) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Mật khẩu không đúng"));
            }
            
            // Deactivate account instead of deleting
            user.setHoatDong(false);
            userService.save(user);
            
            return ResponseEntity.ok(Map.of("success", true, "message", "Tài khoản đã được vô hiệu hóa"));
        } catch (Exception e) {
            log.error("Error deleting account", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
    
    private void addUserAttributesToModel(Model model, User user) {
        if (user != null) {
            model.addAttribute("user", user);
            
            // Add role information
            if (user.getVaiTro() != null) {
                String roleName = user.getVaiTro().getTenVaiTro();
                model.addAttribute("userRole", roleName);
                
                boolean isAdmin = "ADMIN".equalsIgnoreCase(roleName);
                boolean isStaff = "STAFF".equalsIgnoreCase(roleName);
                
                model.addAttribute("isAdmin", isAdmin);
                model.addAttribute("isStaff", isStaff);
            }
        }
    }
}
