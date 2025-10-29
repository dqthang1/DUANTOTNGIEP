package com.example.demo.controller;

import com.example.demo.service.KhuyenMaiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/promotions")
@RequiredArgsConstructor
@Slf4j
public class PromotionController {
    
    // private final KhuyenMaiService khuyenMaiService; // Will be used when implementing featured promotions
    
    /**
     * Lấy khuyến mãi nổi bật
     */
    @GetMapping("/featured")
    public ResponseEntity<Map<String, Object>> getFeaturedPromotion() {
        try {
            // For now, return a simple response indicating no featured promotion
            // You can implement this method in KhuyenMaiService if needed
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Không có khuyến mãi nổi bật");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting featured promotion", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải khuyến mãi nổi bật"
            ));
        }
    }
}
