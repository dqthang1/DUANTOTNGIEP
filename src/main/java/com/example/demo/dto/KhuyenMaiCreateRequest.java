package com.example.demo.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class KhuyenMaiCreateRequest {
    
    @NotBlank(message = "Tên khuyến mãi không được để trống")
    @Size(max = 255, message = "Tên khuyến mãi không được vượt quá 255 ký tự")
    private String ten;
    
    @Size(max = 1000, message = "Mô tả không được vượt quá 1000 ký tự")
    private String moTa;
    
    @NotBlank(message = "Loại khuyến mãi không được để trống")
    private String loai;
    
    @NotNull(message = "Giá trị khuyến mãi không được để trống")
    @DecimalMin(value = "0.0", message = "Giá trị khuyến mãi phải >= 0")
    @DecimalMax(value = "999999999.99", message = "Giá trị khuyến mãi quá lớn")
    private BigDecimal giaTri;
    
    @NotNull(message = "Ngày bắt đầu không được để trống")
    @Future(message = "Ngày bắt đầu phải là ngày tương lai")
    private LocalDateTime ngayBatDau;
    
    @NotNull(message = "Ngày kết thúc không được để trống")
    private LocalDateTime ngayKetThuc;
    
    @Min(value = 0, message = "Số lượng sử dụng phải >= 0")
    private Integer soLuongSuDung = 0;
    
    @Min(value = 1, message = "Số lượng tối đa phải >= 1")
    private Integer soLuongToiDa;
    
    private Boolean hoatDong = true;
    
    private Long nguoiTao;
    
    // Danh sách sản phẩm áp dụng
    private List<Long> sanPhamIds;
    
    // Validation methods
    public boolean isValidDateRange() {
        if (ngayBatDau == null || ngayKetThuc == null) {
            return false;
        }
        return ngayKetThuc.isAfter(ngayBatDau);
    }
    
    public boolean isValidDiscountValue() {
        if (loai == null || giaTri == null) {
            return false;
        }
        
        switch (loai) {
            case "PHAN_TRAM":
                return giaTri.compareTo(BigDecimal.ZERO) > 0 && giaTri.compareTo(BigDecimal.valueOf(100)) <= 0;
            case "SO_TIEN":
                return giaTri.compareTo(BigDecimal.ZERO) > 0;
            case "FREE_SHIP":
            case "TANG_KEM":
                return true; // Không cần giá trị giảm
            default:
                return false;
        }
    }
}
