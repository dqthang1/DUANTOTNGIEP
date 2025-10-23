package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "chi_tiet_don_hang")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ten_san_pham", nullable = false)
    private String tenSanPham;
    
    @Column(name = "so_luong", nullable = false)
    private Integer soLuong;
    
    @Column(name = "gia_ban", nullable = false, precision = 19, scale = 4)
    private BigDecimal giaBan;
    
    @Column(name = "thanh_tien", nullable = false, precision = 19, scale = 4)
    private BigDecimal thanhTien;
    
    @Column(name = "kich_thuoc")
    private String kichThuoc;
    
    @Column(name = "mau_sac")
    private String mauSac;
    
    @Column(name = "bien_the_id")
    private Long bienTheId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "don_hang_id", nullable = false)
    @JsonIgnore
    private Order donHang;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "san_pham_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Product sanPham;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bien_the_id", insertable = false, updatable = false)
    @JsonIgnore
    private BienTheSanPham bienThe;
    
    // Helper method
    public BigDecimal getThanhTien() {
        if (thanhTien != null) {
            return thanhTien;
        }
        return giaBan.multiply(BigDecimal.valueOf(soLuong));
    }
}
