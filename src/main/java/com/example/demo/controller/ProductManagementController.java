package com.example.demo.controller;

import com.example.demo.dto.ProductCreateRequest;
import com.example.demo.dto.ProductUpdateRequest;
import com.example.demo.dto.ProductResponse;
import com.example.demo.service.ProductManagementService;
import com.example.demo.service.DanhMucService;
import com.example.demo.service.ThuongHieuService;
import com.example.demo.service.DanhMucMonTheThaoService;
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
@RequestMapping("/admin/product-management")
@RequiredArgsConstructor
@Slf4j
public class ProductManagementController {
    
    private final ProductManagementService productManagementService;
    private final DanhMucService danhMucService;
    private final ThuongHieuService thuongHieuService;
    private final DanhMucMonTheThaoService danhMucMonTheThaoService;
    
    /**
     * Trang chủ quản lý sản phẩm
     */
    @GetMapping
    public String index(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "10") int size,
                       @RequestParam(defaultValue = "id") String sortBy,
                       @RequestParam(defaultValue = "desc") String sortDir,
                       @RequestParam(required = false) String keyword,
                       @RequestParam(required = false) Long categoryId,
                       @RequestParam(required = false) Long brandId,
                       @RequestParam(required = false) Long sportId,
                       @RequestParam(required = false) String status,
                       Model model,
                       HttpServletRequest request) {
        
        // Xử lý empty parameters
        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        if (status != null && status.trim().isEmpty()) {
            status = null;
        }
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<ProductResponse> products = productManagementService.searchProducts(
            keyword, categoryId, brandId, sportId, status, pageable);
        
        // Lấy dữ liệu cho filter với cache
        model.addAttribute("products", products);
        model.addAttribute("categories", productManagementService.getCachedCategories());
        model.addAttribute("brands", productManagementService.getCachedBrands());
        model.addAttribute("sports", productManagementService.getCachedSports());
        
        // Giữ lại filter parameters
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("keyword", keyword);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("brandId", brandId);
        model.addAttribute("sportId", sportId);
        model.addAttribute("status", status);
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDir", sortDir);
        
        // Thêm CSRF token
        addCsrfToModel(model, request);
        
        return "admin/product-management/index";
    }
    
    /**
     * Form tạo sản phẩm mới
     */
    @GetMapping("/create")
    public String createForm(Model model, HttpServletRequest request) {
        ProductCreateRequest product = new ProductCreateRequest();
        
        model.addAttribute("product", product);
        addFilterDataToModel(model);
        addCsrfToModel(model, request);
        
        return "admin/product-management/create";
    }
    
    /**
     * Xử lý tạo sản phẩm mới
     */
    @PostMapping("/create")
    public String create(@Valid @ModelAttribute("product") ProductCreateRequest request,
                        BindingResult bindingResult,
                        RedirectAttributes redirectAttributes,
                        Model model) {
        
        if (bindingResult.hasErrors()) {
            addFilterDataToModel(model);
            return "admin/product-management/create";
        }
        
        try {
            ProductResponse createdProduct = productManagementService.createProduct(request);
            redirectAttributes.addFlashAttribute("success", "Tạo sản phẩm thành công!");
            return "redirect:/admin/product-management";
        } catch (Exception e) {
            log.error("Error creating product", e);
            model.addAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            addFilterDataToModel(model);
            return "admin/product-management/create";
        }
    }
    
    /**
     * Form chỉnh sửa sản phẩm
     */
    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, HttpServletRequest request) {
        try {
            ProductResponse product = productManagementService.getProductById(id);
            ProductUpdateRequest updateRequest = new ProductUpdateRequest();
            
            // Map ProductResponse to ProductUpdateRequest
            updateRequest.setTen(product.getTen());
            updateRequest.setMoTa(product.getMoTa());
            updateRequest.setMoTaNgan(product.getMoTaNgan());
            updateRequest.setGia(product.getGia());
            updateRequest.setGiaGoc(product.getGiaGoc());
            updateRequest.setSoLuongTon(product.getSoLuongTon());
            updateRequest.setChatLieu(product.getChatLieu());
            updateRequest.setXuatXu(product.getXuatXu());
            updateRequest.setTrongLuong(product.getTrongLuong());
            updateRequest.setKichThuoc(product.getKichThuoc());
            updateRequest.setNoiBat(product.getNoiBat());
            updateRequest.setBanChay(product.getBanChay());
            updateRequest.setMoiVe(product.getMoiVe());
            updateRequest.setHoatDong(product.getHoatDong());
            updateRequest.setDanhMucId(product.getDanhMucId());
            updateRequest.setThuongHieuId(product.getThuongHieuId());
            updateRequest.setMonTheThaoId(product.getMonTheThaoId());
            
            model.addAttribute("product", updateRequest);
            model.addAttribute("productId", id);
            addFilterDataToModel(model);
            addCsrfToModel(model, request);
            
            return "admin/product-management/edit";
        } catch (Exception e) {
            log.error("Error getting product for edit", e);
            return "redirect:/admin/product-management?error=notfound";
        }
    }
    
    /**
     * Xử lý cập nhật sản phẩm
     */
    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id,
                        @Valid @ModelAttribute("product") ProductUpdateRequest request,
                        BindingResult bindingResult,
                        RedirectAttributes redirectAttributes,
                        Model model) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("productId", id);
            addFilterDataToModel(model);
            return "admin/product-management/edit";
        }
        
        try {
            ProductResponse updatedProduct = productManagementService.updateProduct(id, request);
            redirectAttributes.addFlashAttribute("success", "Cập nhật sản phẩm thành công!");
            return "redirect:/admin/product-management";
        } catch (Exception e) {
            log.error("Error updating product", e);
            model.addAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            model.addAttribute("productId", id);
            addFilterDataToModel(model);
            return "admin/product-management/edit";
        }
    }
    
    /**
     * Xem chi tiết sản phẩm
     */
    @GetMapping("/{id}")
    public String view(@PathVariable Long id, Model model) {
        try {
            ProductResponse product = productManagementService.getProductById(id);
            model.addAttribute("product", product);
            return "admin/product-management/view";
        } catch (Exception e) {
            log.error("Error getting product", e);
            return "redirect:/admin/product-management?error=notfound";
        }
    }
    
    
    /**
     * Xóa sản phẩm
     */
    @PostMapping("/{id}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            productManagementService.deleteProduct(id);
            response.put("success", true);
            response.put("message", "Xóa sản phẩm thành công!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error deleting product", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Toggle trạng thái sản phẩm
     */
    @PostMapping("/{id}/toggle-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> toggleStatus(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            productManagementService.toggleProductStatus(id);
            response.put("success", true);
            response.put("message", "Cập nhật trạng thái thành công!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error toggling product status", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Bulk delete sản phẩm
     */
    @PostMapping("/bulk-delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bulkDelete(@RequestBody List<Long> productIds) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int deletedCount = productManagementService.bulkDeleteProducts(productIds);
            response.put("success", true);
            response.put("message", "Đã xóa " + deletedCount + " sản phẩm!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error bulk deleting products", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Bulk update trạng thái sản phẩm
     */
    @PostMapping("/bulk-update-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bulkUpdateStatus(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            @SuppressWarnings("unchecked")
            List<Long> productIds = (List<Long>) request.get("productIds");
            Boolean status = (Boolean) request.get("status");
            
            int updatedCount = productManagementService.bulkUpdateProductStatus(productIds, status);
            response.put("success", true);
            response.put("message", "Đã cập nhật " + updatedCount + " sản phẩm!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error bulk updating product status", e);
            response.put("success", false);
            response.put("message", "Có lỗi xảy ra: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    // ========== PRIVATE HELPER METHODS ==========
    
    /**
     * Thêm CSRF token vào model
     * Sử dụng tại: index(), createForm(), editForm()
     */
    private void addCsrfToModel(Model model, HttpServletRequest request) {
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
    }
    
    /**
     * Thêm dữ liệu filter (categories, brands, sports) vào model
     * Sử dụng tại: createForm(), create() error cases, editForm(), update() error cases
     */
    private void addFilterDataToModel(Model model) {
        model.addAttribute("categories", danhMucService.getAllActiveCategories());
        model.addAttribute("brands", thuongHieuService.getAllActiveBrands());
        model.addAttribute("sports", danhMucMonTheThaoService.getAllActiveSports());
    }
}
