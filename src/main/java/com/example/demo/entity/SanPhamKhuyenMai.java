package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "san_pham_khuyen_mai")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SanPhamKhuyenMai {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_san_pham", nullable = false)
    private Product sanPham;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_khuyen_mai", nullable = false)
    private KhuyenMai khuyenMai;
    
    @Column(name = "gia_khuyen_mai", precision = 19, scale = 4)
    private BigDecimal giaKhuyenMai;
    
    @Column(name = "ngay_bat_dau", nullable = false)
    private LocalDateTime ngayBatDau;
    
    @Column(name = "ngay_ket_thuc", nullable = false)
    private LocalDateTime ngayKetThuc;
    
    @Column(name = "hoat_dong", nullable = false)
    private Boolean hoatDong = true;
    
    @Column(name = "nguoi_tao")
    private Long nguoiTao;
    
    @Column(name = "nguoi_cap_nhat")
    private Long nguoiCapNhat;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao;
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @Column(name = "ghi_chu", length = 500)
    private String ghiChu;
    
    // Helper methods
    public boolean isDangHoatDong() {
        LocalDateTime now = LocalDateTime.now();
        return hoatDong && 
               ngayBatDau.isBefore(now) && 
               ngayKetThuc.isAfter(now) &&
               khuyenMai.isDangHoatDong();
    }
    
    public BigDecimal calculateFinalPrice() {
        if (!isDangHoatDong() || sanPham == null) {
            return sanPham != null ? sanPham.getGia() : BigDecimal.ZERO;
        }
        
        if (giaKhuyenMai != null) {
            return giaKhuyenMai;
        }
        
        return khuyenMai.calculateDiscountAmount(sanPham.getGia());
    }
}

