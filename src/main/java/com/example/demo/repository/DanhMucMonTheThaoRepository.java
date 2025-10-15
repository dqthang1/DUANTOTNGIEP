package com.example.demo.repository;

import com.example.demo.entity.DanhMucMonTheThao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DanhMucMonTheThaoRepository extends JpaRepository<DanhMucMonTheThao, Long> {
    
    List<DanhMucMonTheThao> findByHoatDongTrue();
    
    List<DanhMucMonTheThao> findByHoatDongTrueOrderByThuTuAsc();
    
    Optional<DanhMucMonTheThao> findByTen(String ten);
    
    @Query("SELECT d FROM DanhMucMonTheThao d WHERE d.hoatDong = true AND " +
           "d.ten LIKE %:keyword% OR d.moTa LIKE %:keyword%")
    List<DanhMucMonTheThao> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT COUNT(p) FROM Product p WHERE p.monTheThao.id = :monTheThaoId")
    Long countProductsByMonTheThao(@Param("monTheThaoId") Long monTheThaoId);
}
