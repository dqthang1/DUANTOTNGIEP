package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "dia_chi")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DiaChi {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ten_nguoi_nhan", nullable = false)
    private String tenNguoiNhan;
    
    @Column(name = "so_dien_thoai", nullable = false)
    private String soDienThoai;
    
    @Column(name = "dia_chi_chi_tiet", nullable = false)
    private String diaChiChiTiet;
    
    @Column(name = "tinh_thanh", nullable = false)
    private String tinhThanh;
    
    @Column(name = "quan_huyen", nullable = false)
    private String quanHuyen;
    
    @Column(name = "phuong_xa", nullable = false)
    private String phuongXa;
    
    @Column(name = "la_dia_chi_mac_dinh", nullable = false)
    private Boolean laDiaChiMacDinh = false;
    
    @Column(name = "ghi_chu")
    private String ghiChu;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao = LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nguoi_dung_id", nullable = false)
    private User nguoiDung;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}
