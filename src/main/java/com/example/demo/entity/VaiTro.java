package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "vai_tro")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VaiTro {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ten_vai_tro", nullable = false)
    private String tenVaiTro;
    
    @Column(name = "mo_ta")
    private String moTa;
    
    @Column(name = "quyen_han")
    private String quyenHan;
    
    @Column(name = "hoat_dong", nullable = false)
    private Boolean hoatDong = true;
    
    @Column(name = "ngay_tao", nullable = false)
    private java.time.LocalDateTime ngayTao = java.time.LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private java.time.LocalDateTime ngayCapNhat;
}
