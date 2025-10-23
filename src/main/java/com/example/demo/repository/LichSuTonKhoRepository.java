package com.example.demo.repository;

import com.example.demo.entity.LichSuTonKho;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface LichSuTonKhoRepository extends JpaRepository<LichSuTonKho, Long> {
    
    // Lấy lịch sử theo sản phẩm
    Page<LichSuTonKho> findBySanPhamIdOrderByNgayThayDoiDesc(Long sanPhamId, Pageable pageable);
    
    // Lấy lịch sử theo loại thay đổi
    Page<LichSuTonKho> findByLoaiThayDoiOrderByNgayThayDoiDesc(String loaiThayDoi, Pageable pageable);
    
    // Lấy lịch sử theo khoảng thời gian
    @Query("SELECT l FROM LichSuTonKho l WHERE l.ngayThayDoi BETWEEN :startDate AND :endDate ORDER BY l.ngayThayDoi DESC")
    Page<LichSuTonKho> findByDateRange(
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate,
        Pageable pageable
    );
    
    // Lấy lịch sử theo sản phẩm và thời gian
    @Query("SELECT l FROM LichSuTonKho l WHERE l.sanPham.id = :sanPhamId " +
           "AND l.ngayThayDoi BETWEEN :startDate AND :endDate " +
           "ORDER BY l.ngayThayDoi DESC")
    List<LichSuTonKho> findBySanPhamIdAndDateRange(
        @Param("sanPhamId") Long sanPhamId,
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
    
    // Thống kê tổng số lượng thay đổi theo loại
    @Query("SELECT l.loaiThayDoi, SUM(l.soLuongThayDoi) FROM LichSuTonKho l " +
           "WHERE l.ngayThayDoi BETWEEN :startDate AND :endDate " +
           "GROUP BY l.loaiThayDoi")
    List<Object[]> sumByLoaiThayDoiAndDateRange(
        @Param("startDate") LocalDateTime startDate,
        @Param("endDate") LocalDateTime endDate
    );
}


