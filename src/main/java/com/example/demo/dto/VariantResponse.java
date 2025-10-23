package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VariantResponse {
    
    private Long id;
    private String maSku;
    private String kichCo;
    private String mauSac;
    private BigDecimal giaBan;
    private BigDecimal giaKhuyenMai;
    private Integer soLuongTon;
    private String anhBienThe;
    private BigDecimal trongLuong;
    private Boolean trangThai;
    private Boolean hienThi;
    private LocalDateTime ngayTao;
    private LocalDateTime ngayCapNhat;
    
    // Product info
    private Long productId;
    private String productName;
    private String productCode;
    
    // Computed fields
    private Boolean inStock;
    private BigDecimal finalPrice; // Giá sau khuyến mãi
}


