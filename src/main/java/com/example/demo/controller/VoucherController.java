package com.example.demo.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/voucher")
@RequiredArgsConstructor
@Slf4j
public class VoucherController {

    /**
     * Áp dụng mã giảm giá
     */
    @PostMapping("/apply")
    public ResponseEntity<Map<String, Object>> applyVoucher(
            @RequestParam String code,
            Authentication authentication) {
        
        try {
            log.info("Applying voucher code: {}", code);
            
            // Validate voucher code (placeholder logic)
            if (code == null || code.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Vui lòng nhập mã giảm giá"
                ));
            }
            
            // Mock voucher validation (in production, check database)
            Map<String, Object> voucherData = validateVoucherCode(code.trim().toUpperCase());
            
            if (voucherData == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Mã giảm giá không hợp lệ hoặc đã hết hạn"
                ));
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Áp dụng mã giảm giá thành công");
            response.put("voucher", voucherData);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error applying voucher", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi áp dụng mã giảm giá: " + e.getMessage()
            ));
        }
    }

    /**
     * Xóa mã giảm giá
     */
    @DeleteMapping("/remove")
    public ResponseEntity<Map<String, Object>> removeVoucher(
            @RequestParam String code,
            Authentication authentication) {
        
        try {
            log.info("Removing voucher code: {}", code);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã xóa mã giảm giá");
            response.put("code", code);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error removing voucher", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi xóa mã giảm giá: " + e.getMessage()
            ));
        }
    }

    /**
     * Validate voucher code (mock implementation)
     */
    private Map<String, Object> validateVoucherCode(String code) {
        // Mock voucher data (in production, query database)
        Map<String, Map<String, Object>> mockVouchers = new HashMap<>();
        
        // Sample vouchers
        Map<String, Object> voucher1 = new HashMap<>();
        voucher1.put("code", "WELCOME10");
        voucher1.put("type", "PERCENTAGE");
        voucher1.put("discount", BigDecimal.valueOf(10)); // 10%
        voucher1.put("minOrderAmount", BigDecimal.valueOf(100000)); // Min 100k
        voucher1.put("maxDiscount", BigDecimal.valueOf(50000)); // Max 50k discount
        voucher1.put("description", "Giảm 10% cho đơn hàng từ 100k");
        mockVouchers.put("WELCOME10", voucher1);
        
        Map<String, Object> voucher2 = new HashMap<>();
        voucher2.put("code", "FREESHIP");
        voucher2.put("type", "FIXED");
        voucher2.put("discount", BigDecimal.valueOf(30000)); // 30k
        voucher2.put("minOrderAmount", BigDecimal.valueOf(200000)); // Min 200k
        voucher2.put("maxDiscount", BigDecimal.valueOf(30000));
        voucher2.put("description", "Miễn phí vận chuyển cho đơn từ 200k");
        mockVouchers.put("FREESHIP", voucher2);
        
        Map<String, Object> voucher3 = new HashMap<>();
        voucher3.put("code", "SAVE50K");
        voucher3.put("type", "FIXED");
        voucher3.put("discount", BigDecimal.valueOf(50000)); // 50k
        voucher3.put("minOrderAmount", BigDecimal.valueOf(500000)); // Min 500k
        voucher3.put("maxDiscount", BigDecimal.valueOf(50000));
        voucher3.put("description", "Giảm 50k cho đơn hàng từ 500k");
        mockVouchers.put("SAVE50K", voucher3);
        
        return mockVouchers.get(code);
    }
}
