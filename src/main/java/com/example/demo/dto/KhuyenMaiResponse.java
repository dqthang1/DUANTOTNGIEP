package com.example.demo.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class KhuyenMaiResponse {
    
    private Long id;
    private String ten;
    private String moTa;
    private String loai;
    private BigDecimal giaTri;
    private LocalDateTime ngayBatDau;
    private LocalDateTime ngayKetThuc;
    private Integer soLuongSuDung;
    private Integer soLuongToiDa;
    private Boolean hoatDong;
    private Long nguoiTao;
    private Long nguoiCapNhat;
    private LocalDateTime ngayTao;
    private LocalDateTime ngayCapNhat;
    
    // Thông tin sản phẩm áp dụng
    private List<ProductSummaryDto> sanPhams;
    
    // Thông tin trạng thái
    private boolean isActive;
    private boolean isExpired;
    private boolean isUpcoming;
    private long daysRemaining;
    private String statusText;
    
    @Data
    public static class ProductSummaryDto {
        private Long id;
        private String ten;
        private String maSanPham;
    }
    
    
    // Helper methods
    public void calculateStatus() {
        LocalDateTime now = LocalDateTime.now();
        
        if (!hoatDong) {
            this.statusText = "Đã tắt";
            this.isActive = false;
            return;
        }
        
        if (ngayBatDau.isAfter(now)) {
            this.statusText = "Sắp diễn ra";
            this.isUpcoming = true;
            this.isActive = false;
            this.daysRemaining = java.time.temporal.ChronoUnit.DAYS.between(now, ngayBatDau);
        } else if (ngayKetThuc.isBefore(now)) {
            this.statusText = "Đã hết hạn";
            this.isExpired = true;
            this.isActive = false;
        } else {
            this.statusText = "Đang hoạt động";
            this.isActive = true;
            this.daysRemaining = java.time.temporal.ChronoUnit.DAYS.between(now, ngayKetThuc);
            
            // Kiểm tra số lượng sử dụng
            if (soLuongToiDa != null && soLuongSuDung >= soLuongToiDa) {
                this.statusText = "Đã hết lượt";
                this.isActive = false;
            }
        }
    }
}
