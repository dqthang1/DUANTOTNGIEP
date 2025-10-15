package com.example.demo.repository;

import com.example.demo.entity.AnhSanPham;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnhSanPhamRepository extends JpaRepository<AnhSanPham, Long> {
    
    List<AnhSanPham> findBySanPhamIdOrderByThuTuAsc(Long sanPhamId);
    
    @Query("SELECT a FROM AnhSanPham a WHERE a.sanPham.id = :sanPhamId ORDER BY a.thuTu ASC")
    List<AnhSanPham> findBySanPhamIdWithOrder(@Param("sanPhamId") Long sanPhamId);
    
    @Modifying
    @Query("DELETE FROM AnhSanPham a WHERE a.sanPham.id = :sanPhamId")
    void deleteBySanPhamId(@Param("sanPhamId") Long sanPhamId);
    
    @Query("SELECT COUNT(a) FROM AnhSanPham a WHERE a.sanPham.id = :sanPhamId")
    Long countBySanPhamId(@Param("sanPhamId") Long sanPhamId);
}
