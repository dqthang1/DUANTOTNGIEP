package com.example.demo.controller;

import com.example.demo.entity.Product;
import com.example.demo.service.DanhMucService;
import com.example.demo.service.DanhMucMonTheThaoService;
import com.example.demo.service.ProductService;
import com.example.demo.service.ThuongHieuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@Slf4j
public class ProductController {
    
    private final ProductService productService;
    private final DanhMucService danhMucService;
    private final ThuongHieuService thuongHieuService;
    private final DanhMucMonTheThaoService danhMucMonTheThaoService;
    
    /**
     * Lấy danh sách sản phẩm với lọc và tìm kiếm
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long brandId,
            @RequestParam(required = false) Long sportId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String material,
            @RequestParam(required = false) String origin,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Boolean freeShipping,
            @RequestParam(defaultValue = "default") String sort) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<Product> products;
            
            // Xử lý tìm kiếm và lọc - Kết hợp cả hai
            products = productService.filterProductsWithSearch(
                search, categoryId, brandId, sportId, minPrice, maxPrice, 
                material, origin, status, freeShipping, sort, pageable);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products.getContent());
            response.put("totalPages", products.getTotalPages());
            response.put("totalElements", products.getTotalElements());
            response.put("currentPage", page);
            response.put("size", size);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy dữ liệu cho filter dropdown
     */
    @GetMapping("/filter-data")
    public ResponseEntity<Map<String, Object>> getFilterData() {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("categories", danhMucService.getAllActiveCategories());
            response.put("brands", thuongHieuService.getAllActiveBrands());
            response.put("sports", danhMucMonTheThaoService.getAllActiveSports());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting filter data", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm theo ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getProductById(@PathVariable Long id) {
        try {
            Optional<Product> productOpt = productService.findById(id);
            
            if (productOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            Product product = productOpt.get();
            
            // Tăng lượt xem
            productService.incrementViewCount(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("product", product);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting product by id", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Tìm kiếm sản phẩm
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchProducts(@RequestParam String keyword) {
        try {
            List<Product> products = productService.searchProducts(keyword);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error searching products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy gợi ý tìm kiếm
     */
    @GetMapping("/search-suggestions")
    public ResponseEntity<Map<String, Object>> getSearchSuggestions(@RequestParam String q) {
        try {
            List<String> suggestions = productService.getSearchSuggestions(q);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("suggestions", suggestions);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting search suggestions", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm theo danh mục
     */
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<Map<String, Object>> getProductsByCategory(@PathVariable Long categoryId) {
        try {
            List<Product> products = productService.getProductsByCategory(categoryId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting products by category", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm theo thương hiệu
     */
    @GetMapping("/brand/{brandId}")
    public ResponseEntity<Map<String, Object>> getProductsByBrand(@PathVariable Long brandId) {
        try {
            List<Product> products = productService.getProductsByBrand(brandId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting products by brand", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm theo môn thể thao
     */
    @GetMapping("/sport/{sportId}")
    public ResponseEntity<Map<String, Object>> getProductsBySport(@PathVariable Long sportId) {
        try {
            List<Product> products = productService.getProductsBySport(sportId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting products by sport", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm nổi bật
     */
    @GetMapping("/featured")
    public ResponseEntity<Map<String, Object>> getFeaturedProducts() {
        try {
            List<Product> products = productService.getFeaturedProducts();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting featured products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm bán chạy nhất
     */
    @GetMapping("/bestsellers")
    public ResponseEntity<Map<String, Object>> getBestSellingProducts(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            Pageable pageable = PageRequest.of(0, limit);
            List<Product> products = productService.getTopSellingProducts(pageable);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting best selling products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm có sẵn
     */
    @GetMapping("/available")
    public ResponseEntity<Map<String, Object>> getAvailableProducts() {
        try {
            List<Product> products = productService.getAvailableProducts();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting available products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
