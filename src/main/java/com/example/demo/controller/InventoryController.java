package com.example.demo.controller;

import com.example.demo.dto.InventoryHistoryResponse;
import com.example.demo.dto.InventoryResponse;
import com.example.demo.dto.InventoryUpdateRequest;
import com.example.demo.service.InventoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.DefaultCsrfToken;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/inventory")
@RequiredArgsConstructor
@Slf4j
public class InventoryController {
    
    private final InventoryService inventoryService;
    
    /**
     * Trang quản lý tồn kho
     */
    @GetMapping
    public String index(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "20") int size,
                       @RequestParam(required = false) String search,
                       @RequestParam(required = false) String status,
                       Model model,
                       HttpServletRequest request) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by("ten").ascending());
        Page<InventoryResponse> inventory = inventoryService.getAllInventory(search, status, pageable);
        
        // Count by status
        long inStockCount = inventoryService.countByStatus("IN_STOCK");
        long lowStockCount = inventoryService.countByStatus("LOW_STOCK");
        long outOfStockCount = inventoryService.countByStatus("OUT_OF_STOCK");
        
        model.addAttribute("inventory", inventory);
        model.addAttribute("inStockCount", inStockCount);
        model.addAttribute("lowStockCount", lowStockCount);
        model.addAttribute("outOfStockCount", outOfStockCount);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", inventory.getTotalPages());
        model.addAttribute("search", search);
        model.addAttribute("status", status);
        
        // CSRF token
        CsrfToken csrfToken = (CsrfToken) request.getAttribute("_csrf");
        if (csrfToken == null) {
            String token = java.util.UUID.randomUUID().toString();
            csrfToken = new DefaultCsrfToken("X-CSRF-TOKEN", "_csrf", token);
        }
        model.addAttribute("_csrf", csrfToken);
        
        return "admin/inventory-management/index";
    }
    
    /**
     * API: Cập nhật tồn kho
     */
    @PostMapping("/api/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateInventory(@RequestParam Long productId,
                                                               @RequestBody InventoryUpdateRequest request,
                                                               HttpServletRequest httpRequest) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            InventoryResponse result = inventoryService.updateInventory(productId, request);
            
            response.put("success", true);
            response.put("message", "Cập nhật tồn kho thành công!");
            response.put("data", result);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error updating inventory", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Bulk update tồn kho
     */
    @PostMapping("/api/bulk-update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> bulkUpdateInventory(@RequestBody List<InventoryUpdateRequest> requests,
                                                                   HttpServletRequest httpRequest) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<InventoryResponse> results = inventoryService.bulkUpdateInventory(requests);
            
            response.put("success", true);
            response.put("message", "Cập nhật hàng loạt thành công!");
            response.put("data", results);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error bulk updating inventory", e);
            response.put("success", false);
            response.put("message", "Lỗi: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * API: Lấy sản phẩm sắp hết hàng
     */
    @GetMapping("/api/low-stock")
    @ResponseBody
    public ResponseEntity<List<InventoryResponse>> getLowStockProducts(
            @RequestParam(defaultValue = "10") int threshold) {
        try {
            List<InventoryResponse> lowStock = inventoryService.getLowStockProducts(threshold);
            return ResponseEntity.ok(lowStock);
        } catch (Exception e) {
            log.error("Error getting low stock products", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * API: Lấy lịch sử tồn kho
     */
    @GetMapping("/api/history")
    @ResponseBody
    public ResponseEntity<Page<InventoryHistoryResponse>> getInventoryHistory(
            @RequestParam(required = false) Long productId,
            @RequestParam(required = false) String loaiThayDoi,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            LocalDateTime start = startDate != null ? LocalDateTime.parse(startDate) : null;
            LocalDateTime end = endDate != null ? LocalDateTime.parse(endDate) : null;
            
            Pageable pageable = PageRequest.of(page, size);
            Page<InventoryHistoryResponse> history = inventoryService.getInventoryHistory(
                productId, loaiThayDoi, start, end, pageable);
            
            return ResponseEntity.ok(history);
        } catch (Exception e) {
            log.error("Error getting inventory history", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
}

