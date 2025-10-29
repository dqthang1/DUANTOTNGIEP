package com.example.demo.controller;

import com.example.demo.entity.Product;
import com.example.demo.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@Slf4j
public class ProductController {
    
    private final ProductService productService;
    
    /**
     * Lấy sản phẩm mới
     */
    @GetMapping("/new")
    public ResponseEntity<Map<String, Object>> getNewProducts(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Map<String, Object>> products = productService.getProductDTOsByTab("new", limit);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting new products", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải sản phẩm mới"
            ));
        }
    }
    
    /**
     * Lấy sản phẩm bán chạy
     */
    @GetMapping("/best-selling")
    public ResponseEntity<Map<String, Object>> getBestSellingProducts(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Map<String, Object>> products = productService.getProductDTOsByTab("best-selling", limit);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting best selling products", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải sản phẩm bán chạy"
            ));
        }
    }
    
    /**
     * Lấy sản phẩm giảm giá
     */
    @GetMapping("/discounted")
    public ResponseEntity<Map<String, Object>> getDiscountedProducts(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Map<String, Object>> products = productService.getProductDTOsByTab("discounted", limit);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting discounted products", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải sản phẩm giảm giá"
            ));
        }
    }
    
    /**
     * Lấy sản phẩm nổi bật (featured)
     */
    @GetMapping("/featured")
    public ResponseEntity<Map<String, Object>> getFeaturedProducts(
            @RequestParam(defaultValue = "new") String tab,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<Map<String, Object>> products = productService.getProductDTOsByTab(tab, limit);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", products);
            response.put("total", products.size());
            response.put("tab", tab);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting featured products", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải sản phẩm nổi bật"
            ));
        }
    }
    
    /**
     * Lấy chi tiết sản phẩm theo ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getProductById(@PathVariable Long id) {
        try {
            Map<String, Object> product = productService.getProductWithFullDetails(id);
            if (product == null) {
                return ResponseEntity.notFound().build();
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("product", product);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting product by ID: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải thông tin sản phẩm"
            ));
        }
    }
    
    /**
     * Lấy các biến thể của sản phẩm
     */
    @GetMapping("/{id}/variants")
    public ResponseEntity<Map<String, Object>> getProductVariants(@PathVariable Long id) {
        try {
            log.info("Getting variants for product ID: {}", id);
            
            // Load product with variants directly from repository
            Optional<Product> productOpt = productService.findByIdWithVariants(id);
            if (productOpt.isEmpty()) {
                log.warn("Product not found with ID: {}", id);
                return ResponseEntity.notFound().build();
            }
            
            Product product = productOpt.get();
            List<Map<String, Object>> variants = new ArrayList<>();
            List<String> colors = new ArrayList<>();
            List<String> sizes = new ArrayList<>();
            
            if (product.getBienTheSanPhams() != null && !product.getBienTheSanPhams().isEmpty()) {
                variants = product.getBienTheSanPhams().stream()
                    .map(variant -> {
                        Map<String, Object> variantInfo = new HashMap<>();
                        variantInfo.put("id", variant.getId());
                        variantInfo.put("kichCo", variant.getKichCo());
                        variantInfo.put("mauSac", variant.getMauSac());
                        variantInfo.put("soLuong", variant.getSoLuong());
                        variantInfo.put("giaBan", variant.getGiaBan());
                        variantInfo.put("giaKhuyenMai", variant.getGiaKhuyenMai());
                        variantInfo.put("anhBienThe", variant.getAnhBienThe());
                        variantInfo.put("trangThai", variant.getTrangThai());
                        variantInfo.put("hienThi", variant.getHienThi());
                        variantInfo.put("soLuongTon", variant.getSoLuongTon());
                        return variantInfo;
                    })
                    .collect(Collectors.toList());
                
                // Extract unique colors and sizes
                colors = product.getBienTheSanPhams().stream()
                    .map(variant -> variant.getMauSac())
                    .filter(color -> color != null && !color.trim().isEmpty())
                    .distinct()
                    .collect(Collectors.toList());
                
                sizes = product.getBienTheSanPhams().stream()
                    .map(variant -> variant.getKichCo())
                    .filter(size -> size != null && !size.trim().isEmpty())
                    .distinct()
                    .collect(Collectors.toList());
                
                log.info("Found {} variants, {} colors, {} sizes for product ID: {}", 
                    variants.size(), colors.size(), sizes.size(), id);
            } else {
                log.warn("No variants found for product ID: {}", id);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("variants", variants);
            response.put("colors", colors);
            response.put("sizes", sizes);
            response.put("total", variants.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting product variants for ID: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải thông tin biến thể sản phẩm: " + e.getMessage()
            ));
        }
    }
    
    /**
     * Tìm variant cụ thể theo màu sắc và kích thước
     */
    @GetMapping("/{id}/variant")
    public ResponseEntity<Map<String, Object>> getVariantByColorAndSize(
            @PathVariable Long id,
            @RequestParam String color,
            @RequestParam String size) {
        try {
            log.info("Finding variant for product ID: {}, color: {}, size: {}", id, color, size);
            
            Optional<Product> productOpt = productService.findByIdWithVariants(id);
            if (productOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            Product product = productOpt.get();
            if (product.getBienTheSanPhams() == null || product.getBienTheSanPhams().isEmpty()) {
                return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "Không tìm thấy biến thể phù hợp"
                ));
            }
            
            // Tìm variant phù hợp
            Optional<com.example.demo.entity.BienTheSanPham> variantOpt = product.getBienTheSanPhams().stream()
                .filter(variant -> color.equals(variant.getMauSac()) && size.equals(variant.getKichCo()))
                .findFirst();
            
            if (variantOpt.isPresent()) {
                com.example.demo.entity.BienTheSanPham variant = variantOpt.get();
                Map<String, Object> variantInfo = new HashMap<>();
                variantInfo.put("id", variant.getId());
                variantInfo.put("kichCo", variant.getKichCo());
                variantInfo.put("mauSac", variant.getMauSac());
                variantInfo.put("soLuong", variant.getSoLuong());
                variantInfo.put("giaBan", variant.getGiaBan());
                variantInfo.put("giaKhuyenMai", variant.getGiaKhuyenMai());
                variantInfo.put("anhBienThe", variant.getAnhBienThe());
                variantInfo.put("trangThai", variant.getTrangThai());
                variantInfo.put("hienThi", variant.getHienThi());
                variantInfo.put("soLuongTon", variant.getSoLuongTon());
                
                // Tính giá cuối cùng
                Long finalPrice = variant.getGiaKhuyenMai() != null && variant.getGiaKhuyenMai().compareTo(java.math.BigDecimal.ZERO) > 0 
                    ? variant.getGiaKhuyenMai().longValue() 
                    : variant.getGiaBan().longValue();
                variantInfo.put("finalPrice", finalPrice);
                
                return ResponseEntity.ok(Map.of(
                    "success", true,
                    "variant", variantInfo
                ));
            } else {
                return ResponseEntity.ok(Map.of(
                    "success", false,
                    "message", "Không tìm thấy biến thể với màu sắc và kích thước này"
                ));
            }
        } catch (Exception e) {
            log.error("Error finding variant for product ID: {}, color: {}, size: {}", id, color, size, e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Lỗi khi tìm biến thể: " + e.getMessage()
            ));
        }
    }
    
    /**
     * Lấy sản phẩm liên quan
     */
    @GetMapping("/{id}/related")
    public ResponseEntity<Map<String, Object>> getRelatedProducts(
            @PathVariable Long id,
            @RequestParam(defaultValue = "8") int limit) {
        try {
            List<Map<String, Object>> relatedProducts = productService.getRelatedProducts(id, limit);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", relatedProducts);
            response.put("total", relatedProducts.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting related products for ID: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Không thể tải sản phẩm liên quan"
            ));
        }
    }
    
    /**
     * Debug endpoint để kiểm tra dữ liệu biến thể
     */
    @GetMapping("/{id}/debug")
    public ResponseEntity<Map<String, Object>> debugProductVariants(@PathVariable Long id) {
        try {
            Optional<Product> productOpt = productService.findByIdWithVariants(id);
            if (productOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            Product product = productOpt.get();
            Map<String, Object> debugInfo = new HashMap<>();
            debugInfo.put("productId", product.getId());
            debugInfo.put("productName", product.getTen());
            debugInfo.put("variantsCount", product.getBienTheSanPhams() != null ? product.getBienTheSanPhams().size() : 0);
            
            if (product.getBienTheSanPhams() != null) {
                List<Map<String, Object>> variantsDebug = product.getBienTheSanPhams().stream()
                    .map(variant -> {
                        Map<String, Object> variantDebug = new HashMap<>();
                        variantDebug.put("id", variant.getId());
                        variantDebug.put("maSku", variant.getMaSku());
                        variantDebug.put("mauSac", variant.getMauSac());
                        variantDebug.put("kichCo", variant.getKichCo());
                        variantDebug.put("giaBan", variant.getGiaBan());
                        variantDebug.put("soLuongTon", variant.getSoLuongTon());
                        variantDebug.put("hienThi", variant.getHienThi());
                        return variantDebug;
                    })
                    .collect(Collectors.toList());
                debugInfo.put("variants", variantsDebug);
            }
            
            return ResponseEntity.ok(debugInfo);
        } catch (Exception e) {
            log.error("Error debugging product variants for ID: {}", id, e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Không thể debug biến thể sản phẩm",
                "error", e.getMessage()
            ));
        }
    }
}
