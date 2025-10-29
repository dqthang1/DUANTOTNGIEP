package com.example.demo.controller;

import com.example.demo.service.DanhMucService;
import com.example.demo.service.ThuongHieuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/home")
@RequiredArgsConstructor
@Slf4j
public class HomeController {
    
    private final DanhMucService danhMucService;
    private final ThuongHieuService thuongHieuService;
    
    /**
     * Lấy danh sách danh mục nhanh cho trang chủ
     */
    @GetMapping("/quick-categories")
    public ResponseEntity<Map<String, Object>> getQuickCategories() {
        try {
            List<?> categories = danhMucService.getAllActiveCategories();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("categories", categories);
            response.put("total", categories.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting quick categories", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy danh sách thương hiệu cho trang chủ
     */
    @GetMapping("/brands")
    public ResponseEntity<Map<String, Object>> getBrands() {
        try {
            List<?> brands = thuongHieuService.getAllActiveBrands();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("brands", brands);
            response.put("total", brands.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting brands", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy thống kê tổng quan cho trang chủ
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getHomeStats() {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("stats", Map.of(
                "totalCategories", danhMucService.countActiveCategories(),
                "totalBrands", thuongHieuService.countActiveBrands()
            ));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting home stats", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}