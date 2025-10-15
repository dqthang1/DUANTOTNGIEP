package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "danh_muc_mon_the_thao")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DanhMucMonTheThao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ten", nullable = false)
    private String ten;
    
    @Column(name = "slug", nullable = false)
    private String slug;
    
    @Column(name = "mo_ta")
    private String moTa;
    
    @Column(name = "hinh_anh")
    private String hinhAnh;
    
    @Column(name = "thu_tu", nullable = false)
    private Integer thuTu = 0;
    
    @Column(name = "hien_thi_trang_chu", nullable = false)
    private Boolean hienThiTrangChu = false;
    
    @Column(name = "hoat_dong", nullable = false)
    private Boolean hoatDong = true;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao = LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @OneToMany(mappedBy = "monTheThao", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("product-monTheThao")
    private List<Product> sanPhams;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}
