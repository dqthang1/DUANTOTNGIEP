package com.example.demo.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/newsletter")
@RequiredArgsConstructor
@Slf4j
public class NewsletterController {
    
    /**
     * Đăng ký nhận newsletter
     */
    @PostMapping("/subscribe")
    public ResponseEntity<Map<String, Object>> subscribeNewsletter(
            @RequestBody Map<String, Object> request) {
        
        try {
            String email = request.get("email").toString();
            
            // TODO: Implement actual newsletter subscription logic
            // For now, just log the email and return success
            log.info("Newsletter subscription request for email: {}", email);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đăng ký thành công! Kiểm tra email để nhận mã giảm giá.");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error subscribing to newsletter", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Đăng ký thất bại"));
        }
    }
}
