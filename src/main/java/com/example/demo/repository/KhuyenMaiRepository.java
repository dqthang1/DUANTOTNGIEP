package com.example.demo.repository;

import com.example.demo.entity.KhuyenMai;
import com.example.demo.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface KhuyenMaiRepository extends JpaRepository<KhuyenMai, Long> {
    
    // Tìm khuyến mãi đang hoạt động
    @Query("SELECT k FROM KhuyenMai k WHERE k.hoatDong = true " +
           "AND k.ngayBatDau <= :now AND k.ngayKetThuc >= :now " +
           "AND (k.soLuongToiDa IS NULL OR k.soLuongSuDung < k.soLuongToiDa)")
    List<KhuyenMai> findActivePromotions(@Param("now") LocalDateTime now);
    
    // Tìm khuyến mãi áp dụng cho sản phẩm qua bảng san_pham_khuyen_mai
    @Query("SELECT DISTINCT k FROM KhuyenMai k " +
           "JOIN SanPhamKhuyenMai spk ON spk.khuyenMai.id = k.id " +
           "WHERE k.hoatDong = true " +
           "AND k.ngayBatDau <= :now AND k.ngayKetThuc >= :now " +
           "AND (k.soLuongToiDa IS NULL OR k.soLuongSuDung < k.soLuongToiDa) " +
           "AND spk.sanPham.id = :productId " +
           "AND spk.hoatDong = true")
    List<KhuyenMai> findApplicablePromotions(
        @Param("productId") Long productId,
        @Param("now") LocalDateTime now
    );
    
    // Tìm kiếm khuyến mãi với filter
    @Query("SELECT k FROM KhuyenMai k WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR " +
           " LOWER(k.ten) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           " LOWER(k.moTa) LIKE LOWER(CONCAT('%', :keyword, '%'))) AND " +
           "(:status IS NULL OR k.hoatDong = :status) AND " +
           "(:loai IS NULL OR k.loai = :loai)")
    Page<KhuyenMai> findWithFilters(
        @Param("keyword") String keyword,
        @Param("status") Boolean status,
        @Param("loai") String loai,
        Pageable pageable
    );
    
    // Đếm khuyến mãi đang hoạt động
    @Query("SELECT COUNT(k) FROM KhuyenMai k WHERE k.hoatDong = true " +
           "AND k.ngayBatDau <= :now AND k.ngayKetThuc >= :now")
    long countActivePromotions(@Param("now") LocalDateTime now);
    
    // Tìm khuyến mãi sắp hết hạn (trong 7 ngày tới)
    @Query("SELECT k FROM KhuyenMai k WHERE k.hoatDong = true " +
           "AND k.ngayKetThuc BETWEEN :now AND :sevenDaysLater")
    List<KhuyenMai> findExpiringSoon(
        @Param("now") LocalDateTime now,
        @Param("sevenDaysLater") LocalDateTime sevenDaysLater
    );
    
    // Tìm khuyến mãi theo loại
    List<KhuyenMai> findByLoaiAndHoatDongTrue(String loai);
    
    // Kiểm tra tên khuyến mãi trùng lặp
    boolean existsByTenIgnoreCase(String ten);
}
