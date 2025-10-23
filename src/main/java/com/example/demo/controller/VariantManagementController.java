package com.example.demo.controller;

import com.example.demo.dto.BulkCreateVariantsRequest;
import com.example.demo.dto.VariantCreateRequest;
import com.example.demo.dto.VariantUpdateRequest;
import com.example.demo.dto.VariantResponse;
import com.example.demo.service.ProductManagementService;
import com.example.demo.service.VariantManagementService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.DefaultCsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/product/{productId}/variants")
@RequiredArgsConstructor
@Slf4j
public class VariantManagementController {
    
    private final VariantManagementService variantService;
    private final ProductManagementService productService;
    
    /**
     * Trang quản lý biến thể của sản phẩm
     */
    @GetMapping
    public String index(@PathVariable Long productId, Model model, HttpServletRequest request) {
        try {
            // Load product info
            var product = productService.getProductById(productId);
            model.addAttribute("product", product);
            
            // Load variants
            List<VariantResponse> variants = variantService.getVariantsByProductId(productId);
            model.addAttribute("variants", variants);
            
            // Load statistics
            var stats = variantService.getVariantStatistics(productId);
            model.addAttribute("stats", stats);
            
            // Load available options
            List<String> colors = variantService.getAvailableColors(productId);
            List<String> sizes = variantService.getAvailableSizes(productId);
            model.addAttribute("availableColors", colors);
            model.addAttribute("availableSizes", sizes);
            
            // CSRF token
            addCsrfToModel(model, request);
            
            return "admin/variant-management/index";
        } catch (Exception e) {
            log.error("Error loading variant management page", e);
            return "redirect:/admin/product-management?error=notfound";
        }
    }
    
    /**
     * API: Lấy danh sách biến thể
     */
    @GetMapping("/api/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getVariants(@PathVariable Long productId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<VariantResponse> variants = variantService.getVariantsByProductId(productId);
            
            response.put("success", true);
            response.put("data", variants);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting variants", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Lấy chi tiết một biến thể
     */
    @GetMapping("/api/{variantId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getVariantDetail(
            @PathVariable Long productId,
            @PathVariable Long variantId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            VariantResponse variant = variantService.getVariantById(variantId);
            
            response.put("success", true);
            response.put("data", variant);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting variant detail", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Tạo biến thể mới
     */
    @PostMapping("/api/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createVariant(
            @PathVariable Long productId,
            @Valid @RequestBody VariantCreateRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            VariantResponse created = variantService.createVariant(productId, request);
            
            response.put("success", true);
            response.put("message", "Tạo biến thể thành công!");
            response.put("data", created);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error creating variant", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Cập nhật biến thể
     */
    @PutMapping("/api/{variantId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateVariant(
            @PathVariable Long productId,
            @PathVariable Long variantId,
            @Valid @RequestBody VariantUpdateRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            VariantResponse updated = variantService.updateVariant(variantId, request);
            
            response.put("success", true);
            response.put("message", "Cập nhật biến thể thành công!");
            response.put("data", updated);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error updating variant", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Xóa biến thể
     */
    @DeleteMapping("/api/{variantId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteVariant(
            @PathVariable Long productId,
            @PathVariable Long variantId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            variantService.deleteVariant(variantId);
            
            response.put("success", true);
            response.put("message", "Xóa biến thể thành công!");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error deleting variant", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Toggle hiển thị biến thể
     */
    @PostMapping("/api/{variantId}/toggle-visibility")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleVisibility(
            @PathVariable Long productId,
            @PathVariable Long variantId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            variantService.toggleVisibility(variantId);
            
            response.put("success", true);
            response.put("message", "Cập nhật trạng thái thành công!");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error toggling visibility", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Lấy màu sắc có sẵn
     */
    @GetMapping("/api/colors")
    @ResponseBody
    public ResponseEntity<List<String>> getAvailableColors(@PathVariable Long productId) {
        try {
            List<String> colors = variantService.getAvailableColors(productId);
            return ResponseEntity.ok(colors);
        } catch (Exception e) {
            log.error("Error getting colors", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * API: Lấy kích cỡ có sẵn
     */
    @GetMapping("/api/sizes")
    @ResponseBody
    public ResponseEntity<List<String>> getAvailableSizes(@PathVariable Long productId) {
        try {
            List<String> sizes = variantService.getAvailableSizes(productId);
            return ResponseEntity.ok(sizes);
        } catch (Exception e) {
            log.error("Error getting sizes", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * API: Tạo hàng loạt variants
     */
    @PostMapping("/api/bulk-create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bulkCreateVariants(
            @PathVariable Long productId,
            @Valid @RequestBody BulkCreateVariantsRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            VariantManagementService.BulkCreateResult result = variantService.bulkCreateVariants(productId, request);
            
            String message = String.format("Tạo thành công %d biến thể", result.getCreated().size());
            if (!result.getSkipped().isEmpty()) {
                message += String.format(", bỏ qua %d biến thể đã tồn tại", result.getSkipped().size());
            }
            if (!result.getErrors().isEmpty()) {
                message += String.format(", %d lỗi", result.getErrors().size());
            }
            
            response.put("success", true);
            response.put("message", message);
            response.put("created", result.getCreated());
            response.put("skipped", result.getSkipped());
            response.put("errors", result.getErrors());
            response.put("totalCreated", result.getCreated().size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error bulk creating variants", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    // ========== HELPER METHOD ==========
    
    private void addCsrfToModel(Model model, HttpServletRequest request) {
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
    }
}

