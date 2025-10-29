package com.example.demo.controller;

import com.example.demo.entity.DiaChi;
import com.example.demo.repository.DiaChiRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/api/shipping")
@RequiredArgsConstructor
@Slf4j
public class ShippingController {

    private final DiaChiRepository diaChiRepository;

    /**
     * Tính phí vận chuyển dựa trên địa chỉ và tổng tiền đơn hàng
     */
    @GetMapping("/calculate")
    public ResponseEntity<Map<String, Object>> calculateShipping(
            @RequestParam Long addressId,
            @RequestParam Long totalAmount,
            Authentication authentication) {
        
        try {
            log.info("Calculating shipping for address ID: {}, total amount: {}", addressId, totalAmount);
            
            // Lấy thông tin địa chỉ
            Optional<DiaChi> addressOpt = diaChiRepository.findById(addressId);
            if (addressOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Không tìm thấy địa chỉ"
                ));
            }
            
            DiaChi address = addressOpt.get();
            String province = address.getTinhThanh();
            
            // Tính phí vận chuyển
            BigDecimal shippingFee = calculateShippingFee(totalAmount, province);
            
            // Lấy danh sách phương thức vận chuyển
            List<Map<String, Object>> methods = getShippingMethods(totalAmount, province);
            
            // Tính thời gian giao hàng dự kiến
            String eta = calculateETA(province);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("shippingFee", shippingFee);
            response.put("methods", methods);
            response.put("eta", eta);
            response.put("province", province);
            
            log.info("Shipping calculated: fee={}, methods={}, eta={}", 
                shippingFee, methods.size(), eta);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error calculating shipping", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi tính phí vận chuyển: " + e.getMessage()
            ));
        }
    }

    /**
     * Lấy danh sách phương thức vận chuyển
     */
    @GetMapping("/methods")
    public ResponseEntity<Map<String, Object>> getShippingMethods(
            @RequestParam Long addressId,
            @RequestParam Long totalAmount,
            Authentication authentication) {
        
        try {
            log.info("Getting shipping methods for address ID: {}, total amount: {}", addressId, totalAmount);
            
            // Lấy thông tin địa chỉ
            Optional<DiaChi> addressOpt = diaChiRepository.findById(addressId);
            if (addressOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Không tìm thấy địa chỉ"
                ));
            }
            
            DiaChi address = addressOpt.get();
            String province = address.getTinhThanh();
            
            // Lấy danh sách phương thức vận chuyển
            List<Map<String, Object>> methods = getShippingMethods(totalAmount, province);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("methods", methods);
            response.put("province", province);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error getting shipping methods", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi lấy phương thức vận chuyển: " + e.getMessage()
            ));
        }
    }

    /**
     * Tính phí vận chuyển dựa trên tổng tiền và tỉnh thành
     */
    private BigDecimal calculateShippingFee(Long totalAmount, String province) {
        // Miễn phí vận chuyển cho đơn từ 499k ở HN/HCM
        if (totalAmount >= 499000 && isHanoiOrHCM(province)) {
            return BigDecimal.ZERO;
        }
        
        // Phí vận chuyển mặc định
        return BigDecimal.valueOf(30000);
    }

    /**
     * Kiểm tra có phải Hà Nội hoặc TP.HCM không
     */
    private boolean isHanoiOrHCM(String province) {
        if (province == null) return false;
        
        String provinceLower = province.toLowerCase();
        return provinceLower.contains("hà nội") || 
               provinceLower.contains("hanoi") ||
               provinceLower.contains("thành phố hồ chí minh") ||
               provinceLower.contains("tp.hcm") ||
               provinceLower.contains("ho chi minh");
    }

    /**
     * Lấy danh sách phương thức vận chuyển
     */
    private List<Map<String, Object>> getShippingMethods(Long totalAmount, String province) {
        List<Map<String, Object>> methods = new ArrayList<>();
        
        // Phương thức nhanh
        Map<String, Object> fastMethod = new HashMap<>();
        fastMethod.put("id", "fast");
        fastMethod.put("name", "Giao hàng nhanh");
        fastMethod.put("description", "Giao hàng trong 1-2 ngày làm việc");
        fastMethod.put("eta", "1-2 ngày");
        fastMethod.put("fee", calculateShippingFee(totalAmount, province));
        fastMethod.put("available", true);
        methods.add(fastMethod);
        
        // Phương thức tiết kiệm
        Map<String, Object> standardMethod = new HashMap<>();
        standardMethod.put("id", "standard");
        standardMethod.put("name", "Giao hàng tiết kiệm");
        standardMethod.put("description", "Giao hàng trong 3-5 ngày làm việc");
        standardMethod.put("eta", "3-5 ngày");
        standardMethod.put("fee", calculateShippingFee(totalAmount, province));
        standardMethod.put("available", true);
        methods.add(standardMethod);
        
        // Phương thức hẹn giờ (chỉ cho HN/HCM)
        if (isHanoiOrHCM(province)) {
            Map<String, Object> scheduledMethod = new HashMap<>();
            scheduledMethod.put("id", "scheduled");
            scheduledMethod.put("name", "Giao hàng hẹn giờ");
            scheduledMethod.put("description", "Giao hàng theo khung giờ đã hẹn");
            scheduledMethod.put("eta", "Theo lịch hẹn");
            scheduledMethod.put("fee", calculateShippingFee(totalAmount, province));
            scheduledMethod.put("available", true);
            methods.add(scheduledMethod);
        }
        
        return methods;
    }

    /**
     * Tính thời gian giao hàng dự kiến
     */
    private String calculateETA(String province) {
        if (isHanoiOrHCM(province)) {
            return "1-2 ngày làm việc";
        } else {
            return "3-5 ngày làm việc";
        }
    }

    /**
     * Kiểm tra khu vực có được phục vụ không
     */
    @GetMapping("/check-coverage")
    public ResponseEntity<Map<String, Object>> checkCoverage(
            @RequestParam String province,
            @RequestParam(required = false) String district) {
        
        try {
            log.info("Checking shipping coverage for: {}, {}", province, district);
            
            // Danh sách khu vực không phục vụ (có thể mở rộng)
            Set<String> unsupportedAreas = Set.of(
                "đảo phú quốc",
                "côn đảo",
                "đảo lý sơn"
            );
            
            boolean isSupported = true;
            String reason = null;
            
            if (province != null) {
                String provinceLower = province.toLowerCase();
                for (String unsupported : unsupportedAreas) {
                    if (provinceLower.contains(unsupported)) {
                        isSupported = false;
                        reason = "Khu vực này hiện chưa được phục vụ giao hàng";
                        break;
                    }
                }
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("supported", isSupported);
            response.put("reason", reason);
            response.put("province", province);
            response.put("district", district);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error checking shipping coverage", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi kiểm tra khu vực: " + e.getMessage()
            ));
        }
    }
}
