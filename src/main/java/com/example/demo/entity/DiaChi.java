package com.example.demo.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
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
    @NotBlank(message = "Tên người nhận không được để trống")
    private String tenNguoiNhan;
    
    @Column(name = "so_dien_thoai", nullable = false)
    @NotBlank(message = "Số điện thoại không được để trống")
    @Size(min = 8, max = 20, message = "Số điện thoại phải có từ 8-20 ký tự")
    @Pattern(regexp = "^[+0-9][0-9+]*$", message = "Số điện thoại phải bắt đầu bằng số hoặc dấu +, chỉ chứa số và dấu +")
    private String soDienThoai;
    
    @Column(name = "dia_chi_chi_tiet", nullable = false)
    @NotBlank(message = "Địa chỉ chi tiết không được để trống")
    private String diaChiChiTiet;
    
    @Column(name = "tinh_thanh", nullable = false)
    @NotBlank(message = "Tỉnh/thành không được để trống")
    private String tinhThanh;
    
    @Column(name = "quan_huyen", nullable = false)
    @NotBlank(message = "Quận/huyện không được để trống")
    private String quanHuyen;
    
    @Column(name = "phuong_xa", nullable = false)
    @NotBlank(message = "Phường/xã không được để trống")
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
