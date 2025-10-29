package com.example.demo.repository;

import com.example.demo.entity.Banner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BannerRepository extends JpaRepository<Banner, Long> {
    
    List<Banner> findByHoatDongTrueOrderByThuTuAsc();
    
    List<Banner> findByViTriAndHoatDongTrueOrderByThuTuAsc(String viTri);
    
    @Query("SELECT b FROM Banner b WHERE b.hoatDong = true AND b.viTri = :viTri ORDER BY b.thuTu ASC")
    List<Banner> findActiveBannersByPosition(@Param("viTri") String viTri);
}
