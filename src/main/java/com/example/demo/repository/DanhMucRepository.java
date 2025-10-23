package com.example.demo.repository;

import com.example.demo.entity.DanhMuc;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DanhMucRepository extends JpaRepository<DanhMuc, Long> {
    
    List<DanhMuc> findByHoatDongTrueOrderByTen();
    
    List<DanhMuc> findByHoatDongTrueOrderByThuTuAsc();
    
    Optional<DanhMuc> findByTenIgnoreCase(String ten);
    
    boolean existsByTenIgnoreCase(String ten);
    
    long countByHoatDongTrue();
    
    @Query("SELECT d FROM DanhMuc d WHERE d.hoatDong = true ORDER BY d.ten")
    List<DanhMuc> findAllActiveOrderByTen();
}