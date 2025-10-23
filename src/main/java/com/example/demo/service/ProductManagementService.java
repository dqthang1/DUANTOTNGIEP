package com.example.demo.service;

import com.example.demo.dto.ProductCreateRequest;
import com.example.demo.dto.ProductUpdateRequest;
import com.example.demo.dto.ProductResponse;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductManagementService {
    
    private final ProductRepository productRepository;
    private final DanhMucService danhMucService;
    private final ThuongHieuService thuongHieuService;
    private final DanhMucMonTheThaoService danhMucMonTheThaoService;
    private final BienTheSanPhamRepository bienTheSanPhamRepository;
    
    // Cache cho dữ liệu tĩnh
    private List<DanhMuc> cachedCategories;
    private List<ThuongHieu> cachedBrands;
    private List<DanhMucMonTheThao> cachedSports;
    
    /**
     * Lấy danh sách danh mục với cache
     */
    public List<DanhMuc> getCachedCategories() {
        if (cachedCategories == null) {
            cachedCategories = danhMucService.getAllActiveCategories();
        }
        return cachedCategories;
    }
    
    /**
     * Lấy danh sách thương hiệu với cache
     */
    public List<ThuongHieu> getCachedBrands() {
        if (cachedBrands == null) {
            cachedBrands = thuongHieuService.getAllActiveBrands();
        }
        return cachedBrands;
    }
    
    /**
     * Lấy danh sách môn thể thao với cache
     */
    public List<DanhMucMonTheThao> getCachedSports() {
        if (cachedSports == null) {
            cachedSports = danhMucMonTheThaoService.getAllActiveSports();
        }
        return cachedSports;
    }
    
    /**
     * Clear cache khi có thay đổi dữ liệu
     */
    public void clearCache() {
        cachedCategories = null;
        cachedBrands = null;
        cachedSports = null;
    }
    
    /**
     * Tìm kiếm sản phẩm với filter
     */
    @Transactional(readOnly = true)
    public Page<ProductResponse> searchProducts(String keyword, Long categoryId, Long brandId, 
                                               Long sportId, String status, Pageable pageable) {
        Page<Product> products = productRepository.filterProductsForAdmin(
            keyword, categoryId, brandId, sportId, status, pageable);
        
        // Load relationships separately to avoid N+1 queries
        if (!products.getContent().isEmpty()) {
            List<Long> productIds = products.getContent().stream()
                .map(Product::getId)
                .collect(Collectors.toList());
            
            List<Product> productsWithRelations = productRepository.findByIdInWithRelations(productIds);
            Map<Long, Product> productMap = productsWithRelations.stream()
                .collect(Collectors.toMap(Product::getId, Function.identity()));
            
            // Replace products in page with loaded ones
            products.getContent().forEach(product -> {
                Product loadedProduct = productMap.get(product.getId());
                if (loadedProduct != null) {
                    product.setDanhMuc(loadedProduct.getDanhMuc());
                    product.setThuongHieu(loadedProduct.getThuongHieu());
                    product.setMonTheThao(loadedProduct.getMonTheThao());
                }
            });
        }
        
        return products.map(this::convertToResponse);
    }
    
    
    /**
     * Lấy sản phẩm theo ID
     */
    @Transactional(readOnly = true)
    public ProductResponse getProductById(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));
        
        return convertToResponse(product);
    }
    
    /**
     * Tạo sản phẩm mới
     */
    @Transactional
    public ProductResponse createProduct(ProductCreateRequest request) {
        try {
            // Validate business rules
            validateProductCreateRequest(request);
            
            // Tạo mã sản phẩm unique
            String maSanPham = generateUniqueProductCode(request.getTen());
            
            // Tạo slug unique
            String slug = generateUniqueSlug(request.getTen());
        
            // Load relations
            ProductRelations relations = loadProductRelations(
                request.getDanhMucId(), 
                request.getThuongHieuId(), 
                request.getMonTheThaoId()
            );
        
        // Tạo entity
        Product product = new Product();
        product.setMaSanPham(maSanPham);
        product.setSlug(slug);
        product.setNgayTao(LocalDateTime.now());
        
            // Apply common fields
            applyProductFields(product, request, relations);
        
            // Lưu sản phẩm
            Product savedProduct = productRepository.save(product);
            
            log.info("Created product: {} with ID: {}", savedProduct.getTen(), savedProduct.getId());
            
            return convertToResponse(savedProduct);
        } catch (StringIndexOutOfBoundsException e) {
            log.error("StringIndexOutOfBoundsException in createProduct: {}", e.getMessage());
            throw new RuntimeException("Lỗi xử lý dữ liệu sản phẩm: " + e.getMessage());
        } catch (Exception e) {
            log.error("Error creating product: {}", e.getMessage());
            throw new RuntimeException("Lỗi tạo sản phẩm: " + e.getMessage());
        }
    }
    
    /**
     * Cập nhật sản phẩm
     */
    @Transactional
    public ProductResponse updateProduct(Long id, ProductUpdateRequest request) {
        // Validate business rules
        validateProductUpdateRequest(id, request);
        
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));
        
        // Load relations
        ProductRelations relations = loadProductRelations(
            request.getDanhMucId(), 
            request.getThuongHieuId(), 
            request.getMonTheThaoId()
        );
        
        // Cập nhật thông tin
        applyProductFields(product, request, relations);
        product.setNgayCapNhat(LocalDateTime.now());
        
        // Cập nhật slug nếu tên thay đổi
        if (!product.getTen().equals(request.getTen())) {
            String newSlug = generateUniqueSlug(request.getTen());
            product.setSlug(newSlug);
        }
        
        // Lưu sản phẩm
        Product savedProduct = productRepository.save(product);
        
        log.info("Updated product: {} with ID: {}", savedProduct.getTen(), savedProduct.getId());
        
        return convertToResponse(savedProduct);
    }
    
    /**
     * Xóa sản phẩm
     */
    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));
        
        // Kiểm tra xem sản phẩm có đang được sử dụng trong đơn hàng không
        if (product.getOrderItems() != null && !product.getOrderItems().isEmpty()) {
            throw new RuntimeException("Không thể xóa sản phẩm đã có đơn hàng!");
        }
        
        // Xóa các biến thể sản phẩm trước
        List<BienTheSanPham> variants = bienTheSanPhamRepository.findBySanPhamId(id);
        if (!variants.isEmpty()) {
            bienTheSanPhamRepository.deleteAll(variants);
        }
        
        // Xóa sản phẩm
        productRepository.delete(product);
        
        log.info("Deleted product with ID: {}", id);
    }
    
    /**
     * Toggle trạng thái sản phẩm
     */
    @Transactional
    public void toggleProductStatus(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));
        
        product.setHoatDong(!product.getHoatDong());
        product.setNgayCapNhat(LocalDateTime.now());
        
        productRepository.save(product);
        
        log.info("Toggled product status for ID: {} to {}", id, product.getHoatDong());
    }
    
    /**
     * Xóa nhiều sản phẩm
     */
    @Transactional
    public int bulkDeleteProducts(List<Long> productIds) {
        int deletedCount = 0;
        
        for (Long id : productIds) {
            try {
                deleteProduct(id);
                deletedCount++;
            } catch (Exception e) {
                log.warn("Failed to delete product with ID: {}, error: {}", id, e.getMessage());
            }
        }
        
        log.info("Bulk deleted {} products", deletedCount);
        return deletedCount;
    }
    
    /**
     * Cập nhật trạng thái nhiều sản phẩm
     */
    @Transactional
    public int bulkUpdateProductStatus(List<Long> productIds, Boolean status) {
        int updatedCount = 0;
        
        for (Long id : productIds) {
            try {
                Product product = productRepository.findById(id).orElse(null);
                if (product != null) {
                    product.setHoatDong(status);
                    product.setNgayCapNhat(LocalDateTime.now());
                    productRepository.save(product);
                    updatedCount++;
                }
            } catch (Exception e) {
                log.warn("Failed to update product status for ID: {}, error: {}", id, e.getMessage());
            }
        }
        
        log.info("Bulk updated {} products status to {}", updatedCount, status);
        return updatedCount;
    }
    
    /**
     * Validate tạo sản phẩm
     */
    private void validateProductCreateRequest(ProductCreateRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Request không được null");
        }
        
        if (request.getTen() == null || request.getTen().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên sản phẩm không được để trống");
        }
        
        if (request.getTen().trim().length() < 2) {
            throw new IllegalArgumentException("Tên sản phẩm phải có ít nhất 2 ký tự");
        }
        
        if (request.getTen().trim().length() > 255) {
            throw new IllegalArgumentException("Tên sản phẩm không được vượt quá 255 ký tự");
        }
        
        // Kiểm tra giá gốc phải nhỏ hơn giá bán
        if (request.getGiaGoc() != null && request.getGiaGoc().compareTo(request.getGia()) > 0) {
            throw new RuntimeException("Giá gốc phải nhỏ hơn hoặc bằng giá bán!");
        }
        
        // Kiểm tra tên sản phẩm trùng lặp
        if (productRepository.existsByTenIgnoreCase(request.getTen().trim())) {
            throw new RuntimeException("Tên sản phẩm đã tồn tại!");
        }
    }
    
    /**
     * Validate cập nhật sản phẩm
     */
    private void validateProductUpdateRequest(Long id, ProductUpdateRequest request) {
        // Kiểm tra giá gốc phải nhỏ hơn giá bán
        if (request.getGiaGoc() != null && request.getGiaGoc().compareTo(request.getGia()) > 0) {
            throw new RuntimeException("Giá gốc phải nhỏ hơn hoặc bằng giá bán!");
        }
        
        // Kiểm tra tên sản phẩm trùng lặp (trừ sản phẩm hiện tại)
        Optional<Product> existingProduct = productRepository.findByTenIgnoreCaseAndIdNot(request.getTen(), id);
        if (existingProduct.isPresent()) {
            throw new RuntimeException("Tên sản phẩm đã tồn tại!");
        }
    }
    
    /**
     * Tạo mã sản phẩm unique
     */
    private String generateUniqueProductCode(String productName) {
        if (productName == null || productName.trim().isEmpty()) {
            return "SP-" + System.currentTimeMillis();
        }
        
        String baseCode = productName.toLowerCase()
            .replaceAll("[^a-z0-9\\s]", "")
            .replaceAll("\\s+", "-")
            .trim();
        
        // Đảm bảo baseCode không rỗng
        if (baseCode.isEmpty()) {
            baseCode = "sp";
        }
        
        // Giới hạn độ dài sau khi xử lý
        if (baseCode.length() > 20) {
            baseCode = baseCode.substring(0, 20);
        }
        
        String code = baseCode + "-" + System.currentTimeMillis();
        
        // Kiểm tra unique
        int counter = 1;
        while (productRepository.existsByMaSanPham(code)) {
            code = baseCode + "-" + System.currentTimeMillis() + "-" + counter;
            counter++;
        }
        
        return code;
    }
    
    /**
     * Tạo slug unique
     */
    private String generateUniqueSlug(String productName) {
        if (productName == null || productName.trim().isEmpty()) {
            return "san-pham-" + System.currentTimeMillis();
        }
        
        String baseSlug = productName.toLowerCase()
            .replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
            .replaceAll("[èéẹẻẽêềếệểễ]", "e")
            .replaceAll("[ìíịỉĩ]", "i")
            .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
            .replaceAll("[ùúụủũưừứựửữ]", "u")
            .replaceAll("[ỳýỵỷỹ]", "y")
            .replaceAll("[đ]", "d")
            .replaceAll("[^a-z0-9\\s-]", "")
            .replaceAll("\\s+", "-")
            .replaceAll("-+", "-")
            .replaceAll("^-|-$", "")
            .trim();
        
        // Đảm bảo baseSlug không rỗng
        if (baseSlug.isEmpty()) {
            baseSlug = "san-pham";
        }
        
        String slug = baseSlug;
        int counter = 1;
        
        while (productRepository.existsBySlug(slug)) {
            slug = baseSlug + "-" + counter;
            counter++;
        }
        
        return slug;
    }
    
    /**
     * Đếm tổng số sản phẩm
     */
    public long countAllProducts() {
        return productRepository.count();
    }
    
    /**
     * Đếm số sản phẩm hoạt động
     */
    public long countActiveProducts() {
        return productRepository.countByHoatDongTrue();
    }
    
    /**
     * Convert Product entity to ProductResponse DTO
     */
    public ProductResponse convertToResponse(Product product) {
        ProductResponse response = new ProductResponse();
        response.setId(product.getId());
        response.setMaSanPham(product.getMaSanPham());
        response.setTen(product.getTen());
        response.setSlug(product.getSlug());
        response.setMoTa(product.getMoTa());
        response.setMoTaNgan(product.getMoTaNgan());
        response.setGia(product.getGia());
        response.setGiaGoc(product.getGiaGoc());
        response.setAnhChinh(product.getAnhChinh());
        response.setSoLuongTon(product.getSoLuongTon());
        response.setChatLieu(product.getChatLieu());
        response.setXuatXu(product.getXuatXu());
        response.setTrongLuong(product.getTrongLuong());
        response.setKichThuoc(product.getKichThuoc());
        response.setLuotXem(product.getLuotXem());
        response.setDaBan(product.getDaBan());
        response.setDiemTrungBinh(product.getDiemTrungBinh());
        response.setSoDanhGia(product.getSoDanhGia());
        response.setHoatDong(product.getHoatDong());
        response.setNoiBat(product.getNoiBat());
        response.setBanChay(product.getBanChay());
        response.setMoiVe(product.getMoiVe());
        response.setNgayTao(product.getNgayTao());
        response.setNgayCapNhat(product.getNgayCapNhat());
        response.setNguoiTao(product.getNguoiTao());
        response.setNguoiCapNhat(product.getNguoiCapNhat());
        
        // Thông tin liên quan
        if (product.getDanhMuc() != null) {
            response.setDanhMucId(product.getDanhMuc().getId());
            response.setDanhMucTen(product.getDanhMuc().getTen());
        }
        
        if (product.getThuongHieu() != null) {
            response.setThuongHieuId(product.getThuongHieu().getId());
            response.setThuongHieuTen(product.getThuongHieu().getTen());
        }
        
        if (product.getMonTheThao() != null) {
            response.setMonTheThaoId(product.getMonTheThao().getId());
            response.setMonTheThaoTen(product.getMonTheThao().getTen());
        }
        
        return response;
    }
    
    // ========== PRIVATE HELPER METHODS ==========
    
    /**
     * Inner class để giữ product relations
     */
    @lombok.Data
    @lombok.AllArgsConstructor
    private static class ProductRelations {
        private DanhMuc danhMuc;
        private ThuongHieu thuongHieu;
        private DanhMucMonTheThao monTheThao;
    }
    
    /**
     * Load tất cả relations cần thiết cho sản phẩm
     * Sử dụng tại: createProduct(), updateProduct()
     */
    private ProductRelations loadProductRelations(Long danhMucId, Long thuongHieuId, Long monTheThaoId) {
        DanhMuc danhMuc = danhMucService.getCategoryById(danhMucId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy danh mục với ID: " + danhMucId));
        
        ThuongHieu thuongHieu = thuongHieuService.getBrandById(thuongHieuId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy thương hiệu với ID: " + thuongHieuId));
        
        DanhMucMonTheThao monTheThao = null;
        if (monTheThaoId != null) {
            monTheThao = danhMucMonTheThaoService.getSportById(monTheThaoId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy môn thể thao với ID: " + monTheThaoId));
        }
        
        return new ProductRelations(danhMuc, thuongHieu, monTheThao);
    }
    
    /**
     * Cập nhật các field chung của sản phẩm từ ProductCreateRequest
     */
    private void applyProductFields(Product product, ProductCreateRequest request, ProductRelations relations) {
        product.setTen(request.getTen());
        product.setMoTa(request.getMoTa());
        product.setMoTaNgan(request.getMoTaNgan());
        product.setGia(request.getGia());
        product.setGiaGoc(request.getGiaGoc());
        product.setAnhChinh(request.getAnhChinh());
        product.setSoLuongTon(request.getSoLuongTon());
        product.setChatLieu(request.getChatLieu());
        product.setXuatXu(request.getXuatXu());
        product.setTrongLuong(request.getTrongLuong());
        product.setKichThuoc(request.getKichThuoc());
        product.setNoiBat(request.getNoiBat());
        product.setBanChay(request.getBanChay());
        product.setMoiVe(request.getMoiVe());
        product.setHoatDong(request.getHoatDong());
        product.setDanhMuc(relations.getDanhMuc());
        product.setThuongHieu(relations.getThuongHieu());
        product.setMonTheThao(relations.getMonTheThao());
    }
    
    /**
     * Cập nhật các field chung của sản phẩm từ ProductUpdateRequest
     */
    private void applyProductFields(Product product, ProductUpdateRequest request, ProductRelations relations) {
        product.setTen(request.getTen());
        product.setMoTa(request.getMoTa());
        product.setMoTaNgan(request.getMoTaNgan());
        product.setGia(request.getGia());
        product.setGiaGoc(request.getGiaGoc());
        product.setAnhChinh(request.getAnhChinh());
        product.setSoLuongTon(request.getSoLuongTon());
        product.setChatLieu(request.getChatLieu());
        product.setXuatXu(request.getXuatXu());
        product.setTrongLuong(request.getTrongLuong());
        product.setKichThuoc(request.getKichThuoc());
        product.setNoiBat(request.getNoiBat());
        product.setBanChay(request.getBanChay());
        product.setMoiVe(request.getMoiVe());
        product.setHoatDong(request.getHoatDong());
        product.setDanhMuc(relations.getDanhMuc());
        product.setThuongHieu(relations.getThuongHieu());
        product.setMonTheThao(relations.getMonTheThao());
    }
}
