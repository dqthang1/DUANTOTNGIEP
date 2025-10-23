package com.example.demo.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ProductCreateRequest {
    
    @NotBlank(message = "Tên sản phẩm không được để trống")
    @Size(min = 2, max = 255, message = "Tên sản phẩm phải từ 2-255 ký tự")
    private String ten;
    
    @Size(max = 2000, message = "Mô tả không được quá 2000 ký tự")
    private String moTa;
    
    @Size(max = 500, message = "Mô tả ngắn không được quá 500 ký tự")
    private String moTaNgan;
    
    @NotNull(message = "Giá bán không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá bán phải lớn hơn 0")
    @DecimalMax(value = "999999999.99", message = "Giá bán không được quá 999,999,999.99")
    private BigDecimal gia;
    
    @DecimalMin(value = "0.0", inclusive = true, message = "Giá gốc phải lớn hơn hoặc bằng 0")
    @DecimalMax(value = "999999999.99", message = "Giá gốc không được quá 999,999,999.99")
    private BigDecimal giaGoc;
    
    @Min(value = 0, message = "Số lượng tồn kho phải lớn hơn hoặc bằng 0")
    @Max(value = 999999, message = "Số lượng tồn kho không được quá 999,999")
    private Integer soLuongTon = 0;
    
    @Size(max = 100, message = "Chất liệu không được quá 100 ký tự")
    private String chatLieu;
    
    @Size(max = 100, message = "Xuất xứ không được quá 100 ký tự")
    private String xuatXu;
    
    @DecimalMin(value = "0.0", inclusive = true, message = "Trọng lượng phải lớn hơn hoặc bằng 0")
    @DecimalMax(value = "999.99", message = "Trọng lượng không được quá 999.99")
    private BigDecimal trongLuong;
    
    @Size(max = 50, message = "Kích thước không được quá 50 ký tự")
    private String kichThuoc;
    
    private Boolean noiBat = false;
    private Boolean banChay = false;
    private Boolean moiVe = false;
    private Boolean hoatDong = true;
    
    @NotNull(message = "Danh mục không được để trống")
    private Long danhMucId;
    
    @NotNull(message = "Thương hiệu không được để trống")
    private Long thuongHieuId;
    
    private Long monTheThaoId;
    
    @Size(max = 500, message = "URL ảnh chính không được quá 500 ký tự")
    private String anhChinh;
}

