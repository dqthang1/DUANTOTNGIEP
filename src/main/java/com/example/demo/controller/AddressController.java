package com.example.demo.controller;

import com.example.demo.dto.AddressDTO;
import com.example.demo.entity.DiaChi;
import com.example.demo.entity.User;
import com.example.demo.repository.DiaChiRepository;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/addresses")
@RequiredArgsConstructor
@Slf4j
public class AddressController {
    
    private final DiaChiRepository diaChiRepository;
    private final UserService userService;
    
    /**
     * Lấy danh sách địa chỉ của người dùng
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserAddresses(Authentication authentication) {
        try {
            // Check authentication
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of(
                    "success", false, 
                    "message", "Vui lòng đăng nhập để xem địa chỉ"
                ));
            }
            
            User user = getCurrentUser(authentication);
            // Fix: Use correct repository method
            List<DiaChi> addresses = diaChiRepository.findByNguoiDungId(user.getId());
            
            // Convert to DTOs to avoid serialization issues
            List<AddressDTO> addressDTOs = addresses.stream()
                    .map(AddressDTO::fromEntity)
                    .collect(Collectors.toList());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("addresses", addressDTOs);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting user addresses", e);
            return ResponseEntity.status(500).body(Map.of(
                "success", false, 
                "message", "Lỗi server: " + e.getMessage()
            ));
        }
    }
    
    /**
     * Lấy địa chỉ mặc định của người dùng
     */
    @GetMapping("/default")
    public ResponseEntity<Map<String, Object>> getDefaultAddress(Authentication authentication) {
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of(
                    "success", false, 
                    "message", "Vui lòng đăng nhập"
                ));
            }
            
            User user = getCurrentUser(authentication);
            var defaultAddress = diaChiRepository.findDefaultByUserId(user.getId());
            
            // Convert to DTO
            AddressDTO addressDTO = defaultAddress.map(AddressDTO::fromEntity).orElse(null);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("address", addressDTO);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting default address", e);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Thêm địa chỉ mới
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> addAddress(
            @RequestParam String hoTenNhan,
            @RequestParam String soDienThoai,
            @RequestParam String diaChi,
            @RequestParam String quanHuyen,
            @RequestParam String tinhThanh,
            @RequestParam(required = false) String phuongXa,
            @RequestParam(defaultValue = "false") boolean macDinh,
            Authentication authentication) {
        try {
            log.info("Adding address for user: {}", authentication != null ? authentication.getName() : "null");
            
            if (authentication == null || !authentication.isAuthenticated()) {
                log.warn("Unauthenticated request to add address");
                return ResponseEntity.status(401).body(Map.of(
                    "success", false, 
                    "message", "Vui lòng đăng nhập để thêm địa chỉ"
                ));
            }
            
            User user = getCurrentUser(authentication);
            log.info("Found user: {} with ID: {}", user.getEmail(), user.getId());
            
            // Validate phone number format
            if (!isValidPhoneNumber(soDienThoai)) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false, 
                    "message", "Số điện thoại không hợp lệ. Vui lòng nhập số điện thoại từ 8-20 ký tự, bắt đầu bằng số hoặc dấu +, chỉ chứa số và dấu +"
                ));
            }
            
            // Nếu đặt làm mặc định, bỏ mặc định của các địa chỉ khác
            if (macDinh) {
                List<DiaChi> existingAddresses = diaChiRepository.findByNguoiDungId(user.getId());
                for (DiaChi existingAddress : existingAddresses) {
                    if (existingAddress.getLaDiaChiMacDinh()) {
                        existingAddress.setLaDiaChiMacDinh(false);
                        diaChiRepository.save(existingAddress);
                    }
                }
            }
            
            // Tạo địa chỉ mới
            log.info("Creating new address with data: hoTenNhan={}, soDienThoai={}, diaChi={}, quanHuyen={}, tinhThanh={}, phuongXa={}, macDinh={}", 
                hoTenNhan, soDienThoai, diaChi, quanHuyen, tinhThanh, phuongXa, macDinh);
            
            DiaChi newAddress = new DiaChi();
            newAddress.setNguoiDung(user);
            newAddress.setTenNguoiNhan(hoTenNhan);
            newAddress.setSoDienThoai(soDienThoai);
            newAddress.setDiaChiChiTiet(diaChi);
            newAddress.setQuanHuyen(quanHuyen);
            newAddress.setTinhThanh(tinhThanh);
            newAddress.setPhuongXa(phuongXa != null ? phuongXa : "");
            newAddress.setLaDiaChiMacDinh(macDinh);
            
            DiaChi savedAddress = diaChiRepository.save(newAddress);
            log.info("Address saved successfully with ID: {}", savedAddress.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Địa chỉ đã được thêm thành công");
            response.put("address", AddressDTO.fromEntity(savedAddress));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error adding address", e);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Cập nhật địa chỉ
     */
    @PutMapping("/{addressId}")
    public ResponseEntity<Map<String, Object>> updateAddress(
            @PathVariable Long addressId,
            @RequestParam String hoTenNhan,
            @RequestParam String soDienThoai,
            @RequestParam String diaChi,
            @RequestParam String quanHuyen,
            @RequestParam String tinhThanh,
            @RequestParam(required = false) String phuongXa,
            @RequestParam(defaultValue = "false") boolean macDinh,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            
            // Validate phone number format
            if (!isValidPhoneNumber(soDienThoai)) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false, 
                    "message", "Số điện thoại không hợp lệ. Vui lòng nhập số điện thoại từ 8-20 ký tự, bắt đầu bằng số hoặc dấu +, chỉ chứa số và dấu +"
                ));
            }
            
            DiaChi existingAddress = diaChiRepository.findById(addressId)
                    .orElseThrow(() -> new RuntimeException("Address not found"));
            
            // Kiểm tra quyền sở hữu
            if (!existingAddress.getNguoiDung().getId().equals(user.getId())) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "Không có quyền truy cập"));
            }
            
            // Nếu đặt làm mặc định, bỏ mặc định của các địa chỉ khác
            if (macDinh) {
                List<DiaChi> userAddresses = diaChiRepository.findByNguoiDungId(user.getId());
                for (DiaChi address : userAddresses) {
                    if (address.getLaDiaChiMacDinh() && !address.getId().equals(addressId)) {
                        address.setLaDiaChiMacDinh(false);
                        diaChiRepository.save(address);
                    }
                }
            }
            
            // Cập nhật thông tin
            existingAddress.setTenNguoiNhan(hoTenNhan);
            existingAddress.setSoDienThoai(soDienThoai);
            existingAddress.setDiaChiChiTiet(diaChi);
            existingAddress.setQuanHuyen(quanHuyen);
            existingAddress.setTinhThanh(tinhThanh);
            existingAddress.setPhuongXa(phuongXa != null ? phuongXa : "");
            existingAddress.setLaDiaChiMacDinh(macDinh);
            
            DiaChi updatedAddress = diaChiRepository.save(existingAddress);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Địa chỉ đã được cập nhật thành công");
            response.put("address", AddressDTO.fromEntity(updatedAddress));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error updating address", e);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Xóa địa chỉ
     */
    @DeleteMapping("/{addressId}")
    public ResponseEntity<Map<String, Object>> deleteAddress(
            @PathVariable Long addressId,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            
            DiaChi address = diaChiRepository.findById(addressId)
                    .orElseThrow(() -> new RuntimeException("Address not found"));
            
            // Kiểm tra quyền sở hữu
            if (!address.getNguoiDung().getId().equals(user.getId())) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "Không có quyền truy cập"));
            }
            
            diaChiRepository.delete(address);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Địa chỉ đã được xóa thành công");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error deleting address", e);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Đặt địa chỉ làm mặc định
     */
    @PostMapping("/{addressId}/set-default")
    public ResponseEntity<Map<String, Object>> setDefaultAddress(
            @PathVariable Long addressId,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            
            DiaChi address = diaChiRepository.findById(addressId)
                    .orElseThrow(() -> new RuntimeException("Address not found"));
            
            // Kiểm tra quyền sở hữu
            if (!address.getNguoiDung().getId().equals(user.getId())) {
                return ResponseEntity.status(403).body(Map.of("success", false, "message", "Không có quyền truy cập"));
            }
            
            // Bỏ mặc định của các địa chỉ khác
            List<DiaChi> userAddresses = diaChiRepository.findByNguoiDungId(user.getId());
            for (DiaChi userAddress : userAddresses) {
                if (userAddress.getLaDiaChiMacDinh() && !userAddress.getId().equals(addressId)) {
                    userAddress.setLaDiaChiMacDinh(false);
                    diaChiRepository.save(userAddress);
                }
            }
            
            // Đặt địa chỉ này làm mặc định
            address.setLaDiaChiMacDinh(true);
            diaChiRepository.save(address);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Địa chỉ đã được đặt làm mặc định");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error setting default address", e);
            return ResponseEntity.status(500).body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
    
    /**
     * Validate phone number format according to database constraints
     * - Length between 8 and 20 characters
     * - Must start with + or digit
     * - Must only contain digits and + signs
     */
    private boolean isValidPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            return false;
        }
        
        String trimmed = phoneNumber.trim();
        
        // Check length
        if (trimmed.length() < 8 || trimmed.length() > 20) {
            return false;
        }
        
        // Check if starts with + or digit
        if (!trimmed.matches("^[+0-9].*")) {
            return false;
        }
        
        // Check if only contains digits and + signs
        if (!trimmed.matches("^[0-9+]+$")) {
            return false;
        }
        
        return true;
    }
}
