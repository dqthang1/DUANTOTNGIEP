package com.example.demo.controller;

import com.example.demo.dto.ProductResponse;
import com.example.demo.entity.SanPhamLienQuan;
import com.example.demo.service.SanPhamLienQuanService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.DefaultCsrfToken;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/related-products")
@RequiredArgsConstructor
@Slf4j
public class RelatedProductController {
    
    private final SanPhamLienQuanService sanPhamLienQuanService;
    
    /**
     * Trang chủ quản lý sản phẩm liên quan
     */
    @GetMapping
    public String index(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "10") int size,
                       @RequestParam(required = false) Long sanPhamGocId,
                       @RequestParam(required = false) String loai,
                       Model model,
                       HttpServletRequest request) {
        
        Pageable pageable = PageRequest.of(page, size);
        Page<SanPhamLienQuan> relations = sanPhamLienQuanService.searchRelations(
            sanPhamGocId, loai, pageable);
        
        model.addAttribute("relations", relations);
        model.addAttribute("relationTypes", List.of("CUNG_DANH_MUC", "CUNG_THUONG_HIEU", "CUNG_MON_THE_THAO", "KHUYEN_NGHI", "THAY_THE", "PHU_HOP", "TUONG_TU", "MANUAL"));
        
        // Giữ lại filter parameters
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", relations.getTotalPages());
        model.addAttribute("sanPhamGocId", sanPhamGocId);
        model.addAttribute("loai", loai);
        
        // Thêm CSRF token
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
        
        return "admin/related-products/index";
    }
    
    /**
     * Form tạo sản phẩm liên quan thủ công
     */
    @GetMapping("/create")
    public String createForm(Model model, HttpServletRequest request) {
        model.addAttribute("relationTypes", List.of("CUNG_DANH_MUC", "CUNG_THUONG_HIEU", "CUNG_MON_THE_THAO", "KHUYEN_NGHI", "THAY_THE", "PHU_HOP", "TUONG_TU", "MANUAL"));
        
        // Thêm CSRF token
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
        
        return "admin/related-products/create";
    }
    
    /**
     * Xử lý tạo sản phẩm liên quan
     */
    @PostMapping("/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> create(
            @RequestParam Long sanPhamGocId,
            @RequestParam Long sanPhamLienQuanId,
            @RequestParam String loai,
            @RequestParam(required = false) Integer thuTu,
            @RequestParam(required = false) String ghiChu) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            SanPhamLienQuan relation = sanPhamLienQuanService.createManualRelation(
                sanPhamGocId, sanPhamLienQuanId, loai, thuTu, ghiChu);
            
            response.put("success", true);
            response.put("message", "Tạo sản phẩm liên quan thành công!");
            response.put("relation", relation);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error creating related product", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Tự động tạo sản phẩm liên quan
     */
    @PostMapping("/{productId}/generate")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> generateRelatedProducts(@PathVariable Long productId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            sanPhamLienQuanService.generateRelatedProducts(productId);
            
            response.put("success", true);
            response.put("message", "Tạo sản phẩm liên quan tự động thành công!");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error generating related products", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Xóa sản phẩm liên quan
     */
    @PostMapping("/{id}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            sanPhamLienQuanService.deleteRelation(id);
            response.put("success", true);
            response.put("message", "Xóa sản phẩm liên quan thành công!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error deleting related product", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Xóa sản phẩm liên quan
     */
    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteRelation(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            sanPhamLienQuanService.deleteRelation(id);
            response.put("success", true);
            response.put("message", "Xóa sản phẩm liên quan thành công!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error deleting related product", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API lấy sản phẩm liên quan cho frontend
     */
    @GetMapping("/api/related/{productId}")
    @ResponseBody
    public ResponseEntity<List<ProductResponse>> getRelatedProducts(@PathVariable Long productId,
                                                                   @RequestParam(defaultValue = "8") int limit) {
        try {
            List<ProductResponse> relatedProducts = sanPhamLienQuanService.getRelatedProducts(productId, limit);
            return ResponseEntity.ok(relatedProducts);
        } catch (Exception e) {
            log.error("Error getting related products", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * API lấy sản phẩm liên quan theo loại
     */
    @GetMapping("/api/related/{productId}/by-type")
    @ResponseBody
    public ResponseEntity<List<ProductResponse>> getRelatedProductsByType(
            @PathVariable Long productId,
            @RequestParam String loai,
            @RequestParam(defaultValue = "4") int limit) {
        try {
            List<ProductResponse> relatedProducts = sanPhamLienQuanService.getRelatedProductsByType(
                productId, loai, limit);
            return ResponseEntity.ok(relatedProducts);
        } catch (Exception e) {
            log.error("Error getting related products by type", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
}
