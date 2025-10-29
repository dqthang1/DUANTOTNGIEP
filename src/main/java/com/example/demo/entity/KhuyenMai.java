package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "khuyen_mai")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class KhuyenMai {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ten", nullable = false, length = 255)
    private String ten;
    
    @Column(name = "mo_ta", length = 1000)
    private String moTa;
    
    @Column(name = "loai", nullable = false, length = 50)
    private String loai;
    
    @Column(name = "gia_tri", nullable = false, precision = 19, scale = 4)
    private BigDecimal giaTri;
    
    @Column(name = "ngay_bat_dau", nullable = false)
    private LocalDateTime ngayBatDau;
    
    @Column(name = "ngay_ket_thuc", nullable = false)
    private LocalDateTime ngayKetThuc;
    
    @Column(name = "so_luong_su_dung", nullable = false)
    private Integer soLuongSuDung = 0;
    
    @Column(name = "so_luong_toi_da")
    private Integer soLuongToiDa;
    
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
    
    // Relationships sẽ được quản lý qua bảng san_pham_khuyen_mai
    
    public enum LoaiKhuyenMai {
        PHAN_TRAM("Phần trăm"),
        SO_TIEN("Số tiền"),
        FREE_SHIP("Miễn phí vận chuyển"),
        TANG_KEM("Tặng kèm");
        
        private final String displayName;
        
        LoaiKhuyenMai(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    // Helper methods
    public boolean isDangHoatDong() {
        LocalDateTime now = LocalDateTime.now();
        return hoatDong && 
               ngayBatDau.isBefore(now) && 
               ngayKetThuc.isAfter(now) &&
               (soLuongToiDa == null || soLuongSuDung < soLuongToiDa);
    }
    
    public BigDecimal calculateDiscountAmount(BigDecimal originalPrice) {
        if (!isDangHoatDong() || originalPrice == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal discountAmount = BigDecimal.ZERO;
        
        if ("PHAN_TRAM".equals(loai)) {
            // giaTri là phần trăm (ví dụ: 20 cho 20%)
            discountAmount = originalPrice.multiply(giaTri).divide(BigDecimal.valueOf(100));
        } else if ("SO_TIEN".equals(loai)) {
            // giaTri là số tiền giảm
            discountAmount = giaTri;
        }
        // FREE_SHIP và TANG_KEM sẽ được xử lý riêng trong logic đơn hàng
        
        // Đảm bảo không giảm quá giá gốc
        return discountAmount.compareTo(originalPrice) > 0 ? originalPrice : discountAmount;
    }
}
