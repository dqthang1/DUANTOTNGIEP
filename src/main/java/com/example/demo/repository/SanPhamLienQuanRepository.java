package com.example.demo.repository;

import com.example.demo.entity.Product;
import com.example.demo.entity.SanPhamLienQuan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SanPhamLienQuanRepository extends JpaRepository<SanPhamLienQuan, Long> {
    
    // Tìm sản phẩm liên quan của một sản phẩm
    @Query("SELECT splq FROM SanPhamLienQuan splq " +
           "WHERE splq.sanPhamGoc.id = :sanPhamGocId " +
           "AND splq.sanPhamLienQuan.hoatDong = true " +
           "ORDER BY splq.thuTu DESC, splq.doLienQuan DESC")
    List<SanPhamLienQuan> findBySanPhamGocIdOrderByWeight(@Param("sanPhamGocId") Long sanPhamGocId);
    
    // Tìm sản phẩm liên quan với giới hạn số lượng
    @Query("SELECT splq FROM SanPhamLienQuan splq " +
           "WHERE splq.sanPhamGoc.id = :sanPhamGocId " +
           "AND splq.sanPhamLienQuan.hoatDong = true " +
           "ORDER BY splq.thuTu DESC, splq.doLienQuan DESC")
    Page<SanPhamLienQuan> findBySanPhamGocIdOrderByWeight(@Param("sanPhamGocId") Long sanPhamGocId, Pageable pageable);
    
    // Tìm sản phẩm liên quan theo loại
    @Query("SELECT splq FROM SanPhamLienQuan splq " +
           "WHERE splq.sanPhamGoc.id = :sanPhamGocId " +
           "AND splq.loai = :loai " +
           "AND splq.sanPhamLienQuan.hoatDong = true " +
           "ORDER BY splq.thuTu DESC")
    List<SanPhamLienQuan> findBySanPhamGocIdAndLoai(
        @Param("sanPhamGocId") Long sanPhamGocId,
        @Param("loai") String loai
    );
    
    // Kiểm tra sản phẩm liên quan đã tồn tại
    @Query("SELECT COUNT(splq) > 0 FROM SanPhamLienQuan splq " +
           "WHERE splq.sanPhamGoc.id = :sanPhamGocId " +
           "AND splq.sanPhamLienQuan.id = :sanPhamLienQuanId")
    boolean existsBySanPhamGocIdAndSanPhamLienQuanId(
        @Param("sanPhamGocId") Long sanPhamGocId,
        @Param("sanPhamLienQuanId") Long sanPhamLienQuanId
    );
    
    // Tìm tất cả sản phẩm liên quan (cho admin)
    @Query("SELECT splq FROM SanPhamLienQuan splq " +
           "WHERE (:sanPhamGocId IS NULL OR splq.sanPhamGoc.id = :sanPhamGocId) " +
           "AND (:loai IS NULL OR splq.loai = :loai)")
    Page<SanPhamLienQuan> findWithFilters(
        @Param("sanPhamGocId") Long sanPhamGocId,
        @Param("loai") String loai,
        Pageable pageable
    );
    
    // Xóa sản phẩm liên quan theo sản phẩm gốc
    void deleteBySanPhamGocId(Long sanPhamGocId);
    
    // Xóa sản phẩm liên quan theo sản phẩm liên quan
    void deleteBySanPhamLienQuanId(Long sanPhamLienQuanId);
    
    // Đếm số lượng sản phẩm liên quan
    long countBySanPhamGocId(Long sanPhamGocId);
    
    // Tìm sản phẩm được liên quan đến sản phẩm khác
    @Query("SELECT splq FROM SanPhamLienQuan splq " +
           "WHERE splq.sanPhamLienQuan.id = :sanPhamId")
    List<SanPhamLienQuan> findBySanPhamLienQuanId(@Param("sanPhamId") Long sanPhamId);
}
