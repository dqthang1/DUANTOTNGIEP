package com.example.demo.repository;

import com.example.demo.entity.Order;
import com.example.demo.entity.User;
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
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    Optional<Order> findByMaDonHang(String maDonHang);
    
    @Query("SELECT DISTINCT o FROM Order o " +
           "LEFT JOIN FETCH o.nguoiDung " +
           "LEFT JOIN FETCH o.orderItems oi " +
           "LEFT JOIN FETCH oi.sanPham " +
           "WHERE o.id = :orderId")
    Optional<Order> findByIdWithItems(@Param("orderId") Long orderId);
    
    @Query("SELECT DISTINCT o FROM Order o " +
           "LEFT JOIN FETCH o.nguoiDung " +
           "LEFT JOIN FETCH o.orderItems oi " +
           "LEFT JOIN FETCH oi.sanPham " +
           "WHERE o.maDonHang = :orderCode")
    Optional<Order> findByMaDonHangWithItems(@Param("orderCode") String orderCode);
    
    List<Order> findByNguoiDung(User user);
    
    List<Order> findByNguoiDungId(Long userId);
    
    @Query("SELECT DISTINCT o FROM Order o " +
           "LEFT JOIN FETCH o.nguoiDung " +
           "LEFT JOIN FETCH o.orderItems oi " +
           "LEFT JOIN FETCH oi.sanPham " +
           "WHERE o.nguoiDung.id = :userId " +
           "ORDER BY o.ngayDatHang DESC")
    List<Order> findByNguoiDungIdWithItems(@Param("userId") Long userId);
    
    Page<Order> findByNguoiDungIdOrderByNgayDatHangDesc(Long userId, Pageable pageable);
    
    List<Order> findByTrangThai(String trangThai);
    
    @Query("SELECT o FROM Order o WHERE o.nguoiDung.id = :userId AND o.trangThai = :status")
    List<Order> findByUserAndStatus(@Param("userId") Long userId, @Param("status") String status);
    
    @Query("SELECT o FROM Order o WHERE o.ngayDatHang BETWEEN :startDate AND :endDate")
    List<Order> findByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT COUNT(o) FROM Order o WHERE o.trangThai = :status")
    Long countByStatus(@Param("status") String status);
    
    @Query("SELECT SUM(o.tongTien) FROM Order o WHERE o.trangThai = 'DA_GIAO'")
    Double getTotalRevenue();
    
    @Query("SELECT SUM(o.tongTien) FROM Order o WHERE o.trangThai = 'DA_GIAO' AND o.ngayDatHang >= :startDate")
    Double getRevenueFromDate(@Param("startDate") LocalDateTime startDate);
}
