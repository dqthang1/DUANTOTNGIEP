package com.example.demo.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class VariantCreateRequest {
    
    @NotNull(message = "Kích cỡ không được để trống")
    @NotBlank(message = "Kích cỡ không được để trống")
    private String kichCo;
    
    @NotNull(message = "Màu sắc không được để trống")
    @NotBlank(message = "Màu sắc không được để trống")
    private String mauSac;
    
    @NotNull(message = "Giá bán không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá bán phải lớn hơn 0")
    private BigDecimal giaBan;
    
    private BigDecimal giaKhuyenMai;
    
    @NotNull(message = "Số lượng tồn không được để trống")
    @Min(value = 0, message = "Số lượng tồn phải >= 0")
    private Integer soLuongTon;
    
    private String anhBienThe;
    
    private BigDecimal trongLuong;
    
    private Boolean hienThi = true;
}


