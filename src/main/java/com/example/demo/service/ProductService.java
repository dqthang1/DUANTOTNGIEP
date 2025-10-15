package com.example.demo.service;

import com.example.demo.entity.BienTheSanPham;
import com.example.demo.entity.Product;
import com.example.demo.repository.BienTheSanPhamRepository;
import com.example.demo.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {
    
    private final ProductRepository productRepository;
    private final BienTheSanPhamRepository bienTheSanPhamRepository;
    
    public List<Product> getAllActiveProducts() {
        return productRepository.findByHoatDongTrue();
    }
    
    public Page<Product> getAllActiveProducts(Pageable pageable) {
        return productRepository.findByHoatDongTrue(pageable);
    }
    
    public List<Product> getFeaturedProducts() {
        return productRepository.findByNoiBatTrue();
    }
    
    public List<Product> getAvailableProducts() {
        return productRepository.findAvailableProducts();
    }
    
    public List<Product> searchProducts(String keyword) {
        return productRepository.searchProducts(keyword);
    }
    
    public List<Product> getProductsByCategory(Long categoryId) {
        return productRepository.findByCategoryId(categoryId);
    }
    
    public List<Product> getProductsByBrand(Long brandId) {
        return productRepository.findByBrandId(brandId);
    }
    
    public List<Product> getTopSellingProducts(Pageable pageable) {
        return productRepository.findTopSellingProducts(pageable);
    }
    
    public Optional<Product> findById(Long id) {
        return productRepository.findById(id);
    }
    
    public Optional<Product> findByIdWithDetails(Long id) {
        return productRepository.findByIdWithDetailsEager(id);
    }
    
    public Optional<Product> findByCode(String code) {
        return productRepository.findByMaSanPham(code);
    }
    
    public Optional<Product> findBySlug(String slug) {
        return productRepository.findBySlug(slug);
    }
    
    public Product save(Product product) {
        return productRepository.save(product);
    }
    
    public void deleteById(Long id) {
        productRepository.deleteById(id);
    }
    
    public void incrementViewCount(Long productId) {
        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            product.setLuotXem(product.getLuotXem() + 1);
            productRepository.save(product);
        }
    }
    
    // Thêm các method mới cho Admin
    public Page<Product> getAllProducts(Pageable pageable) {
        return productRepository.findAll(pageable);
    }
    
    public Page<Product> searchProducts(String keyword, Pageable pageable) {
        return productRepository.searchProducts(keyword, pageable);
    }
    
    public Page<Product> filterProducts(Long categoryId, Long brandId, Long sportId, Pageable pageable) {
        return productRepository.filterProducts(categoryId, brandId, sportId, pageable);
    }
    
    public List<Product> getProductsBySport(Long sportId) {
        return productRepository.findBySportId(sportId);
    }
    
    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }
    
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }
    
    public void toggleProductStatus(Long id) {
        Optional<Product> productOpt = productRepository.findById(id);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            product.setHoatDong(!product.getHoatDong());
            productRepository.save(product);
        }
    }
    
    public long countAllProducts() {
        return productRepository.countAllProducts();
    }
    
    public long countActiveProducts() {
        return productRepository.countByHoatDongTrue();
    }
    
    public List<BienTheSanPham> getProductVariants(Long productId) {
        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isPresent()) {
            return productOpt.get().getBienTheSanPhams();
        }
        return List.of();
    }
    
    public void saveProductVariants(Long productId, List<String> sizes, List<String> colors) {
        if (sizes == null || colors == null || sizes.isEmpty() || colors.isEmpty()) {
            return;
        }
        
        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            
            // Lấy danh sách biến thể hiện tại
            List<BienTheSanPham> existingVariants = bienTheSanPhamRepository.findBySanPhamId(productId);
            
            // Tạo biến thể mới từ size và màu
            for (String size : sizes) {
                if (size != null && !size.trim().isEmpty()) {
                    for (String color : colors) {
                        if (color != null && !color.trim().isEmpty()) {
                            // Kiểm tra xem biến thể đã tồn tại chưa
                            boolean exists = existingVariants.stream()
                                .anyMatch(v -> v.getKichCo().equals(size.trim()) && v.getMauSac().equals(color.trim()));
                            
                            if (!exists) {
                                BienTheSanPham variant = new BienTheSanPham();
                                variant.setKichCo(size.trim());
                                variant.setMauSac(color.trim());
                                variant.setSoLuongTon(0);
                                variant.setSanPham(product);
                                
                                // Tạo maSku unique cho variant
                                String maSku = generateVariantSku(product.getMaSanPham(), size.trim(), color.trim());
                                variant.setMaSku(maSku);
                                
                                bienTheSanPhamRepository.save(variant);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public Map<String, Object> saveProductVariantsWithValidation(Long productId, List<String> sizes, List<String> colors) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, String>> createdVariants = new ArrayList<>();
        List<Map<String, String>> duplicateVariants = new ArrayList<>();
        
        if (sizes == null || colors == null || sizes.isEmpty() || colors.isEmpty()) {
            result.put("success", false);
            result.put("message", "Vui lòng nhập ít nhất một kích thước và một màu sắc");
            return result;
        }
        
        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isEmpty()) {
            result.put("success", false);
            result.put("message", "Không tìm thấy sản phẩm");
            return result;
        }
        
        Product product = productOpt.get();
        List<BienTheSanPham> existingVariants = bienTheSanPhamRepository.findBySanPhamId(productId);
        
        // Tạo biến thể mới từ size và màu
        for (String size : sizes) {
            if (size != null && !size.trim().isEmpty()) {
                for (String color : colors) {
                    if (color != null && !color.trim().isEmpty()) {
                        // Kiểm tra xem biến thể đã tồn tại chưa
                        boolean exists = existingVariants.stream()
                            .anyMatch(v -> v.getKichCo().equals(size.trim()) && v.getMauSac().equals(color.trim()));
                        
                        if (exists) {
                            Map<String, String> duplicate = new HashMap<>();
                            duplicate.put("size", size.trim());
                            duplicate.put("color", color.trim());
                            duplicateVariants.add(duplicate);
                        } else {
                            BienTheSanPham variant = new BienTheSanPham();
                            variant.setKichCo(size.trim());
                            variant.setMauSac(color.trim());
                            variant.setSoLuongTon(0);
                            variant.setSanPham(product);
                            
                            // Tạo maSku unique cho variant
                            String maSku = generateVariantSku(product.getMaSanPham(), size.trim(), color.trim());
                            variant.setMaSku(maSku);
                            
                            bienTheSanPhamRepository.save(variant);
                            
                            Map<String, String> created = new HashMap<>();
                            created.put("size", size.trim());
                            created.put("color", color.trim());
                            created.put("sku", maSku);
                            createdVariants.add(created);
                        }
                    }
                }
            }
        }
        
        result.put("success", true);
        result.put("createdVariants", createdVariants);
        result.put("duplicateVariants", duplicateVariants);
        result.put("message", String.format("Tạo thành công %d biến thể, %d biến thể đã tồn tại", 
            createdVariants.size(), duplicateVariants.size()));
        
        return result;
    }
    
    // Thêm các method mới cho tìm kiếm và lọc nâng cao
    public Page<Product> filterProductsAdvanced(Long categoryId, Long brandId, Long sportId,
                                                BigDecimal minPrice, BigDecimal maxPrice,
                                                String material, String origin, String status,
                                                Boolean freeShipping, Pageable pageable) {
        return productRepository.filterProductsAdvanced(categoryId, brandId, sportId, 
                                                       minPrice, maxPrice, material, origin, 
                                                       status, freeShipping, pageable);
    }
    
    public List<String> getSearchSuggestions(String query) {
        return productRepository.getSearchSuggestions(query);
    }
    
    public void deleteProductVariant(Long variantId) {
        bienTheSanPhamRepository.deleteById(variantId);
    }
    
    public void updateProductVariant(Long variantId, String size, String color, Integer stock) {
        Optional<BienTheSanPham> variantOpt = bienTheSanPhamRepository.findById(variantId);
        if (variantOpt.isPresent()) {
            BienTheSanPham variant = variantOpt.get();
            variant.setKichCo(size);
            variant.setMauSac(color);
            if (stock != null) {
                variant.setSoLuongTon(stock);
            }
            
            // Tạo lại maSku
            String maSku = generateVariantSku(variant.getSanPham().getMaSanPham(), size, color);
            variant.setMaSku(maSku);
            
            bienTheSanPhamRepository.save(variant);
        }
    }
    
    public Map<String, Object> validateVariantUpdate(Long variantId, String newSize, String newColor) {
        Map<String, Object> result = new HashMap<>();
        
        // Lấy thông tin variant hiện tại
        Optional<BienTheSanPham> variantOpt = bienTheSanPhamRepository.findById(variantId);
        if (variantOpt.isEmpty()) {
            result.put("valid", false);
            result.put("message", "Không tìm thấy biến thể");
            return result;
        }
        
        BienTheSanPham currentVariant = variantOpt.get();
        Long productId = currentVariant.getSanPham().getId();
        
        // Lấy danh sách tất cả biến thể của sản phẩm (trừ biến thể hiện tại)
        List<BienTheSanPham> otherVariants = bienTheSanPhamRepository.findBySanPhamId(productId)
            .stream()
            .filter(v -> !v.getId().equals(variantId))
            .toList();
        
        // Kiểm tra trùng lặp với các biến thể khác
        boolean isDuplicate = otherVariants.stream()
            .anyMatch(v -> v.getKichCo().equals(newSize) && v.getMauSac().equals(newColor));
        
        if (isDuplicate) {
            result.put("valid", false);
            result.put("message", "Biến thể với kích cỡ '" + newSize + "' và màu sắc '" + newColor + "' đã tồn tại!");
        } else {
            result.put("valid", true);
            result.put("message", "Biến thể hợp lệ");
        }
        
        return result;
    }
    
    // Thêm method mới để kết hợp tìm kiếm và lọc
    public Page<Product> filterProductsWithSearch(String search, Long categoryId, Long brandId, Long sportId,
                                                  BigDecimal minPrice, BigDecimal maxPrice,
                                                  String material, String origin, String status,
                                                  Boolean freeShipping, String sort, Pageable pageable) {
        // Xử lý sort parameter
        Pageable sortedPageable = pageable;
        if (sort != null && !sort.equals("default")) {
            Sort sortObj = Sort.unsorted();
            switch (sort) {
                case "price-low":
                    sortObj = Sort.by("gia").ascending();
                    break;
                case "price-high":
                    sortObj = Sort.by("gia").descending();
                    break;
                case "name":
                    sortObj = Sort.by("ten").ascending();
                    break;
                case "popular":
                    sortObj = Sort.by("daBan").descending();
                    break;
            }
            sortedPageable = PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), sortObj);
        }
        
        // Lấy kết quả từ repository (đã xử lý freeShipping trong query)
        Page<Product> products = productRepository.filterProductsWithSearch(search, categoryId, brandId, sportId, 
                                                         minPrice, maxPrice, material, origin, 
                                                         status, freeShipping, sortedPageable);
        
        return products;
    }
    
    /**
     * Tạo mã SKU unique cho biến thể sản phẩm
     */
    private String generateVariantSku(String productCode, String size, String color) {
        // Loại bỏ khoảng trắng và chuyển thành chữ hoa
        String cleanProductCode = productCode.replaceAll("\\s+", "").toUpperCase();
        String cleanSize = size.replaceAll("\\s+", "").toUpperCase();
        String cleanColor = color.replaceAll("\\s+", "").toUpperCase();
        
        // Tạo SKU theo format: [MÃ_SẢN_PHẨM]-[SIZE]-[MÀU]
        return cleanProductCode + "-" + cleanSize + "-" + cleanColor;
    }
}
