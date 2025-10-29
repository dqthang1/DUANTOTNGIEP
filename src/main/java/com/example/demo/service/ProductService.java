package com.example.demo.service;

import com.example.demo.entity.BienTheSanPham;
import com.example.demo.entity.Product;
import com.example.demo.entity.SanPhamKhuyenMai;
import com.example.demo.repository.BienTheSanPhamRepository;
import com.example.demo.repository.ProductRepository;
import com.example.demo.repository.SanPhamKhuyenMaiRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {
    
    private final ProductRepository productRepository;
    private final BienTheSanPhamRepository bienTheSanPhamRepository;
    private final SanPhamKhuyenMaiRepository sanPhamKhuyenMaiRepository;
    
    public List<Product> getAllActiveProducts() {
        return productRepository.findByHoatDongTrue();
    }
    
    public Page<Product> getAllActiveProducts(Pageable pageable) {
        return productRepository.findByHoatDongTrue(pageable);
    }
    
    public Product getProductById(Long id) {
        return productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + id));
    }
    
    public List<Product> getFeaturedProducts() {
        return productRepository.findByNoiBatTrue();
    }
    
    public List<Product> getNewProducts(int limit) {
        return productRepository.findNewProducts(PageRequest.of(0, limit));
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
    
    public List<Product> getRecommendedProducts(int limit) {
        // Lấy sản phẩm nổi bật và có giảm giá
        List<Product> featuredProducts = productRepository.findByNoiBatTrue();
        List<Product> saleProducts = productRepository.findSaleProducts();
        
        // Kết hợp và loại bỏ trùng lặp
        Set<Product> recommendedSet = new LinkedHashSet<>();
        recommendedSet.addAll(featuredProducts);
        recommendedSet.addAll(saleProducts);
        
        // Chuyển thành list và giới hạn số lượng
        List<Product> recommended = new ArrayList<>(recommendedSet);
        
        // Nếu không đủ sản phẩm, lấy thêm sản phẩm ngẫu nhiên
        if (recommended.size() < limit) {
            List<Product> randomProducts = productRepository.findRandomProducts(limit - recommended.size());
            recommended.addAll(randomProducts);
        }
        
        return recommended.stream().limit(limit).toList();
    }
    
    public List<Product> getTopSellingProducts(Pageable pageable) {
        return productRepository.findTopSellingProducts(pageable);
    }
    
    public List<Product> getDiscountedProducts() {
        return productRepository.findDiscountedProducts();
    }
    
    public Optional<Product> findById(Long id) {
        return productRepository.findById(id);
    }
    
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getProductVariants(Long productId) {
        try {
            // Try to get distinct colors directly
            List<String> colors = bienTheSanPhamRepository.findDistinctColorsByProductId(productId);
            
            // Convert to variant format
            List<Map<String, Object>> variants = new ArrayList<>();
            for (String color : colors) {
                Map<String, Object> variant = new HashMap<>();
                variant.put("id", productId); // Use product ID as variant ID
                variant.put("mauSac", color);
                variant.put("kichCo", "M"); // Default size
                variant.put("soLuong", 1); // Default quantity
                variants.add(variant);
            }
            
            return variants;
        } catch (Exception e) {
            log.error("Error getting variants for product {}: {}", productId, e.getMessage());
            return new ArrayList<>();
        }
    }
    
    @Transactional(readOnly = true)
    public Map<String, Object> getProductCategory(Long productId) {
        return productRepository.findCategoryByProductId(productId);
    }
    
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getProductDTOsByTab(String tab, int limit) {
        List<Map<String, Object>> productDTOs = productRepository.findProductDTOsByTab(tab, limit);
        List<Map<String, Object>> result = new ArrayList<>();
        
        // Convert each TupleBackedMap to a new HashMap
        for (Map<String, Object> productDTO : productDTOs) {
            Map<String, Object> newDTO = new HashMap<>();
            
            // Copy all fields to new HashMap
            newDTO.put("id", productDTO.get("id"));
            newDTO.put("ten", productDTO.get("ten"));
            newDTO.put("gia", productDTO.get("gia"));
            newDTO.put("giaGoc", productDTO.get("giaGoc"));
            newDTO.put("anhChinh", productDTO.get("anhChinh"));
            newDTO.put("noiBat", productDTO.get("noiBat"));
            newDTO.put("giamGia", productDTO.get("giamGia"));
            
            try {
                Long productId = ((Number) productDTO.get("id")).longValue();
                List<Map<String, Object>> variants = getProductVariants(productId);
                newDTO.put("bienTheSanPhams", variants);
                
                // Format category info
                Map<String, Object> category = new HashMap<>();
                category.put("id", productDTO.get("danhMuc_id"));
                category.put("ten", productDTO.get("danhMuc_ten"));
                newDTO.put("danhMuc", category);
                
            } catch (Exception e) {
                log.warn("Could not access variants for product {}: {}", productDTO.get("id"), e.getMessage());
                newDTO.put("bienTheSanPhams", null);
                
                // Still add category info even if variants fail
                Map<String, Object> category = new HashMap<>();
                category.put("id", productDTO.get("danhMuc_id"));
                category.put("ten", productDTO.get("danhMuc_ten"));
                newDTO.put("danhMuc", category);
            }
            
            result.add(newDTO);
        }
        
        return result;
    }
    
    public Optional<Product> findByIdWithDetails(Long id) {
        // First load basic relationships
        Optional<Product> productOpt = productRepository.findByIdWithDetailsEager(id);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            
            // Load images separately to avoid MultipleBagFetchException
            Optional<Product> productWithImages = productRepository.findByIdWithImages(id);
            if (productWithImages.isPresent()) {
                product.setAnhSanPhams(productWithImages.get().getAnhSanPhams());
            }
            
            // Load variants separately
            Optional<Product> productWithVariants = productRepository.findByIdWithVariants(id);
            if (productWithVariants.isPresent()) {
                product.setBienTheSanPhams(productWithVariants.get().getBienTheSanPhams());
            }
            
            return Optional.of(product);
        }
        return productOpt;
    }
    
    public Optional<Product> findByCode(String code) {
        return productRepository.findByMaSanPham(code);
    }
    
    public Optional<Product> findBySlug(String slug) {
        return productRepository.findBySlug(slug);
    }
    
    public Optional<Product> findByIdWithVariants(Long id) {
        return productRepository.findByIdWithVariants(id);
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
     * Lấy thông tin khuyến mãi cho sản phẩm
     */
    public Map<String, Object> getProductPromotionInfo(Long productId) {
        Map<String, Object> promotionInfo = new HashMap<>();
        
        // Lấy khuyến mãi đang hoạt động cho sản phẩm
        List<SanPhamKhuyenMai> activePromotions = sanPhamKhuyenMaiRepository
            .findActivePromotionsForProduct(productId, LocalDateTime.now());
        
        if (!activePromotions.isEmpty()) {
            // Lấy khuyến mãi có giá trị cao nhất
            SanPhamKhuyenMai bestPromotion = activePromotions.stream()
                .max((p1, p2) -> {
                    BigDecimal discount1 = p1.calculateFinalPrice();
                    BigDecimal discount2 = p2.calculateFinalPrice();
                    return discount1.compareTo(discount2);
                })
                .orElse(activePromotions.get(0));
            
            promotionInfo.put("hasPromotion", true);
            promotionInfo.put("promotionName", bestPromotion.getKhuyenMai().getTen());
            promotionInfo.put("promotionType", bestPromotion.getKhuyenMai().getLoai());
            promotionInfo.put("originalPrice", bestPromotion.getSanPham().getGia());
            promotionInfo.put("finalPrice", bestPromotion.calculateFinalPrice());
            promotionInfo.put("discountAmount", bestPromotion.getSanPham().getGia().subtract(bestPromotion.calculateFinalPrice()));
            
            // Tính phần trăm giảm giá
            BigDecimal discountPercent = bestPromotion.getSanPham().getGia()
                .subtract(bestPromotion.calculateFinalPrice())
                .multiply(BigDecimal.valueOf(100))
                .divide(bestPromotion.getSanPham().getGia(), 2, java.math.RoundingMode.HALF_UP);
            promotionInfo.put("discountPercent", discountPercent);
        } else {
            promotionInfo.put("hasPromotion", false);
        }
        
        return promotionInfo;
    }
    
    /**
     * Lấy thông tin khuyến mãi cho danh sách sản phẩm
     */
    public Map<Long, Map<String, Object>> getProductsPromotionInfo(List<Product> products) {
        Map<Long, Map<String, Object>> promotionsMap = new HashMap<>();
        
        for (Product product : products) {
            promotionsMap.put(product.getId(), getProductPromotionInfo(product.getId()));
        }
        
        return promotionsMap;
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
    
    /**
     * Convert Product entity to DTO to avoid lazy loading issues
     */
    @Transactional(readOnly = true)
    public Map<String, Object> convertToProductDTO(Product product) {
        log.info("Converting product to DTO: {}", product.getId());
        Map<String, Object> dto = new HashMap<>();
        dto.put("id", product.getId());
        dto.put("maSanPham", product.getMaSanPham());
        dto.put("ten", product.getTen());
        dto.put("slug", product.getSlug());
        dto.put("moTa", product.getMoTa());
        dto.put("moTaNgan", product.getMoTaNgan());
        dto.put("gia", product.getGia());
        dto.put("giaGoc", product.getGiaGoc());
        dto.put("anhChinh", product.getAnhChinh());
        dto.put("soLuongTon", product.getSoLuongTon());
        dto.put("chatLieu", product.getChatLieu());
        dto.put("xuatXu", product.getXuatXu());
        dto.put("trongLuong", product.getTrongLuong());
        dto.put("kichThuoc", product.getKichThuoc());
        dto.put("luotXem", product.getLuotXem());
        dto.put("daBan", product.getDaBan());
        dto.put("diemTrungBinh", product.getDiemTrungBinh());
        dto.put("soDanhGia", product.getSoDanhGia());
        dto.put("hoatDong", product.getHoatDong());
        dto.put("noiBat", product.getNoiBat());
        dto.put("banChay", product.getBanChay());
        dto.put("moiVe", product.getMoiVe());
        dto.put("ngayTao", product.getNgayTao());
        dto.put("ngayCapNhat", product.getNgayCapNhat());
        
        // Add category info if available
        try {
            if (product.getDanhMuc() != null) {
                Map<String, Object> categoryInfo = new HashMap<>();
                categoryInfo.put("id", product.getDanhMuc().getId());
                categoryInfo.put("ten", product.getDanhMuc().getTen());
                categoryInfo.put("slug", product.getDanhMuc().getSlug());
                dto.put("danhMuc", categoryInfo);
            }
        } catch (Exception e) {
            log.error("Error getting category info", e);
        }
        
        // Add brand info if available
        try {
            if (product.getThuongHieu() != null) {
                Map<String, Object> brandInfo = new HashMap<>();
                brandInfo.put("id", product.getThuongHieu().getId());
                brandInfo.put("ten", product.getThuongHieu().getTen());
                brandInfo.put("slug", product.getThuongHieu().getSlug());
                dto.put("thuongHieu", brandInfo);
            }
        } catch (Exception e) {
            log.error("Error getting brand info", e);
        }
        
        // Add sport category info if available
        try {
            if (product.getMonTheThao() != null) {
                Map<String, Object> sportInfo = new HashMap<>();
                sportInfo.put("id", product.getMonTheThao().getId());
                sportInfo.put("ten", product.getMonTheThao().getTen());
                sportInfo.put("slug", product.getMonTheThao().getSlug());
                dto.put("monTheThao", sportInfo);
            }
        } catch (Exception e) {
            log.error("Error getting sport info", e);
        }
        
        // Add variants info if available (avoid lazy loading)
        try {
            if (product.getBienTheSanPhams() != null && !product.getBienTheSanPhams().isEmpty()) {
                List<Map<String, Object>> variants = product.getBienTheSanPhams().stream()
                    .map(variant -> {
                        Map<String, Object> variantInfo = new HashMap<>();
                        variantInfo.put("id", variant.getId());
                        variantInfo.put("maSku", variant.getMaSku());
                        variantInfo.put("kichCo", variant.getKichCo());
                        variantInfo.put("mauSac", variant.getMauSac());
                        variantInfo.put("soLuong", variant.getSoLuong());
                        variantInfo.put("giaBan", variant.getGiaBan());
                        variantInfo.put("giaKhuyenMai", variant.getGiaKhuyenMai());
                        variantInfo.put("anhBienThe", variant.getAnhBienThe());
                        variantInfo.put("trongLuong", variant.getTrongLuong());
                        variantInfo.put("trangThai", variant.getTrangThai());
                        variantInfo.put("hienThi", variant.getHienThi());
                        return variantInfo;
                    })
                    .collect(Collectors.toList());
                dto.put("bienTheSanPhams", variants);
            }
        } catch (Exception e) {
            log.error("Error getting variants info", e);
        }
        
        // Add images info if available (avoid lazy loading)
        try {
            if (product.getAnhSanPhams() != null && !product.getAnhSanPhams().isEmpty()) {
                List<Map<String, Object>> images = product.getAnhSanPhams().stream()
                    .map(image -> {
                        Map<String, Object> imageInfo = new HashMap<>();
                        imageInfo.put("id", image.getId());
                        imageInfo.put("urlAnh", image.getUrlAnh());
                        imageInfo.put("laAnhChinh", image.getLaAnhChinh());
                        imageInfo.put("thuTu", image.getThuTu());
                        imageInfo.put("ngayThem", image.getNgayThem());
                        return imageInfo;
                    })
                    .collect(Collectors.toList());
                dto.put("anhSanPhams", images);
            }
        } catch (Exception e) {
            log.error("Error getting images info", e);
        }
        
        return dto;
    }
    
    /**
     * Get product with full details including images and variants
     */
    public Map<String, Object> getProductWithFullDetails(Long id) {
        try {
            // Get product with basic details
            Optional<Product> productOpt = productRepository.findByIdWithDetails(id);
            if (productOpt.isEmpty()) {
                return null;
            }
            
            Product product = productOpt.get();
            Map<String, Object> productDTO = new HashMap<>();
            
            // Basic product info
            productDTO.put("id", product.getId());
            productDTO.put("maSanPham", product.getMaSanPham());
            productDTO.put("ten", product.getTen());
            productDTO.put("slug", product.getSlug());
            productDTO.put("gia", product.getGia());
            productDTO.put("giaGoc", product.getGiaGoc());
            productDTO.put("anhChinh", product.getAnhChinh());
            productDTO.put("moTa", product.getMoTa());
            productDTO.put("moTaNgan", product.getMoTaNgan());
            productDTO.put("chatLieu", product.getChatLieu());
            productDTO.put("xuatXu", product.getXuatXu());
            productDTO.put("trongLuong", product.getTrongLuong());
            productDTO.put("kichThuoc", product.getKichThuoc());
            productDTO.put("diemTrungBinh", product.getDiemTrungBinh());
            productDTO.put("soDanhGia", product.getSoDanhGia());
            productDTO.put("soLuongTon", product.getSoLuongTon());
            productDTO.put("daBan", product.getDaBan());
            productDTO.put("luotXem", product.getLuotXem());
            productDTO.put("hoatDong", product.getHoatDong());
            productDTO.put("noiBat", product.getNoiBat());
            productDTO.put("banChay", product.getBanChay());
            productDTO.put("moiVe", product.getMoiVe());
            productDTO.put("ngayTao", product.getNgayTao());
            productDTO.put("ngayCapNhat", product.getNgayCapNhat());
            
            // Category info
            if (product.getDanhMuc() != null) {
                Map<String, Object> categoryInfo = new HashMap<>();
                categoryInfo.put("id", product.getDanhMuc().getId());
                categoryInfo.put("ten", product.getDanhMuc().getTen());
                productDTO.put("danhMuc", categoryInfo);
                log.info("Category info added for product {}: {}", product.getId(), product.getDanhMuc().getTen());
            } else {
                log.warn("No category info found for product {}", product.getId());
                // Add default category info to prevent template errors
                Map<String, Object> defaultCategoryInfo = new HashMap<>();
                defaultCategoryInfo.put("id", 0L);
                defaultCategoryInfo.put("ten", "Danh mục chung");
                productDTO.put("danhMuc", defaultCategoryInfo);
            }
            
            // Brand info
            if (product.getThuongHieu() != null) {
                Map<String, Object> brandInfo = new HashMap<>();
                brandInfo.put("id", product.getThuongHieu().getId());
                brandInfo.put("ten", product.getThuongHieu().getTen());
                productDTO.put("thuongHieu", brandInfo);
                log.info("Brand info added for product {}: {}", product.getId(), product.getThuongHieu().getTen());
            } else {
                log.warn("No brand info found for product {}", product.getId());
                // Add default brand info to prevent template errors
                Map<String, Object> defaultBrandInfo = new HashMap<>();
                defaultBrandInfo.put("id", 0L);
                defaultBrandInfo.put("ten", "Activewear Store");
                productDTO.put("thuongHieu", defaultBrandInfo);
            }
            
            // Sport info
            if (product.getMonTheThao() != null) {
                Map<String, Object> sportInfo = new HashMap<>();
                sportInfo.put("id", product.getMonTheThao().getId());
                sportInfo.put("ten", product.getMonTheThao().getTen());
                productDTO.put("monTheThao", sportInfo);
            } else {
                // Add default sport info to prevent template errors
                Map<String, Object> defaultSportInfo = new HashMap<>();
                defaultSportInfo.put("id", 0L);
                defaultSportInfo.put("ten", "Thể thao chung");
                productDTO.put("monTheThao", defaultSportInfo);
            }
            
            // Load images separately to avoid MultipleBagFetchException
            try {
                Optional<Product> productWithImages = productRepository.findByIdWithImages(id);
                if (productWithImages.isPresent()) {
                    List<Map<String, Object>> images = productWithImages.get().getAnhSanPhams().stream()
                        .map(image -> {
                            Map<String, Object> imageInfo = new HashMap<>();
                            imageInfo.put("id", image.getId());
                            imageInfo.put("urlAnh", image.getUrlAnh());
                            imageInfo.put("laAnhChinh", image.getLaAnhChinh());
                            imageInfo.put("thuTu", image.getThuTu());
                            return imageInfo;
                        })
                        .collect(Collectors.toList());
                    productDTO.put("anhSanPhams", images);
                }
            } catch (Exception e) {
                log.error("Error loading images for product {}", id, e);
                // Fallback: create basic image from main image
                List<Map<String, Object>> fallbackImages = new ArrayList<>();
                Map<String, Object> mainImage = new HashMap<>();
                mainImage.put("id", 1L);
                mainImage.put("urlAnh", product.getAnhChinh());
                mainImage.put("laAnhChinh", true);
                mainImage.put("thuTu", 1);
                fallbackImages.add(mainImage);
                productDTO.put("anhSanPhams", fallbackImages);
            }
            
            // Load variants separately
            try {
                Optional<Product> productWithVariants = productRepository.findByIdWithVariants(id);
                if (productWithVariants.isPresent()) {
                    List<Map<String, Object>> variants = productWithVariants.get().getBienTheSanPhams().stream()
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
                            return variantInfo;
                        })
                        .collect(Collectors.toList());
                    productDTO.put("bienTheSanPhams", variants);
                }
            } catch (Exception e) {
                log.error("Error loading variants for product {}", id, e);
                // Fallback: create mock variants
                List<Map<String, Object>> mockVariants = new ArrayList<>();
                Map<String, Object> variant1 = new HashMap<>();
                variant1.put("id", 1L);
                variant1.put("kichCo", "M");
                variant1.put("mauSac", "White");
                variant1.put("soLuong", 10);
                variant1.put("giaBan", product.getGia());
                variant1.put("trangThai", true);
                mockVariants.add(variant1);
                
                Map<String, Object> variant2 = new HashMap<>();
                variant2.put("id", 2L);
                variant2.put("kichCo", "L");
                variant2.put("mauSac", "White");
                variant2.put("soLuong", 5);
                variant2.put("giaBan", product.getGia());
                variant2.put("trangThai", true);
                mockVariants.add(variant2);
                
                productDTO.put("bienTheSanPhams", mockVariants);
            }
            
            return productDTO;
            
        } catch (Exception e) {
            log.error("Error getting product with full details for ID: {}", id, e);
            return null;
        }
    }
    
    /**
     * Get related products based on category and brand
     */
    public List<Map<String, Object>> getRelatedProducts(Long productId, int limit) {
        try {
            Optional<Product> productOpt = productRepository.findById(productId);
            if (productOpt.isEmpty()) {
                return new ArrayList<>();
            }
            
            Product product = productOpt.get();
            List<Product> relatedProducts = new ArrayList<>();
            
            // Get products from same category
            if (product.getDanhMuc() != null) {
                List<Product> categoryProducts = productRepository.findByDanhMucAndHoatDongTrueAndIdNot(product.getDanhMuc(), productId, PageRequest.of(0, limit));
                relatedProducts.addAll(categoryProducts);
            }
            
            // If not enough, get products from same brand
            if (relatedProducts.size() < limit && product.getThuongHieu() != null) {
                List<Product> brandProducts = productRepository.findByThuongHieuAndHoatDongTrueAndIdNot(product.getThuongHieu(), productId, PageRequest.of(0, limit - relatedProducts.size()));
                relatedProducts.addAll(brandProducts);
            }
            
            // If still not enough, get random products
            if (relatedProducts.size() < limit) {
                List<Product> randomProducts = productRepository.findRandomProducts(limit - relatedProducts.size());
                relatedProducts.addAll(randomProducts);
            }
            
            // Convert to DTOs
            return relatedProducts.stream()
                .map(p -> {
                    Map<String, Object> dto = new HashMap<>();
                    dto.put("id", p.getId());
                    dto.put("ten", p.getTen());
                    dto.put("gia", p.getGia());
                    dto.put("giaGoc", p.getGiaGoc());
                    dto.put("anhChinh", p.getAnhChinh());
                    dto.put("slug", p.getSlug());
                    return dto;
                })
                .collect(Collectors.toList());
                
        } catch (Exception e) {
            log.error("Error getting related products for product {}", productId, e);
            return new ArrayList<>();
        }
    }
    
    /**
     * Get mock reviews data
     */
    public List<Map<String, Object>> getMockReviews() {
        List<Map<String, Object>> reviews = new ArrayList<>();
        
        Map<String, Object> review1 = new HashMap<>();
        review1.put("id", 1L);
        review1.put("author", "Nguyễn Văn A");
        review1.put("rating", 5);
        review1.put("content", "Sản phẩm chất lượng tốt, giao hàng nhanh. Rất hài lòng!");
        review1.put("date", "2 ngày trước");
        review1.put("verified", true);
        reviews.add(review1);
        
        Map<String, Object> review2 = new HashMap<>();
        review2.put("id", 2L);
        review2.put("author", "Trần Thị B");
        review2.put("rating", 4);
        review2.put("content", "Áo đẹp, vải mát, mặc thoải mái. Sẽ mua lại!");
        review2.put("date", "1 tuần trước");
        review2.put("verified", true);
        reviews.add(review2);
        
        Map<String, Object> review3 = new HashMap<>();
        review3.put("id", 3L);
        review3.put("author", "Lê Văn C");
        review3.put("rating", 5);
        review3.put("content", "Chất lượng vượt mong đợi, đóng gói cẩn thận.");
        review3.put("date", "3 ngày trước");
        review3.put("verified", false);
        reviews.add(review3);
        
        return reviews;
    }
}
