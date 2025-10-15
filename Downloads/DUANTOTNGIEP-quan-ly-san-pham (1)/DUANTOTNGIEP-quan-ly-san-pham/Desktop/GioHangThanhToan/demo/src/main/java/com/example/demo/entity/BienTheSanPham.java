package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bien_the_san_pham")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BienTheSanPham {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ma_sku")
    private String maSku;
    
    @Column(name = "kich_co")
    private String kichCo;
    
    @Column(name = "mau_sac")
    private String mauSac;
    
    @Column(name = "so_luong", nullable = false)
    private Integer soLuong = 0;
    
    @Column(name = "gia_ban", precision = 15, scale = 2)
    private BigDecimal giaBan;
    
    @Column(name = "gia_khuyen_mai", precision = 15, scale = 2)
    private BigDecimal giaKhuyenMai;
    
    @Column(name = "anh_bien_the")
    private String anhBienThe;
    
    @Column(name = "trong_luong", precision = 10, scale = 2)
    private BigDecimal trongLuong;
    
    @Column(name = "trang_thai", nullable = false)
    private Boolean trangThai = true;
    
    @Column(name = "hien_thi", nullable = false)
    private Boolean hienThi = true;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao = LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @Column(name = "so_luong_ton", nullable = false)
    private Integer soLuongTon = 0;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_san_pham", nullable = false)
    private Product sanPham;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}