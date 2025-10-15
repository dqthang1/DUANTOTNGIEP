package com.example.demo.repository;

import com.example.demo.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    Optional<Product> findByMaSanPham(String maSanPham);
    
    Optional<Product> findBySlug(String slug);
    
    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.danhMuc LEFT JOIN FETCH p.thuongHieu LEFT JOIN FETCH p.monTheThao WHERE p.id = :id")
    Optional<Product> findByIdWithDetails(@Param("id") Long id);
    
    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.danhMuc LEFT JOIN FETCH p.thuongHieu LEFT JOIN FETCH p.monTheThao WHERE p.id = :id")
    @EntityGraph(attributePaths = {"danhMuc", "thuongHieu", "monTheThao"})
    Optional<Product> findByIdWithDetailsEager(@Param("id") Long id);
    
    List<Product> findByHoatDongTrue();
    
    @Query("SELECT p FROM Product p WHERE p.noiBat = true AND p.hoatDong = true")
    List<Product> findByNoiBatTrue();
    
    Page<Product> findByHoatDongTrue(Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND p.soLuongTon > 0")
    List<Product> findAvailableProducts();
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND " +
           "(p.ten LIKE %:keyword% OR p.moTa LIKE %:keyword%)")
    List<Product> searchProducts(@Param("keyword") String keyword);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND p.danhMuc.id = :categoryId")
    List<Product> findByCategoryId(@Param("categoryId") Long categoryId);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND p.thuongHieu.id = :brandId")
    List<Product> findByBrandId(@Param("brandId") Long brandId);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true ORDER BY p.daBan DESC")
    List<Product> findTopSellingProducts(Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND " +
           "(p.ten LIKE %:keyword% OR p.moTa LIKE %:keyword%)")
    Page<Product> searchProducts(@Param("keyword") String keyword, Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND " +
           "(:categoryId IS NULL OR p.danhMuc.id = :categoryId) AND " +
           "(:brandId IS NULL OR p.thuongHieu.id = :brandId) AND " +
           "(:sportId IS NULL OR p.monTheThao.id = :sportId)")
    Page<Product> filterProducts(@Param("categoryId") Long categoryId, 
                                @Param("brandId") Long brandId,
                                @Param("sportId") Long sportId, 
                                Pageable pageable);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND p.monTheThao.id = :sportId")
    List<Product> findBySportId(@Param("sportId") Long sportId);

    @Query("SELECT COUNT(p) FROM Product p")
    long countAllProducts();
    
    long countByHoatDongTrue();
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND " +
           "(:categoryId IS NULL OR p.danhMuc.id = :categoryId) AND " +
           "(:brandId IS NULL OR p.thuongHieu.id = :brandId) AND " +
           "(:sportId IS NULL OR p.monTheThao.id = :sportId) AND " +
           "(:minPrice IS NULL OR p.gia >= :minPrice) AND " +
           "(:maxPrice IS NULL OR p.gia <= :maxPrice) AND " +
           "(:material IS NULL OR p.chatLieu LIKE %:material%) AND " +
           "(:origin IS NULL OR p.xuatXu LIKE %:origin%) AND " +
           "(:status IS NULL OR (:status = 'available' AND p.soLuongTon > 0) OR (:status = 'out-of-stock' AND p.soLuongTon = 0) OR (:status = 'featured' AND p.noiBat = true)) AND " +
           "(:freeShipping IS NULL OR :freeShipping = false OR (:freeShipping = true AND p.gia >= 500000))")
    Page<Product> filterProductsAdvanced(@Param("categoryId") Long categoryId, 
                                        @Param("brandId") Long brandId,
                                        @Param("sportId") Long sportId,
                                        @Param("minPrice") BigDecimal minPrice,
                                        @Param("maxPrice") BigDecimal maxPrice,
                                        @Param("material") String material,
                                        @Param("origin") String origin,
                                        @Param("status") String status,
                                        @Param("freeShipping") Boolean freeShipping,
                                        Pageable pageable);
    
    @Query("SELECT DISTINCT p.ten FROM Product p WHERE p.hoatDong = true AND " +
           "p.ten LIKE %:query% ORDER BY p.ten")
    List<String> getSearchSuggestions(@Param("query") String query);
    
    @Query("SELECT p FROM Product p WHERE p.hoatDong = true AND " +
           "(:search IS NULL OR :search = '' OR p.ten LIKE %:search% OR p.moTa LIKE %:search%) AND " +
           "(:categoryId IS NULL OR p.danhMuc.id = :categoryId) AND " +
           "(:brandId IS NULL OR p.thuongHieu.id = :brandId) AND " +
           "(:sportId IS NULL OR p.monTheThao.id = :sportId) AND " +
           "(:minPrice IS NULL OR p.gia >= :minPrice) AND " +
           "(:maxPrice IS NULL OR p.gia <= :maxPrice) AND " +
           "(:material IS NULL OR p.chatLieu LIKE %:material%) AND " +
           "(:origin IS NULL OR p.xuatXu LIKE %:origin%) AND " +
           "(:status IS NULL OR (:status = 'available' AND p.soLuongTon > 0) OR (:status = 'out-of-stock' AND p.soLuongTon = 0) OR (:status = 'featured' AND p.noiBat = true)) AND " +
           "(:freeShipping IS NULL OR :freeShipping = false OR (:freeShipping = true AND p.gia >= 500000))")
    Page<Product> filterProductsWithSearch(@Param("search") String search,
                                          @Param("categoryId") Long categoryId, 
                                          @Param("brandId") Long brandId,
                                          @Param("sportId") Long sportId,
                                          @Param("minPrice") BigDecimal minPrice,
                                          @Param("maxPrice") BigDecimal maxPrice,
                                          @Param("material") String material,
                                          @Param("origin") String origin,
                                          @Param("status") String status,
                                          @Param("freeShipping") Boolean freeShipping,
                                          Pageable pageable);
}
