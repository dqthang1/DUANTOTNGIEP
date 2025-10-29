package com.example.demo.repository;

import com.example.demo.entity.CartItem;
import com.example.demo.entity.Cart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    
    @Query("SELECT ci FROM CartItem ci LEFT JOIN FETCH ci.sanPham WHERE ci.gioHang = :cart")
    List<CartItem> findByGioHang(@Param("cart") Cart cart);
    
    @Query("SELECT ci FROM CartItem ci WHERE ci.gioHang.id = :cartId")
    List<CartItem> findByGioHangId(@Param("cartId") Long cartId);
    
    @Query("SELECT ci FROM CartItem ci WHERE ci.gioHang.id = :cartId AND ci.sanPham.id = :productId " +
           "AND (:size IS NULL AND ci.kichThuoc IS NULL OR ci.kichThuoc = :size) " +
           "AND (:color IS NULL AND ci.mauSac IS NULL OR ci.mauSac = :color)")
    Optional<CartItem> findByCartAndProductAndVariants(@Param("cartId") Long cartId, 
                                                       @Param("productId") Long productId,
                                                       @Param("size") String size, 
                                                       @Param("color") String color);
    
    @Query("SELECT ci FROM CartItem ci WHERE ci.gioHang.id = :cartId AND ci.bienTheId = :bienTheId")
    Optional<CartItem> findByCartAndBienThe(@Param("cartId") Long cartId, @Param("bienTheId") Long bienTheId);
    
    @Query("SELECT ci FROM CartItem ci WHERE ci.gioHang.id = :gioHangId AND ci.bienTheId = :bienTheId")
    Optional<CartItem> findByGioHangIdAndBienTheId(@Param("gioHangId") Long gioHangId, @Param("bienTheId") Long bienTheId);
    
    @Query("SELECT ci FROM CartItem ci WHERE ci.gioHang.id = :cartId AND ci.sanPham.id = :productId")
    List<CartItem> findByCartAndProduct(@Param("cartId") Long cartId, @Param("productId") Long productId);
    
    void deleteByGioHang(Cart cart);
    
    @Query("DELETE FROM CartItem ci WHERE ci.gioHang.id = :cartId")
    void deleteByGioHangId(@Param("cartId") Long cartId);
    
    @Query("SELECT SUM(ci.soLuong * ci.giaBan) FROM CartItem ci WHERE ci.gioHang.id = :cartId")
    Double getTotalAmountByCartId(@Param("cartId") Long cartId);
}
