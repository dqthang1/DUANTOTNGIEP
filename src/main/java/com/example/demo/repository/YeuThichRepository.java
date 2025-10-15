package com.example.demo.repository;

import com.example.demo.entity.YeuThich;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface YeuThichRepository extends JpaRepository<YeuThich, Long> {
    
    @Query("SELECT y FROM YeuThich y WHERE y.nguoiDung.id = :nguoiDungId ORDER BY y.ngayThem DESC")
    List<YeuThich> findByNguoiDungIdOrderByNgayThemDesc(@Param("nguoiDungId") Long nguoiDungId);
    
    @Query("SELECT y FROM YeuThich y WHERE y.nguoiDung.id = :nguoiDungId AND y.sanPham.id = :sanPhamId")
    Optional<YeuThich> findByNguoiDungIdAndSanPhamId(@Param("nguoiDungId") Long nguoiDungId, @Param("sanPhamId") Long sanPhamId);
    
    @Query("SELECT COUNT(y) > 0 FROM YeuThich y WHERE y.nguoiDung.id = :nguoiDungId AND y.sanPham.id = :sanPhamId")
    boolean existsByNguoiDungIdAndSanPhamId(@Param("nguoiDungId") Long nguoiDungId, @Param("sanPhamId") Long sanPhamId);
    
    @Query("DELETE FROM YeuThich y WHERE y.nguoiDung.id = :nguoiDungId AND y.sanPham.id = :sanPhamId")
    void deleteByNguoiDungIdAndSanPhamId(@Param("nguoiDungId") Long nguoiDungId, @Param("sanPhamId") Long sanPhamId);
    
    @Query("SELECT COUNT(y) FROM YeuThich y WHERE y.sanPham.id = :sanPhamId")
    Long countBySanPhamId(@Param("sanPhamId") Long sanPhamId);
    
    @Query("SELECT y.sanPham.id FROM YeuThich y WHERE y.nguoiDung.id = :nguoiDungId")
    List<Long> findSanPhamIdsByNguoiDungId(@Param("nguoiDungId") Long nguoiDungId);
}
