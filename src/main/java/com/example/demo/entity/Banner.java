package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "banner")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Banner {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ten", nullable = false)
    private String ten;
    
    @Column(name = "hinh_anh", nullable = false, length = 500)
    private String hinhAnh;
    
    @Column(name = "mo_ta", length = 1000)
    private String moTa;
    
    @Column(name = "link", length = 500)
    private String link;
    
    @Column(name = "vi_tri", nullable = false, length = 50)
    private String viTri; // main, header, sidebar
    
    @Column(name = "thu_tu", nullable = false)
    private Integer thuTu = 0;
    
    @Column(name = "hoat_dong", nullable = false)
    private Boolean hoatDong = true;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao = LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}
