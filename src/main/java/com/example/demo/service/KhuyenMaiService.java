package com.example.demo.service;

import com.example.demo.dto.KhuyenMaiCreateRequest;
import com.example.demo.dto.KhuyenMaiResponse;
import com.example.demo.entity.KhuyenMai;
import com.example.demo.entity.Product;
import com.example.demo.entity.SanPhamKhuyenMai;
import com.example.demo.repository.KhuyenMaiRepository;
import com.example.demo.repository.ProductRepository;
import com.example.demo.repository.SanPhamKhuyenMaiRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class KhuyenMaiService {
    
    private final KhuyenMaiRepository khuyenMaiRepository;
    private final SanPhamKhuyenMaiRepository sanPhamKhuyenMaiRepository;
    private final ProductRepository productRepository;
    
    /**
     * Tìm kiếm khuyến mãi với filter
     */
    @Transactional(readOnly = true)
    public Page<KhuyenMaiResponse> searchPromotions(String keyword, Boolean status, 
                                                   String loai, 
                                                   Pageable pageable) {
        Page<KhuyenMai> promotions = khuyenMaiRepository.findWithFilters(
            keyword, status, loai, pageable);
        
        return promotions.map(this::convertToResponse);
    }
    
    /**
     * Lấy khuyến mãi theo ID
     */
    @Transactional(readOnly = true)
    public KhuyenMaiResponse getPromotionById(Long id) {
        KhuyenMai promotion = khuyenMaiRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy khuyến mãi với ID: " + id));
        
        return convertToResponse(promotion);
    }
    
    /**
     * Tạo khuyến mãi mới
     */
    @Transactional
    public KhuyenMaiResponse createPromotion(KhuyenMaiCreateRequest request) {
        // Validate business rules
        validatePromotionRequest(request);
        
        // Tạo entity
        KhuyenMai promotion = new KhuyenMai();
        promotion.setTen(request.getTen());
        promotion.setMoTa(request.getMoTa());
        promotion.setLoai(request.getLoai());
        promotion.setGiaTri(request.getGiaTri());
        promotion.setNgayBatDau(request.getNgayBatDau());
        promotion.setNgayKetThuc(request.getNgayKetThuc());
        promotion.setSoLuongSuDung(request.getSoLuongSuDung() != null ? request.getSoLuongSuDung() : 0);
        promotion.setSoLuongToiDa(request.getSoLuongToiDa());
        promotion.setHoatDong(request.getHoatDong());
        promotion.setNguoiTao(request.getNguoiTao());
        promotion.setNgayTao(LocalDateTime.now());
        
        // Lưu khuyến mãi
        KhuyenMai savedPromotion = khuyenMaiRepository.save(promotion);
        
        // Thêm sản phẩm áp dụng qua bảng san_pham_khuyen_mai
        if (request.getSanPhamIds() != null && !request.getSanPhamIds().isEmpty()) {
            List<Product> products = productRepository.findAllById(request.getSanPhamIds());
            for (Product product : products) {
                SanPhamKhuyenMai sanPhamKhuyenMai = new SanPhamKhuyenMai();
                sanPhamKhuyenMai.setSanPham(product);
                sanPhamKhuyenMai.setKhuyenMai(savedPromotion);
                sanPhamKhuyenMai.setNgayBatDau(request.getNgayBatDau());
                sanPhamKhuyenMai.setNgayKetThuc(request.getNgayKetThuc());
                sanPhamKhuyenMai.setHoatDong(true);
                sanPhamKhuyenMai.setNguoiTao(request.getNguoiTao());
                sanPhamKhuyenMai.setNgayTao(LocalDateTime.now());
                
                sanPhamKhuyenMaiRepository.save(sanPhamKhuyenMai);
            }
        }
        
        log.info("Created promotion: {} with ID: {}", savedPromotion.getTen(), savedPromotion.getId());
        
        return convertToResponse(savedPromotion);
    }
    
    /**
     * Cập nhật khuyến mãi
     */
    @Transactional
    public KhuyenMaiResponse updatePromotion(Long id, KhuyenMaiCreateRequest request) {
        KhuyenMai promotion = khuyenMaiRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy khuyến mãi với ID: " + id));
        
        // Validate business rules
        validatePromotionRequest(request);
        
        // Cập nhật thông tin
        promotion.setTen(request.getTen());
        promotion.setMoTa(request.getMoTa());
        promotion.setLoai(request.getLoai());
        promotion.setGiaTri(request.getGiaTri());
        promotion.setNgayBatDau(request.getNgayBatDau());
        promotion.setNgayKetThuc(request.getNgayKetThuc());
        promotion.setSoLuongSuDung(request.getSoLuongSuDung() != null ? request.getSoLuongSuDung() : 0);
        promotion.setSoLuongToiDa(request.getSoLuongToiDa());
        promotion.setHoatDong(request.getHoatDong());
        promotion.setNguoiCapNhat(request.getNguoiTao()); // Sử dụng nguoiTao làm nguoiCapNhat
        promotion.setNgayCapNhat(LocalDateTime.now());
        
        // Cập nhật relationships qua bảng san_pham_khuyen_mai
        if (request.getSanPhamIds() != null) {
            // Xóa các sản phẩm cũ
            sanPhamKhuyenMaiRepository.deleteByKhuyenMaiId(id);
            
            // Thêm sản phẩm mới
            if (!request.getSanPhamIds().isEmpty()) {
                List<Product> products = productRepository.findAllById(request.getSanPhamIds());
                for (Product product : products) {
                    SanPhamKhuyenMai sanPhamKhuyenMai = new SanPhamKhuyenMai();
                    sanPhamKhuyenMai.setSanPham(product);
                    sanPhamKhuyenMai.setKhuyenMai(promotion);
                    sanPhamKhuyenMai.setNgayBatDau(request.getNgayBatDau());
                    sanPhamKhuyenMai.setNgayKetThuc(request.getNgayKetThuc());
                    sanPhamKhuyenMai.setHoatDong(true);
                    sanPhamKhuyenMai.setNguoiTao(request.getNguoiTao());
                    sanPhamKhuyenMai.setNgayTao(LocalDateTime.now());
                    
                    sanPhamKhuyenMaiRepository.save(sanPhamKhuyenMai);
                }
            }
        }
        
        // Lưu khuyến mãi
        KhuyenMai savedPromotion = khuyenMaiRepository.save(promotion);
        
        log.info("Updated promotion: {} with ID: {}", savedPromotion.getTen(), savedPromotion.getId());
        
        return convertToResponse(savedPromotion);
    }
    
    /**
     * Xóa khuyến mãi
     */
    @Transactional
    public void deletePromotion(Long id) {
        KhuyenMai promotion = khuyenMaiRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy khuyến mãi với ID: " + id));
        
        // Kiểm tra xem khuyến mãi có đang được sử dụng không
        if (promotion.getSoLuongSuDung() > 0) {
            throw new RuntimeException("Không thể xóa khuyến mãi đã được sử dụng!");
        }
        
        khuyenMaiRepository.delete(promotion);
        
        log.info("Deleted promotion with ID: {}", id);
    }
    
    /**
     * Toggle trạng thái khuyến mãi
     */
    @Transactional
    public void togglePromotionStatus(Long id) {
        KhuyenMai promotion = khuyenMaiRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy khuyến mãi với ID: " + id));
        
        promotion.setHoatDong(!promotion.getHoatDong());
        promotion.setNgayCapNhat(LocalDateTime.now());
        khuyenMaiRepository.save(promotion);
        
        log.info("Toggled promotion status for ID: {} to {}", id, promotion.getHoatDong());
    }
    
    /**
     * Lấy khuyến mãi áp dụng cho sản phẩm
     */
    @Transactional(readOnly = true)
    public List<KhuyenMaiResponse> getApplicablePromotions(Product product) {
        List<SanPhamKhuyenMai> sanPhamKhuyenMais = sanPhamKhuyenMaiRepository
            .findActivePromotionsForProduct(product.getId(), LocalDateTime.now());
        
        return sanPhamKhuyenMais.stream()
            .map(spk -> convertToResponse(spk.getKhuyenMai()))
            .collect(Collectors.toList());
    }
    
    /**
     * Tính giá sau khi áp dụng khuyến mãi
     */
    public BigDecimal calculateDiscountedPrice(Product product, String maKhuyenMai) {
        // Tìm khuyến mãi qua bảng san_pham_khuyen_mai
        List<SanPhamKhuyenMai> sanPhamKhuyenMais = sanPhamKhuyenMaiRepository
            .findActivePromotionsForProduct(product.getId(), LocalDateTime.now());
        
        if (sanPhamKhuyenMais.isEmpty()) {
            return product.getGia();
        }
        
        // Lấy khuyến mãi tốt nhất
        SanPhamKhuyenMai bestPromotion = sanPhamKhuyenMais.stream()
            .max((p1, p2) -> {
                BigDecimal discount1 = p1.calculateFinalPrice();
                BigDecimal discount2 = p2.calculateFinalPrice();
                return discount1.compareTo(discount2);
            })
            .orElse(sanPhamKhuyenMais.get(0));
        
        return bestPromotion.calculateFinalPrice();
    }
    
    /**
     * Validate khuyến mãi request
     */
    private void validatePromotionRequest(KhuyenMaiCreateRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("Request không được null");
        }
        
        if (!request.isValidDateRange()) {
            throw new RuntimeException("Ngày kết thúc phải sau ngày bắt đầu!");
        }
        
        if (!request.isValidDiscountValue()) {
            throw new RuntimeException("Giá trị khuyến mãi không hợp lệ!");
        }
        
        // Kiểm tra tên khuyến mãi trùng lặp
        if (khuyenMaiRepository.existsByTenIgnoreCase(request.getTen())) {
            throw new RuntimeException("Tên khuyến mãi đã tồn tại!");
        }
    }
    
    
    /**
     * Convert KhuyenMai entity to KhuyenMaiResponse DTO
     */
    private KhuyenMaiResponse convertToResponse(KhuyenMai promotion) {
        KhuyenMaiResponse response = new KhuyenMaiResponse();
        response.setId(promotion.getId());
        response.setTen(promotion.getTen());
        response.setMoTa(promotion.getMoTa());
        response.setLoai(promotion.getLoai());
        response.setGiaTri(promotion.getGiaTri());
        response.setNgayBatDau(promotion.getNgayBatDau());
        response.setNgayKetThuc(promotion.getNgayKetThuc());
        response.setSoLuongSuDung(promotion.getSoLuongSuDung());
        response.setSoLuongToiDa(promotion.getSoLuongToiDa());
        response.setHoatDong(promotion.getHoatDong());
        response.setNguoiTao(promotion.getNguoiTao());
        response.setNguoiCapNhat(promotion.getNguoiCapNhat());
        response.setNgayTao(promotion.getNgayTao());
        response.setNgayCapNhat(promotion.getNgayCapNhat());
        
        // Get products through SanPhamKhuyenMai
        List<SanPhamKhuyenMai> sanPhamKhuyenMais = sanPhamKhuyenMaiRepository.findByKhuyenMaiId(promotion.getId());
        if (!sanPhamKhuyenMais.isEmpty()) {
            List<KhuyenMaiResponse.ProductSummaryDto> sanPhams = sanPhamKhuyenMais.stream()
                .map(spk -> {
                    KhuyenMaiResponse.ProductSummaryDto dto = new KhuyenMaiResponse.ProductSummaryDto();
                    dto.setId(spk.getSanPham().getId());
                    dto.setTen(spk.getSanPham().getTen());
                    dto.setMaSanPham(spk.getSanPham().getMaSanPham());
                    return dto;
                })
                .collect(Collectors.toList());
            response.setSanPhams(sanPhams);
        }
        
        // Calculate status
        response.calculateStatus();
        
        return response;
    }
}
