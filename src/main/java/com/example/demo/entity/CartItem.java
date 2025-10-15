package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "chi_tiet_gio_hang")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CartItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "so_luong", nullable = false)
    private Integer soLuong = 1;
    
    @Column(name = "gia_ban", nullable = false, precision = 19, scale = 4)
    private BigDecimal giaBan;
    
    @Column(name = "kich_thuoc")
    private String kichThuoc;
    
    @Column(name = "mau_sac")
    private String mauSac;
    
    @Column(name = "ngay_them", nullable = false)
    private LocalDateTime ngayThem = LocalDateTime.now();
    
    @Column(name = "bien_the_id")
    private Long bienTheId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "gio_hang_id", nullable = false)
    @JsonIgnore
    private Cart gioHang;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "san_pham_id", nullable = false)
    private Product sanPham;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bien_the_id", insertable = false, updatable = false)
    @JsonIgnore
    private BienTheSanPham bienThe;
    
    // Helper methods
    public BigDecimal getThanhTien() {
        return giaBan.multiply(BigDecimal.valueOf(soLuong));
    }
}
