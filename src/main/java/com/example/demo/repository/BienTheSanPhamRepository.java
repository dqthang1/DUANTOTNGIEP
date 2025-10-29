package com.example.demo.repository;

import com.example.demo.entity.BienTheSanPham;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BienTheSanPhamRepository extends JpaRepository<BienTheSanPham, Long> {
    
    /**
     * Tìm tất cả biến thể của một sản phẩm
     */
    List<BienTheSanPham> findBySanPhamId(Long sanPhamId);
    
    /**
     * Tìm tất cả biến thể đang hiển thị của một sản phẩm
     */
    List<BienTheSanPham> findBySanPhamIdAndHienThiTrue(Long sanPhamId);
    
    /**
     * Tìm tất cả biến thể còn hàng của một sản phẩm
     */
    @Query("SELECT v FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.soLuongTon > 0 AND v.hienThi = true")
    List<BienTheSanPham> findInStockVariantsByProductId(@Param("sanPhamId") Long sanPhamId);
    
    /**
     * Kiểm tra xem combination (màu + size) đã tồn tại chưa
     */
    @Query("SELECT v FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.kichCo = :kichCo AND v.mauSac = :mauSac")
    Optional<BienTheSanPham> findBySanPhamIdAndKichCoAndMauSac(
        @Param("sanPhamId") Long sanPhamId,
        @Param("kichCo") String kichCo,
        @Param("mauSac") String mauSac
    );
    
    /**
     * Kiểm tra duplicate khi update (exclude current variant)
     */
    @Query("SELECT v FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.kichCo = :kichCo AND v.mauSac = :mauSac AND v.id != :variantId")
    Optional<BienTheSanPham> findDuplicateVariant(
        @Param("sanPhamId") Long sanPhamId,
        @Param("kichCo") String kichCo,
        @Param("mauSac") String mauSac,
        @Param("variantId") Long variantId
    );
    
    /**
     * Lấy tất cả màu sắc của một sản phẩm
     */
    @Query("SELECT DISTINCT v.mauSac FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.hienThi = true ORDER BY v.mauSac")
    List<String> findDistinctColorsByProductId(@Param("sanPhamId") Long sanPhamId);
    
    /**
     * Lấy tất cả kích cỡ của một sản phẩm
     */
    @Query("SELECT DISTINCT v.kichCo FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.hienThi = true ORDER BY v.kichCo")
    List<String> findDistinctSizesByProductId(@Param("sanPhamId") Long sanPhamId);
    
    /**
     * Tìm variant theo màu và size
     */
    @Query("SELECT v FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.mauSac = :mauSac AND v.kichCo = :kichCo AND v.hienThi = true")
    Optional<BienTheSanPham> findByProductIdAndColorAndSize(
        @Param("sanPhamId") Long sanPhamId,
        @Param("mauSac") String mauSac,
        @Param("kichCo") String kichCo
    );
    
    /**
     * Xóa tất cả biến thể của một sản phẩm
     */
    void deleteBySanPhamId(Long sanPhamId);
    
    /**
     * Đếm số lượng biến thể của một sản phẩm
     */
    long countBySanPhamId(Long sanPhamId);
    
    /**
     * Đếm số lượng biến thể còn hàng
     */
    @Query("SELECT COUNT(v) FROM BienTheSanPham v WHERE v.sanPham.id = :sanPhamId AND v.soLuongTon > 0 AND v.hienThi = true")
    long countInStockVariants(@Param("sanPhamId") Long sanPhamId);
}
