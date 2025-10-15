package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "danh_muc")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DanhMuc {
    
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
    private java.time.LocalDateTime ngayTao = java.time.LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private java.time.LocalDateTime ngayCapNhat;
    
    
    @OneToMany(mappedBy = "danhMuc", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("product-danhmuc")
    private java.util.List<Product> sanPhams;
}
