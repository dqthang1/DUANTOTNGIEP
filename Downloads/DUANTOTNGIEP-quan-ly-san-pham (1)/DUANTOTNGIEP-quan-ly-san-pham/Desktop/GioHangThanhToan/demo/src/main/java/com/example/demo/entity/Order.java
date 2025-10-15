package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "don_hang")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ma_don_hang", nullable = false, unique = true)
    private String maDonHang;
    
    @Column(name = "tong_tien", precision = 15, scale = 2)
    private BigDecimal tongTien;
    
    @Column(name = "phi_van_chuyen", precision = 10, scale = 2)
    private BigDecimal phiVanChuyen;
    
    @Column(name = "tong_thanh_toan", precision = 10, scale = 2)
    private BigDecimal tongThanhToan;
    
    @Column(name = "ten_nguoi_nhan")
    private String tenNguoiNhan;
    
    @Column(name = "so_dien_thoai")
    private String soDienThoai;
    
    @Column(name = "dia_chi_giao_hang")
    private String diaChiGiaoHang;
    
    @Column(name = "trang_thai", nullable = false)
    private String trangThai = "PENDING";
    
    @Column(name = "phuong_thuc_thanh_toan", nullable = false)
    private String phuongThucThanhToan = "COD";
    
    @Column(name = "ghi_chu")
    private String ghiChu;
    
    @Column(name = "ngay_dat_hang", nullable = false)
    private LocalDateTime ngayDatHang = LocalDateTime.now();
    
    @Column(name = "ngay_giao_hang")
    private LocalDateTime ngayGiaoHang;
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nguoi_dung_id", nullable = false)
    @JsonIgnore
    private User nguoiDung;
    
    @OneToMany(mappedBy = "donHang", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private List<OrderItem> orderItems;
    
    @OneToMany(mappedBy = "donHang", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<ThanhToan> thanhToans;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
    
    // Helper methods
    public String getTrangThaiDisplay() {
        switch (trangThai) {
            case "CHO_XAC_NHAN": return "Chờ xác nhận";
            case "CONFIRMED": return "Đã xác nhận";
            case "DANG_GIAO": return "Đang giao";
            case "DA_GIAO": return "Đã giao";
            case "DA_HUY": return "Đã hủy";
            case "PENDING": return "Chờ xác nhận";
            case "SHIPPING": return "Đang giao";
            case "DELIVERED": return "Đã giao";
            case "CANCELLED": return "Đã hủy";
            default: return trangThai;
        }
    }
}
