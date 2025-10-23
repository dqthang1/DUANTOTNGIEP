package com.example.demo.repository;

import com.example.demo.entity.SanPhamKhuyenMai;
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
public interface SanPhamKhuyenMaiRepository extends JpaRepository<SanPhamKhuyenMai, Long> {
    
    // Tìm khuyến mãi đang hoạt động cho sản phẩm
    @Query("SELECT spk FROM SanPhamKhuyenMai spk " +
           "WHERE spk.sanPham.id = :sanPhamId " +
           "AND spk.hoatDong = true " +
           "AND spk.khuyenMai.hoatDong = true " +
           "AND spk.ngayBatDau <= :now AND spk.ngayKetThuc >= :now " +
           "AND spk.khuyenMai.ngayBatDau <= :now AND spk.khuyenMai.ngayKetThuc >= :now " +
           "AND (spk.khuyenMai.soLuongToiDa IS NULL OR spk.khuyenMai.soLuongSuDung < spk.khuyenMai.soLuongToiDa)")
    List<SanPhamKhuyenMai> findActivePromotionsForProduct(
        @Param("sanPhamId") Long sanPhamId,
        @Param("now") LocalDateTime now
    );
    
    // Tìm tất cả khuyến mãi cho sản phẩm
    @Query("SELECT spk FROM SanPhamKhuyenMai spk " +
           "WHERE spk.sanPham.id = :sanPhamId " +
           "ORDER BY spk.ngayTao DESC")
    List<SanPhamKhuyenMai> findBySanPhamId(@Param("sanPhamId") Long sanPhamId);
    
    // Tìm tất cả sản phẩm áp dụng khuyến mãi
    @Query("SELECT spk FROM SanPhamKhuyenMai spk " +
           "WHERE spk.khuyenMai.id = :khuyenMaiId " +
           "ORDER BY spk.ngayTao DESC")
    List<SanPhamKhuyenMai> findByKhuyenMaiId(@Param("khuyenMaiId") Long khuyenMaiId);
    
    // Tìm kiếm với filter
    @Query("SELECT spk FROM SanPhamKhuyenMai spk " +
           "WHERE (:sanPhamId IS NULL OR spk.sanPham.id = :sanPhamId) " +
           "AND (:khuyenMaiId IS NULL OR spk.khuyenMai.id = :khuyenMaiId) " +
           "AND (:hoatDong IS NULL OR spk.hoatDong = :hoatDong)")
    Page<SanPhamKhuyenMai> findWithFilters(
        @Param("sanPhamId") Long sanPhamId,
        @Param("khuyenMaiId") Long khuyenMaiId,
        @Param("hoatDong") Boolean hoatDong,
        Pageable pageable
    );
    
    // Kiểm tra sản phẩm đã có khuyến mãi chưa
    boolean existsBySanPhamIdAndKhuyenMaiId(Long sanPhamId, Long khuyenMaiId);
    
    // Xóa khuyến mãi cho sản phẩm
    void deleteBySanPhamIdAndKhuyenMaiId(Long sanPhamId, Long khuyenMaiId);
    
    // Xóa tất cả khuyến mãi của sản phẩm
    void deleteBySanPhamId(Long sanPhamId);
    
    // Xóa tất cả sản phẩm của khuyến mãi
    void deleteByKhuyenMaiId(Long khuyenMaiId);
    
    // Đếm số sản phẩm áp dụng khuyến mãi
    long countByKhuyenMaiId(Long khuyenMaiId);
    
    // Đếm số khuyến mãi của sản phẩm
    long countBySanPhamId(Long sanPhamId);
}

