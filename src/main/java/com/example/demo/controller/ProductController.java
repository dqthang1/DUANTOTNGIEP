package com.example.demo.controller;

import com.example.demo.entity.Product;
import com.example.demo.service.DanhMucService;
import com.example.demo.service.DanhMucMonTheThaoService;
import com.example.demo.service.ProductService;
import com.example.demo.service.ThuongHieuService;
import com.example.demo.service.KhuyenMaiService;
import com.example.demo.service.SanPhamLienQuanService;
import com.example.demo.service.VariantManagementService;
import com.example.demo.dto.KhuyenMaiResponse;
import com.example.demo.dto.ProductResponse;
import com.example.demo.dto.VariantResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
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
    private final KhuyenMaiService khuyenMaiService;
    private final SanPhamLienQuanService sanPhamLienQuanService;
    private final VariantManagementService variantService;
    
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
            
            // Lấy thông tin khuyến mãi cho tất cả sản phẩm
            Map<Long, Map<String, Object>> promotionsInfo = productService.getProductsPromotionInfo(products.getContent());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products.getContent());
            response.put("promotionsInfo", promotionsInfo);
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
    
    /**
     * Lấy sản phẩm mới (8 sản phẩm đầu tiên)
     */
    @GetMapping("/new")
    public ResponseEntity<Map<String, Object>> getNewProducts() {
        try {
            Pageable pageable = PageRequest.of(0, 8, Sort.by("ngayTao").descending());
            List<Product> products = productService.getAllActiveProducts(pageable).getContent();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting new products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy khuyến mãi áp dụng cho sản phẩm
     */
    @GetMapping("/{productId}/promotions")
    public ResponseEntity<List<KhuyenMaiResponse>> getProductPromotions(@PathVariable Long productId) {
        try {
            Product product = productService.getProductById(productId);
            List<KhuyenMaiResponse> promotions = khuyenMaiService.getApplicablePromotions(product);
            return ResponseEntity.ok(promotions);
        } catch (Exception e) {
            log.error("Error getting product promotions", e);
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * Tính giá sau khi áp dụng khuyến mãi
     */
    @PostMapping("/{productId}/calculate-price")
    public ResponseEntity<Map<String, Object>> calculateDiscountedPrice(
            @PathVariable Long productId,
            @RequestParam(required = false) String maKhuyenMai) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Product product = productService.getProductById(productId);
            BigDecimal originalPrice = product.getGia();
            BigDecimal discountedPrice = originalPrice;
            
            if (maKhuyenMai != null && !maKhuyenMai.trim().isEmpty()) {
                discountedPrice = khuyenMaiService.calculateDiscountedPrice(product, maKhuyenMai);
            }
            
            response.put("success", true);
            response.put("originalPrice", originalPrice);
            response.put("discountedPrice", discountedPrice);
            response.put("savings", originalPrice.subtract(discountedPrice));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error calculating discounted price", e);
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    /**
     * Lấy sản phẩm liên quan (Public API for frontend)
     */
    @GetMapping("/{productId}/related")
    public ResponseEntity<List<ProductResponse>> getRelatedProducts(
            @PathVariable Long productId,
            @RequestParam(defaultValue = "8") int limit) {
        try {
            List<ProductResponse> relatedProducts = sanPhamLienQuanService.getRelatedProducts(productId, limit);
            return ResponseEntity.ok(relatedProducts);
        } catch (Exception e) {
            log.error("Error getting related products for product {}", productId, e);
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    /**
     * Lấy tất cả biến thể của sản phẩm (Public API for frontend)
     */
    @GetMapping("/{productId}/variants")
    public ResponseEntity<Map<String, Object>> getProductVariants(@PathVariable Long productId) {
        try {
            List<VariantResponse> variants = variantService.getVariantsByProductId(productId);
            List<String> colors = variantService.getAvailableColors(productId);
            List<String> sizes = variantService.getAvailableSizes(productId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("variants", variants);
            response.put("colors", colors);
            response.put("sizes", sizes);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting variants for product {}", productId, e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy sản phẩm bán chạy (8 sản phẩm đầu tiên) - alias cho bestsellers
     */
    @GetMapping("/best-selling")
    public ResponseEntity<Map<String, Object>> getBestSellingProductsForHome() {
        try {
            Pageable pageable = PageRequest.of(0, 8);
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
     * Lấy sản phẩm giảm giá (8 sản phẩm đầu tiên)
     */
    @GetMapping("/discounted")
    public ResponseEntity<Map<String, Object>> getDiscountedProducts() {
        try {
            List<Product> products = productService.getDiscountedProducts();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting discounted products", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Tìm variant theo màu và size (Public API for frontend)
     */
    @GetMapping("/{productId}/variant")
    public ResponseEntity<Map<String, Object>> findVariant(
            @PathVariable Long productId,
            @RequestParam String color,
            @RequestParam String size) {
        try {
            VariantResponse variant = variantService.findVariantByColorAndSize(productId, color, size);
            
            Map<String, Object> response = new HashMap<>();
            if (variant != null) {
                response.put("success", true);
                response.put("variant", variant);
            } else {
                response.put("success", false);
                response.put("message", "Không tìm thấy biến thể phù hợp");
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error finding variant", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
