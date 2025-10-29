package com.example.demo.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class ProductResponse {
    
    private Long id;
    private String maSanPham;
    private String ten;
    private String slug;
    private String moTa;
    private String moTaNgan;
    private BigDecimal gia;
    private BigDecimal giaGoc;
    private String anhChinh;
    private Integer soLuongTon;
    private String chatLieu;
    private String xuatXu;
    private BigDecimal trongLuong;
    private String kichThuoc;
    private Integer luotXem;
    private Integer daBan;
    private BigDecimal diemTrungBinh;
    private Integer soDanhGia;
    private Boolean hoatDong;
    private Boolean noiBat;
    private Boolean banChay;
    private Boolean moiVe;
    private LocalDateTime ngayTao;
    private LocalDateTime ngayCapNhat;
    
    // Thông tin liên quan
    private Long danhMucId;
    private String danhMucTen;
    private Long thuongHieuId;
    private String thuongHieuTen;
    private Long monTheThaoId;
    private String monTheThaoTen;
    
    // Thông tin người tạo/cập nhật
    private Long nguoiTao;
    private Long nguoiCapNhat;
}

