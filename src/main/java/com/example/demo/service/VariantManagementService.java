package com.example.demo.service;

import com.example.demo.dto.VariantCreateRequest;
import com.example.demo.dto.VariantUpdateRequest;
import com.example.demo.dto.VariantResponse;
import com.example.demo.entity.BienTheSanPham;
import com.example.demo.entity.Product;
import com.example.demo.repository.BienTheSanPhamRepository;
import com.example.demo.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class VariantManagementService {
    
    private final BienTheSanPhamRepository variantRepository;
    private final ProductRepository productRepository;
    
    /**
     * Lấy tất cả biến thể của một sản phẩm
     */
    @Transactional(readOnly = true)
    public List<VariantResponse> getVariantsByProductId(Long productId) {
        validateProductExists(productId);
        
        List<BienTheSanPham> variants = variantRepository.findBySanPhamId(productId);
        return variants.stream()
            .map(variant -> convertToResponse(variant))
            .collect(Collectors.toList());
    }
    
    /**
     * Lấy biến thể theo ID
     */
    @Transactional(readOnly = true)
    public VariantResponse getVariantById(Long variantId) {
        BienTheSanPham variant = variantRepository.findById(variantId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy biến thể với ID: " + variantId));
        
        return convertToResponse(variant);
    }
    
    /**
     * Tạo biến thể mới
     */
    @Transactional
    public VariantResponse createVariant(Long productId, VariantCreateRequest request) {
        // Validate
        Product product = validateProductExists(productId);
        validateDuplicateVariant(productId, request.getKichCo(), request.getMauSac());
        validatePrice(request.getGiaBan(), request.getGiaKhuyenMai());
        
        // Tạo SKU
        String maSku = generateSKU(product.getMaSanPham(), request.getKichCo(), request.getMauSac());
        
        // Tạo variant
        BienTheSanPham variant = new BienTheSanPham();
        variant.setMaSku(maSku);
        variant.setKichCo(request.getKichCo().trim());
        variant.setMauSac(request.getMauSac().trim());
        variant.setGiaBan(request.getGiaBan());
        variant.setGiaKhuyenMai(request.getGiaKhuyenMai());
        variant.setSoLuong(request.getSoLuongTon());
        variant.setSoLuongTon(request.getSoLuongTon());
        variant.setAnhBienThe(request.getAnhBienThe());
        variant.setTrongLuong(request.getTrongLuong());
        variant.setHienThi(request.getHienThi() != null ? request.getHienThi() : true);
        variant.setTrangThai(true);
        variant.setNgayTao(LocalDateTime.now());
        variant.setSanPham(product);
        
        BienTheSanPham saved = variantRepository.save(variant);
        
        log.info("Created variant {} for product {}", saved.getMaSku(), productId);
        
        return convertToResponse(saved);
    }
    
    /**
     * Cập nhật biến thể
     */
    @Transactional
    public VariantResponse updateVariant(Long variantId, VariantUpdateRequest request) {
        BienTheSanPham variant = variantRepository.findById(variantId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy biến thể với ID: " + variantId));
        
        Long productId = variant.getSanPham().getId();
        
        // Validate duplicate (trừ chính nó)
        validateDuplicateVariantForUpdate(productId, request.getKichCo(), request.getMauSac(), variantId);
        validatePrice(request.getGiaBan(), request.getGiaKhuyenMai());
        
        // Update fields
        variant.setKichCo(request.getKichCo().trim());
        variant.setMauSac(request.getMauSac().trim());
        variant.setGiaBan(request.getGiaBan());
        variant.setGiaKhuyenMai(request.getGiaKhuyenMai());
        variant.setSoLuong(request.getSoLuongTon());
        variant.setSoLuongTon(request.getSoLuongTon());
        variant.setAnhBienThe(request.getAnhBienThe());
        variant.setTrongLuong(request.getTrongLuong());
        
        if (request.getHienThi() != null) {
            variant.setHienThi(request.getHienThi());
        }
        if (request.getTrangThai() != null) {
            variant.setTrangThai(request.getTrangThai());
        }
        
        variant.setNgayCapNhat(LocalDateTime.now());
        
        // Update SKU nếu màu hoặc size thay đổi
        String newSku = generateSKU(variant.getSanPham().getMaSanPham(), variant.getKichCo(), variant.getMauSac());
        variant.setMaSku(newSku);
        
        BienTheSanPham updated = variantRepository.save(variant);
        
        log.info("Updated variant {}", variantId);
        
        return convertToResponse(updated);
    }
    
    /**
     * Xóa biến thể
     */
    @Transactional
    public void deleteVariant(Long variantId) {
        BienTheSanPham variant = variantRepository.findById(variantId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy biến thể với ID: " + variantId));
        
        // Kiểm tra xem có đơn hàng nào đang sử dụng variant này không
        // (Tùy business logic, có thể soft delete thay vì hard delete)
        
        variantRepository.deleteById(variantId);
        
        log.info("Deleted variant {}", variantId);
    }
    
    /**
     * Toggle trạng thái hiển thị
     */
    @Transactional
    public void toggleVisibility(Long variantId) {
        BienTheSanPham variant = variantRepository.findById(variantId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy biến thể với ID: " + variantId));
        
        variant.setHienThi(!variant.getHienThi());
        variant.setNgayCapNhat(LocalDateTime.now());
        
        variantRepository.save(variant);
        
        log.info("Toggled visibility for variant {}: {}", variantId, variant.getHienThi());
    }
    
    /**
     * Lấy danh sách màu sắc có sẵn
     */
    @Transactional(readOnly = true)
    public List<String> getAvailableColors(Long productId) {
        validateProductExists(productId);
        return variantRepository.findDistinctColorsByProductId(productId);
    }
    
    /**
     * Lấy danh sách kích cỡ có sẵn
     */
    @Transactional(readOnly = true)
    public List<String> getAvailableSizes(Long productId) {
        validateProductExists(productId);
        return variantRepository.findDistinctSizesByProductId(productId);
    }
    
    /**
     * Tìm variant theo màu và size
     */
    @Transactional(readOnly = true)
    public VariantResponse findVariantByColorAndSize(Long productId, String color, String size) {
        return variantRepository.findByProductIdAndColorAndSize(productId, color, size)
            .map(variant -> convertToResponse(variant))
            .orElse(null);
    }
    
    /**
     * Lấy thống kê variants
     */
    @Transactional(readOnly = true)
    public VariantStatistics getVariantStatistics(Long productId) {
        validateProductExists(productId);
        
        long totalVariants = variantRepository.countBySanPhamId(productId);
        long inStockVariants = variantRepository.countInStockVariants(productId);
        
        return new VariantStatistics(totalVariants, inStockVariants, totalVariants - inStockVariants);
    }
    
    /**
     * Tạo hàng loạt variants từ danh sách màu và size
     */
    @Transactional
    public BulkCreateResult bulkCreateVariants(Long productId, com.example.demo.dto.BulkCreateVariantsRequest request) {
        Product product = validateProductExists(productId);
        
        List<VariantResponse> created = new java.util.ArrayList<>();
        List<String> skipped = new java.util.ArrayList<>();
        List<String> errors = new java.util.ArrayList<>();
        
        for (String color : request.getColors()) {
            for (String size : request.getSizes()) {
                String colorTrimmed = color.trim();
                String sizeTrimmed = size.trim();
                
                // Skip empty
                if (colorTrimmed.isEmpty() || sizeTrimmed.isEmpty()) {
                    continue;
                }
                
                try {
                    // Check duplicate
                    if (variantRepository.findBySanPhamIdAndKichCoAndMauSac(productId, sizeTrimmed, colorTrimmed).isPresent()) {
                        if (request.getSkipDuplicates()) {
                            skipped.add(colorTrimmed + " - " + sizeTrimmed);
                            continue;
                        } else {
                            errors.add(colorTrimmed + " - " + sizeTrimmed + ": Đã tồn tại");
                            continue;
                        }
                    }
                    
                    // Create variant
                    String maSku = generateSKU(product.getMaSanPham(), sizeTrimmed, colorTrimmed);
                    
                    BienTheSanPham variant = new BienTheSanPham();
                    variant.setMaSku(maSku);
                    variant.setKichCo(sizeTrimmed);
                    variant.setMauSac(colorTrimmed);
                    variant.setGiaBan(request.getDefaultPrice());
                    variant.setGiaKhuyenMai(request.getDefaultPromotionPrice());
                    variant.setSoLuong(request.getDefaultStock());
                    variant.setSoLuongTon(request.getDefaultStock());
                    variant.setHienThi(true);
                    variant.setTrangThai(true);
                    variant.setNgayTao(LocalDateTime.now());
                    variant.setSanPham(product);
                    
                    BienTheSanPham saved = variantRepository.save(variant);
                    created.add(convertToResponse(saved));
                    
                } catch (Exception e) {
                    errors.add(colorTrimmed + " - " + sizeTrimmed + ": " + e.getMessage());
                    log.error("Error creating variant {}-{} for product {}", colorTrimmed, sizeTrimmed, productId, e);
                }
            }
        }
        
        log.info("Bulk created {} variants for product {}, skipped {}, errors {}", 
            created.size(), productId, skipped.size(), errors.size());
        
        return new BulkCreateResult(created, skipped, errors);
    }
    
    // ========== PRIVATE HELPER METHODS ==========
    
    private Product validateProductExists(Long productId) {
        return productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + productId));
    }
    
    private void validateDuplicateVariant(Long productId, String kichCo, String mauSac) {
        variantRepository.findBySanPhamIdAndKichCoAndMauSac(productId, kichCo.trim(), mauSac.trim())
            .ifPresent(v -> {
                throw new RuntimeException(String.format(
                    "Biến thể với màu '%s' và kích cỡ '%s' đã tồn tại!", mauSac, kichCo));
            });
    }
    
    private void validateDuplicateVariantForUpdate(Long productId, String kichCo, String mauSac, Long variantId) {
        variantRepository.findDuplicateVariant(productId, kichCo.trim(), mauSac.trim(), variantId)
            .ifPresent(v -> {
                throw new RuntimeException(String.format(
                    "Biến thể với màu '%s' và kích cỡ '%s' đã tồn tại!", mauSac, kichCo));
            });
    }
    
    private void validatePrice(java.math.BigDecimal giaBan, java.math.BigDecimal giaKhuyenMai) {
        if (giaBan == null || giaBan.compareTo(java.math.BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Giá bán phải lớn hơn 0!");
        }
        
        if (giaKhuyenMai != null && giaKhuyenMai.compareTo(giaBan) > 0) {
            throw new RuntimeException("Giá khuyến mãi không được lớn hơn giá bán!");
        }
        
        if (giaKhuyenMai != null && giaKhuyenMai.compareTo(java.math.BigDecimal.ZERO) < 0) {
            throw new RuntimeException("Giá khuyến mãi không được âm!");
        }
    }
    
    private String generateSKU(String productCode, String size, String color) {
        String sizeCode = size != null ? size.toUpperCase().replaceAll("[^A-Z0-9]", "") : "XX";
        String colorCode = color != null ? color.substring(0, Math.min(3, color.length())).toUpperCase() : "XXX";
        return productCode + "-" + sizeCode + "-" + colorCode;
    }
    
    private VariantResponse convertToResponse(BienTheSanPham variant) {
        VariantResponse response = new VariantResponse();
        
        response.setId(variant.getId());
        response.setMaSku(variant.getMaSku());
        response.setKichCo(variant.getKichCo());
        response.setMauSac(variant.getMauSac());
        response.setGiaBan(variant.getGiaBan());
        response.setGiaKhuyenMai(variant.getGiaKhuyenMai());
        response.setSoLuongTon(variant.getSoLuongTon());
        response.setAnhBienThe(variant.getAnhBienThe());
        response.setTrongLuong(variant.getTrongLuong());
        response.setTrangThai(variant.getTrangThai());
        response.setHienThi(variant.getHienThi());
        response.setNgayTao(variant.getNgayTao());
        response.setNgayCapNhat(variant.getNgayCapNhat());
        
        // Product info
        if (variant.getSanPham() != null) {
            response.setProductId(variant.getSanPham().getId());
            response.setProductName(variant.getSanPham().getTen());
            response.setProductCode(variant.getSanPham().getMaSanPham());
        }
        
        // Computed fields
        response.setInStock(variant.getSoLuongTon() != null && variant.getSoLuongTon() > 0);
        response.setFinalPrice(variant.getGiaKhuyenMai() != null ? variant.getGiaKhuyenMai() : variant.getGiaBan());
        
        return response;
    }
    
    // Inner class for statistics
    @lombok.Data
    @lombok.AllArgsConstructor
    public static class VariantStatistics {
        private long totalVariants;
        private long inStockVariants;
        private long outOfStockVariants;
    }
    
    // Inner class for bulk create result
    @lombok.Data
    @lombok.AllArgsConstructor
    public static class BulkCreateResult {
        private List<VariantResponse> created;
        private List<String> skipped;
        private List<String> errors;
    }
}

