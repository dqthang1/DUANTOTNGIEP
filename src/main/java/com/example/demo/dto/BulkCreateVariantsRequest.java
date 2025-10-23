package com.example.demo.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class BulkCreateVariantsRequest {
    
    @NotNull(message = "Danh sách màu sắc không được để trống")
    @Size(min = 1, message = "Phải có ít nhất 1 màu sắc")
    private List<String> colors;
    
    @NotNull(message = "Danh sách kích cỡ không được để trống")
    @Size(min = 1, message = "Phải có ít nhất 1 kích cỡ")
    private List<String> sizes;
    
    @NotNull(message = "Giá bán không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá bán phải lớn hơn 0")
    private BigDecimal defaultPrice;
    
    private BigDecimal defaultPromotionPrice;
    
    @NotNull(message = "Số lượng tồn không được để trống")
    @Min(value = 0, message = "Số lượng tồn phải >= 0")
    private Integer defaultStock;
    
    private Boolean skipDuplicates = true; // Bỏ qua variants đã tồn tại
}


