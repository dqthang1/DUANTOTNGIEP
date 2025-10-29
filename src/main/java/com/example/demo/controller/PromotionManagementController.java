package com.example.demo.controller;

import com.example.demo.dto.KhuyenMaiCreateRequest;
import com.example.demo.dto.KhuyenMaiResponse;
import com.example.demo.entity.Product;
import com.example.demo.service.KhuyenMaiService;
import com.example.demo.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.DefaultCsrfToken;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/promotion-management")
@RequiredArgsConstructor
@Slf4j
public class PromotionManagementController {
    
    private final KhuyenMaiService khuyenMaiService;
    private final ProductService productService;
    
    /**
     * Trang chủ quản lý khuyến mãi
     */
    @GetMapping
    public String index(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "10") int size,
                       @RequestParam(defaultValue = "id") String sortBy,
                       @RequestParam(defaultValue = "desc") String sortDir,
                       @RequestParam(required = false) String keyword,
                       @RequestParam(required = false) Boolean status,
                       @RequestParam(required = false) String loai,
                       Model model,
                       HttpServletRequest request) {
        
        // Xử lý empty parameters
        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<KhuyenMaiResponse> promotions = khuyenMaiService.searchPromotions(
            keyword, status, loai, pageable);
        
        model.addAttribute("promotions", promotions);
        model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
        
        // Giữ lại filter parameters
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", promotions.getTotalPages());
        model.addAttribute("keyword", keyword);
        model.addAttribute("status", status);
        model.addAttribute("loai", loai);
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDir", sortDir);
        
        // Thêm CSRF token
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
        
        return "admin/promotion-management/index";
    }
    
    /**
     * Form tạo khuyến mãi mới
     */
    @GetMapping("/create")
    public String createForm(Model model, HttpServletRequest request) {
        KhuyenMaiCreateRequest promotion = new KhuyenMaiCreateRequest();
        
        model.addAttribute("promotion", promotion);
        model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
        model.addAttribute("products", productService.getAllActiveProducts());
        
        // Thêm CSRF token
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
        
        return "admin/promotion-management/create";
    }
    
    /**
     * Xử lý tạo khuyến mãi mới
     */
    @PostMapping("/create")
    public String create(@Valid @ModelAttribute("promotion") KhuyenMaiCreateRequest request,
                        BindingResult bindingResult,
                        RedirectAttributes redirectAttributes,
                        Model model) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
            model.addAttribute("products", productService.getAllActiveProducts());
            return "admin/promotion-management/create";
        }
        
        try {
            KhuyenMaiResponse createdPromotion = khuyenMaiService.createPromotion(request);
            redirectAttributes.addFlashAttribute("success", "Tạo khuyến mãi thành công!");
            return "redirect:/admin/promotion-management";
        } catch (Exception e) {
            log.error("Error creating promotion", e);
            model.addAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
            model.addAttribute("products", productService.getAllActiveProducts());
            return "admin/promotion-management/create";
        }
    }
    
    /**
     * Form chỉnh sửa khuyến mãi
     */
    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpServletRequest request) {
        try {
            KhuyenMaiResponse promotion = khuyenMaiService.getPromotionById(id);
            KhuyenMaiCreateRequest updateRequest = new KhuyenMaiCreateRequest();
            
            // Map KhuyenMaiResponse to KhuyenMaiCreateRequest
            updateRequest.setTen(promotion.getTen());
            updateRequest.setMoTa(promotion.getMoTa());
            updateRequest.setLoai(promotion.getLoai());
            updateRequest.setGiaTri(promotion.getGiaTri());
            updateRequest.setNgayBatDau(promotion.getNgayBatDau());
            updateRequest.setNgayKetThuc(promotion.getNgayKetThuc());
            updateRequest.setSoLuongSuDung(promotion.getSoLuongSuDung());
            updateRequest.setSoLuongToiDa(promotion.getSoLuongToiDa());
            updateRequest.setHoatDong(promotion.getHoatDong());
            // Không cần setMaKhuyenMai vì không có trong entity mới
            
            // Map product IDs
            if (promotion.getSanPhams() != null) {
                updateRequest.setSanPhamIds(promotion.getSanPhams().stream()
                    .map(KhuyenMaiResponse.ProductSummaryDto::getId)
                    .collect(java.util.stream.Collectors.toList()));
            }
            
            model.addAttribute("promotion", updateRequest);
            model.addAttribute("promotionId", id);
            model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
            model.addAttribute("products", productService.getAllActiveProducts());
            
            // Thêm CSRF token
            CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
            if (csrfToken != null) {
                model.addAttribute("_csrf", csrfToken);
            }
            
            return "admin/promotion-management/edit";
        } catch (Exception e) {
            log.error("Error getting promotion for edit", e);
            return "redirect:/admin/promotion-management?error=notfound";
        }
    }
    
    /**
     * Xử lý cập nhật khuyến mãi
     */
    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                        @Valid @ModelAttribute("promotion") KhuyenMaiCreateRequest request,
                        BindingResult bindingResult,
                        RedirectAttributes redirectAttributes,
                        Model model) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("promotionId", id);
            model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
            model.addAttribute("products", productService.getAllActiveProducts());
            return "admin/promotion-management/edit";
        }
        
        try {
            KhuyenMaiResponse updatedPromotion = khuyenMaiService.updatePromotion(id, request);
            redirectAttributes.addFlashAttribute("success", "Cập nhật khuyến mãi thành công!");
            return "redirect:/admin/promotion-management";
        } catch (Exception e) {
            log.error("Error updating promotion", e);
            model.addAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            model.addAttribute("promotionId", id);
            model.addAttribute("promotionTypes", List.of("PHAN_TRAM", "SO_TIEN", "FREE_SHIP", "TANG_KEM"));
            model.addAttribute("products", productService.getAllActiveProducts());
            return "admin/promotion-management/edit";
        }
    }
    
    /**
     * Xem chi tiết khuyến mãi
     */
    @GetMapping("/{id}")
    public String view(@PathVariable Long id, Model model) {
        try {
            KhuyenMaiResponse promotion = khuyenMaiService.getPromotionById(id);
            model.addAttribute("promotion", promotion);
            return "admin/promotion-management/view";
        } catch (Exception e) {
            log.error("Error getting promotion", e);
            return "redirect:/admin/promotion-management?error=notfound";
        }
    }
    
    /**
     * Xóa khuyến mãi
     */
    @PostMapping("/{id}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            khuyenMaiService.deletePromotion(id);
            response.put("success", true);
            response.put("message", "Xóa khuyến mãi thành công!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error deleting promotion", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Toggle trạng thái khuyến mãi
     */
    @PostMapping("/{id}/toggle-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleStatus(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            khuyenMaiService.togglePromotionStatus(id);
            response.put("success", true);
            response.put("message", "Cập nhật trạng thái thành công!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error toggling promotion status", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API lấy khuyến mãi áp dụng cho sản phẩm
     */
    @GetMapping("/api/applicable/{productId}")
    @ResponseBody
    public ResponseEntity<List<KhuyenMaiResponse>> getApplicablePromotions(@PathVariable Long productId) {
        try {
            Product product = productService.getProductById(productId);
            List<KhuyenMaiResponse> promotions = khuyenMaiService.getApplicablePromotions(product);
            return ResponseEntity.ok(promotions);
        } catch (Exception e) {
            log.error("Error getting applicable promotions", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
}
