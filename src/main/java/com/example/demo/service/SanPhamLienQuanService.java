package com.example.demo.service;

import com.example.demo.dto.ProductResponse;
import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class SanPhamLienQuanService {
    
    private final SanPhamLienQuanRepository sanPhamLienQuanRepository;
    private final ProductRepository productRepository;
    private final ProductManagementService productManagementService;
    
    /**
     * Lấy sản phẩm liên quan theo sản phẩm gốc
     * TỰ ĐỘNG tìm theo quy tắc: cùng danh mục, brand, môn thể thao, khoảng giá
     */
    @Transactional(readOnly = true)
    public List<ProductResponse> getRelatedProducts(Long sanPhamGocId, int limit) {
        // Kiểm tra xem có sản phẩm liên quan đã được tạo thủ công/tự động chưa
        Page<SanPhamLienQuan> manualRelations = sanPhamLienQuanRepository
            .findBySanPhamGocIdOrderByWeight(sanPhamGocId, Pageable.ofSize(limit));
        
        List<ProductResponse> manualResults = manualRelations.stream()
            .filter(SanPhamLienQuan::isActive)
            .map(splq -> productManagementService.convertToResponse(splq.getSanPhamLienQuan()))
            .collect(Collectors.toList());
        
        // Nếu đã có đủ sản phẩm liên quan thủ công, return ngay
        if (manualResults.size() >= limit) {
            return manualResults;
        }
        
        // Nếu chưa có hoặc không đủ, tự động tìm theo quy tắc
        Optional<Product> productOpt = productRepository.findById(sanPhamGocId);
        if (productOpt.isEmpty()) {
            return manualResults;
        }
        
        Product sanPhamGoc = productOpt.get();
        Set<Long> existingIds = manualResults.stream()
            .map(ProductResponse::getId)
            .collect(Collectors.toSet());
        existingIds.add(sanPhamGocId); // Loại bỏ chính sản phẩm gốc
        
        List<ProductResponse> autoRelated = findAutoRelatedProducts(sanPhamGoc, limit - manualResults.size(), existingIds);
        
        // Kết hợp manual + auto
        List<ProductResponse> allRelated = new ArrayList<>(manualResults);
        allRelated.addAll(autoRelated);
        
        return allRelated;
    }
    
    /**
     * Tự động tìm sản phẩm liên quan theo quy tắc
     * Rule-based với fallback strategy
     */
    private List<ProductResponse> findAutoRelatedProducts(Product sanPhamGoc, int limit, Set<Long> excludeIds) {
        List<Product> candidates = new ArrayList<>();
        
        log.info("Finding auto related products for: {} (ID: {})", sanPhamGoc.getTen(), sanPhamGoc.getId());
        
        // 1. CÙNG DANH MỤC (Ưu tiên cao nhất)
        if (sanPhamGoc.getDanhMuc() != null && candidates.size() < limit) {
            List<Product> sameCategory = productRepository
                .findByDanhMucIdAndHoatDongTrueAndIdNot(sanPhamGoc.getDanhMuc().getId(), sanPhamGoc.getId())
                .stream()
                .filter(p -> !excludeIds.contains(p.getId()))
                .limit(limit - candidates.size())
                .collect(Collectors.toList());
            candidates.addAll(sameCategory);
            log.info("Found {} products with same category", sameCategory.size());
        }
        
        // 2. CÙNG THƯƠNG HIỆU (Nếu chưa đủ)
        if (sanPhamGoc.getThuongHieu() != null && candidates.size() < limit) {
            List<Product> sameBrand = productRepository
                .findByThuongHieuIdAndHoatDongTrueAndIdNot(sanPhamGoc.getThuongHieu().getId(), sanPhamGoc.getId())
                .stream()
                .filter(p -> !excludeIds.contains(p.getId()) && !containsProduct(candidates, p))
                .limit(limit - candidates.size())
                .collect(Collectors.toList());
            candidates.addAll(sameBrand);
            log.info("Found {} products with same brand", sameBrand.size());
        }
        
        // 3. CÙNG MÔN THỂ THAO (Nếu chưa đủ)
        if (sanPhamGoc.getMonTheThao() != null && candidates.size() < limit) {
            List<Product> sameSport = productRepository
                .findByMonTheThaoIdAndHoatDongTrueAndIdNot(sanPhamGoc.getMonTheThao().getId(), sanPhamGoc.getId())
                .stream()
                .filter(p -> !excludeIds.contains(p.getId()) && !containsProduct(candidates, p))
                .limit(limit - candidates.size())
                .collect(Collectors.toList());
            candidates.addAll(sameSport);
            log.info("Found {} products with same sport", sameSport.size());
        }
        
        // 4. GIÁ TƯƠNG TỰ (70%-130% giá gốc - Nếu chưa đủ)
        if (candidates.size() < limit) {
            BigDecimal minPrice = sanPhamGoc.getGia().multiply(new BigDecimal("0.7"));
            BigDecimal maxPrice = sanPhamGoc.getGia().multiply(new BigDecimal("1.3"));
            
            List<Product> similarPrice = productRepository
                .findByGiaBetweenAndHoatDongTrueAndIdNot(minPrice, maxPrice, sanPhamGoc.getId())
                .stream()
                .filter(p -> !excludeIds.contains(p.getId()) && !containsProduct(candidates, p))
                .limit(limit - candidates.size())
                .collect(Collectors.toList());
            candidates.addAll(similarPrice);
            log.info("Found {} products with similar price", similarPrice.size());
        }
        
        // 5. FALLBACK: Sản phẩm bán chạy/nổi bật/mới nhất (Nếu vẫn chưa đủ)
        if (candidates.size() < limit) {
            List<Product> fallbackProducts = productRepository
                .findByHoatDongTrue(Pageable.ofSize(limit - candidates.size()))
                .stream()
                .filter(p -> !excludeIds.contains(p.getId()) && !containsProduct(candidates, p) && !p.getId().equals(sanPhamGoc.getId()))
                .sorted((p1, p2) -> {
                    // Ưu tiên: noiBat > luotXem > mới nhất
                    if (p1.getNoiBat() && !p2.getNoiBat()) return -1;
                    if (!p1.getNoiBat() && p2.getNoiBat()) return 1;
                    
                    int viewCompare = Integer.compare(
                        p2.getLuotXem() != null ? p2.getLuotXem() : 0,
                        p1.getLuotXem() != null ? p1.getLuotXem() : 0
                    );
                    if (viewCompare != 0) return viewCompare;
                    
                    return p2.getNgayTao().compareTo(p1.getNgayTao());
                })
                .limit(limit - candidates.size())
                .collect(Collectors.toList());
            candidates.addAll(fallbackProducts);
            log.info("Added {} fallback products (featured/popular/new)", fallbackProducts.size());
        }
        
        log.info("Total auto related products found: {}", candidates.size());
        
        // Convert to ProductResponse
        return candidates.stream()
            .limit(limit)
            .map(productManagementService::convertToResponse)
            .collect(Collectors.toList());
    }
    
    /**
     * Kiểm tra xem product đã có trong list chưa
     */
    private boolean containsProduct(List<Product> products, Product product) {
        return products.stream().anyMatch(p -> p.getId().equals(product.getId()));
    }
    
    /**
     * Lấy sản phẩm liên quan theo loại
     */
    @Transactional(readOnly = true)
    public List<ProductResponse> getRelatedProductsByType(Long sanPhamGocId, 
                                                          String loai, 
                                                          int limit) {
        List<SanPhamLienQuan> relatedProducts = sanPhamLienQuanRepository
            .findBySanPhamGocIdAndLoai(sanPhamGocId, loai);
        
        return relatedProducts.stream()
            .filter(SanPhamLienQuan::isActive)
            .limit(limit)
            .map(splq -> productManagementService.convertToResponse(splq.getSanPhamLienQuan()))
            .collect(Collectors.toList());
    }
    
    /**
     * Tự động tạo sản phẩm liên quan dựa trên thuật toán
     */
    @Transactional
    public void generateRelatedProducts(Long sanPhamGocId) {
        Optional<Product> productOpt = productRepository.findById(sanPhamGocId);
        if (productOpt.isEmpty()) {
            throw new RuntimeException("Không tìm thấy sản phẩm với ID: " + sanPhamGocId);
        }
        
        Product sanPhamGoc = productOpt.get();
        
        // Xóa các sản phẩm liên quan tự động cũ (không phải thủ công)
        List<SanPhamLienQuan> existingAuto = sanPhamLienQuanRepository
            .findBySanPhamGocIdOrderByWeight(sanPhamGocId, Pageable.unpaged())
            .stream()
            .filter(splq -> splq.getTuDong() && !"MANUAL".equals(splq.getLoai()))
            .collect(Collectors.toList());
        
        sanPhamLienQuanRepository.deleteAll(existingAuto);
        
        // Tìm sản phẩm cùng danh mục
        if (sanPhamGoc.getDanhMuc() != null) {
            generateProductsByCategory(sanPhamGoc);
        }
        
        // Tìm sản phẩm cùng thương hiệu
        if (sanPhamGoc.getThuongHieu() != null) {
            generateProductsByBrand(sanPhamGoc);
        }
        
        // Tìm sản phẩm cùng môn thể thao
        if (sanPhamGoc.getMonTheThao() != null) {
            generateProductsBySport(sanPhamGoc);
        }
        
        // Tìm sản phẩm tương tự dựa trên giá
        generateProductsByPriceRange(sanPhamGoc);
        
        log.info("Generated related products for product ID: {}", sanPhamGocId);
    }
    
    /**
     * Tạo sản phẩm liên quan thủ công
     */
    @Transactional
    public SanPhamLienQuan createManualRelation(Long sanPhamGocId, Long sanPhamLienQuanId, 
                                               String loai, 
                                               Integer thuTu, String ghiChu) {
        // Kiểm tra sản phẩm gốc
        Product sanPhamGoc = productRepository.findById(sanPhamGocId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm gốc với ID: " + sanPhamGocId));
        
        // Kiểm tra sản phẩm liên quan
        Product sanPhamLienQuan = productRepository.findById(sanPhamLienQuanId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm liên quan với ID: " + sanPhamLienQuanId));
        
        // Kiểm tra không được liên quan với chính nó
        if (sanPhamGocId.equals(sanPhamLienQuanId)) {
            throw new RuntimeException("Sản phẩm không thể liên quan với chính nó!");
        }
        
        // Kiểm tra đã tồn tại
        if (sanPhamLienQuanRepository.existsBySanPhamGocIdAndSanPhamLienQuanId(sanPhamGocId, sanPhamLienQuanId)) {
            throw new RuntimeException("Sản phẩm liên quan đã tồn tại!");
        }
        
        // Tạo sản phẩm liên quan
        SanPhamLienQuan relation = new SanPhamLienQuan();
        relation.setSanPhamGoc(sanPhamGoc);
        relation.setSanPhamLienQuan(sanPhamLienQuan);
        relation.setLoai(loai);
        relation.setThuTu(thuTu != null ? thuTu : 1);
        relation.setTuDong(false); // Thủ công
        relation.setDoLienQuan(BigDecimal.valueOf(1.0)); // Độ liên quan cao cho thủ công
        relation.setNgayThem(LocalDateTime.now());
        
        SanPhamLienQuan savedRelation = sanPhamLienQuanRepository.save(relation);
        
        log.info("Created manual relation: {} -> {} (type: {})", 
                sanPhamGocId, sanPhamLienQuanId, loai);
        
        return savedRelation;
    }
    
    /**
     * Xóa sản phẩm liên quan
     */
    @Transactional
    public void deleteRelation(Long relationId) {
        SanPhamLienQuan relation = sanPhamLienQuanRepository.findById(relationId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm liên quan với ID: " + relationId));
        
        sanPhamLienQuanRepository.delete(relation);
        
        log.info("Deleted relation with ID: {}", relationId);
    }
    
    /**
     * Tìm kiếm sản phẩm liên quan với filter (cho admin)
     */
    @Transactional(readOnly = true)
    public Page<SanPhamLienQuan> searchRelations(Long sanPhamGocId, 
                                                  String loai, 
                                                  Pageable pageable) {
        return sanPhamLienQuanRepository.findWithFilters(sanPhamGocId, loai, pageable);
    }
    
    // Helper methods for auto-generation
    
    private void generateProductsByCategory(Product sanPhamGoc) {
        List<Product> sameCategoryProducts = productRepository
            .findByDanhMucIdAndHoatDongTrueAndIdNot(sanPhamGoc.getDanhMuc().getId(), sanPhamGoc.getId());
        
        int count = 0;
        for (Product product : sameCategoryProducts) {
            if (count >= 5) break; // Giới hạn 5 sản phẩm cùng danh mục
            
            if (!sanPhamLienQuanRepository.existsBySanPhamGocIdAndSanPhamLienQuanId(
                    sanPhamGoc.getId(), product.getId())) {
                
                SanPhamLienQuan relation = new SanPhamLienQuan();
                relation.setSanPhamGoc(sanPhamGoc);
                relation.setSanPhamLienQuan(product);
                relation.setLoai("CUNG_DANH_MUC");
                relation.setThuTu(1);
                relation.setTuDong(true);
                relation.setDoLienQuan(BigDecimal.valueOf(0.8));
                relation.setNgayThem(LocalDateTime.now());
                
                sanPhamLienQuanRepository.save(relation);
                count++;
            }
        }
    }
    
    private void generateProductsByBrand(Product sanPhamGoc) {
        List<Product> sameBrandProducts = productRepository
            .findByThuongHieuIdAndHoatDongTrueAndIdNot(sanPhamGoc.getThuongHieu().getId(), sanPhamGoc.getId());
        
        int count = 0;
        for (Product product : sameBrandProducts) {
            if (count >= 3) break; // Giới hạn 3 sản phẩm cùng thương hiệu
            
            if (!sanPhamLienQuanRepository.existsBySanPhamGocIdAndSanPhamLienQuanId(
                    sanPhamGoc.getId(), product.getId())) {
                
                SanPhamLienQuan relation = new SanPhamLienQuan();
                relation.setSanPhamGoc(sanPhamGoc);
                relation.setSanPhamLienQuan(product);
                relation.setLoai("CUNG_THUONG_HIEU");
                relation.setThuTu(1);
                relation.setTuDong(true);
                relation.setDoLienQuan(BigDecimal.valueOf(0.7));
                relation.setNgayThem(LocalDateTime.now());
                
                sanPhamLienQuanRepository.save(relation);
                count++;
            }
        }
    }
    
    private void generateProductsBySport(Product sanPhamGoc) {
        List<Product> sameSportProducts = productRepository
            .findByMonTheThaoIdAndHoatDongTrueAndIdNot(sanPhamGoc.getMonTheThao().getId(), sanPhamGoc.getId());
        
        int count = 0;
        for (Product product : sameSportProducts) {
            if (count >= 3) break; // Giới hạn 3 sản phẩm cùng môn thể thao
            
            if (!sanPhamLienQuanRepository.existsBySanPhamGocIdAndSanPhamLienQuanId(
                    sanPhamGoc.getId(), product.getId())) {
                
                SanPhamLienQuan relation = new SanPhamLienQuan();
                relation.setSanPhamGoc(sanPhamGoc);
                relation.setSanPhamLienQuan(product);
                relation.setLoai("CUNG_MON_THE_THAO");
                relation.setThuTu(1);
                relation.setTuDong(true);
                relation.setDoLienQuan(BigDecimal.valueOf(0.6));
                relation.setNgayThem(LocalDateTime.now());
                
                sanPhamLienQuanRepository.save(relation);
                count++;
            }
        }
    }
    
    private void generateProductsByPriceRange(Product sanPhamGoc) {
        BigDecimal minPrice = sanPhamGoc.getGia().multiply(new BigDecimal("0.7")); // 70% giá
        BigDecimal maxPrice = sanPhamGoc.getGia().multiply(new BigDecimal("1.3")); // 130% giá
        
        List<Product> similarPriceProducts = productRepository
            .findByGiaBetweenAndHoatDongTrueAndIdNot(minPrice, maxPrice, sanPhamGoc.getId());
        
        int count = 0;
        for (Product product : similarPriceProducts) {
            if (count >= 2) break; // Giới hạn 2 sản phẩm tương tự giá
            
            if (!sanPhamLienQuanRepository.existsBySanPhamGocIdAndSanPhamLienQuanId(
                    sanPhamGoc.getId(), product.getId())) {
                
                SanPhamLienQuan relation = new SanPhamLienQuan();
                relation.setSanPhamGoc(sanPhamGoc);
                relation.setSanPhamLienQuan(product);
                relation.setLoai("TUONG_TU");
                relation.setThuTu(1);
                relation.setTuDong(true);
                relation.setDoLienQuan(BigDecimal.valueOf(0.5));
                relation.setNgayThem(LocalDateTime.now());
                
                sanPhamLienQuanRepository.save(relation);
                count++;
            }
        }
    }
}
