package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "thanh_toan")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ThanhToan {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ma_giao_dich", nullable = false)
    private String maGiaoDich;
    
    @Column(name = "phuong_thuc", nullable = false)
    private String phuongThuc;
    
    @Column(name = "so_tien", nullable = false, precision = 19, scale = 4)
    private BigDecimal soTien;
    
    @Column(name = "trang_thai", nullable = false)
    private String trangThai;
    
    @Column(name = "thong_tin_them")
    private String thongTinThem;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao = LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "don_hang_id", nullable = false)
    @JsonIgnore
    private Order donHang;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
    
    // Helper methods
    public String getTrangThaiDisplay() {
        switch (trangThai) {
            case "PENDING": return "Chờ thanh toán";
            case "SUCCESS": return "Thành công";
            case "FAILED": return "Thất bại";
            case "CANCELLED": return "Đã hủy";
            default: return trangThai;
        }
    }
    
    public boolean isSuccess() {
        return "SUCCESS".equals(trangThai);
    }
    
    public boolean isPending() {
        return "PENDING".equals(trangThai);
    }
}