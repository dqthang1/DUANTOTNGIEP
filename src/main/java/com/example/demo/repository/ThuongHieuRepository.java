package com.example.demo.repository;

import com.example.demo.entity.ThuongHieu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ThuongHieuRepository extends JpaRepository<ThuongHieu, Long> {
    
    List<ThuongHieu> findByHoatDongTrueOrderByTen();
    
    Optional<ThuongHieu> findByTenIgnoreCase(String ten);
    
    boolean existsByTenIgnoreCase(String ten);
    
    @Query("SELECT t FROM ThuongHieu t WHERE t.hoatDong = true ORDER BY t.ten")
    List<ThuongHieu> findAllActiveOrderByTen();
}