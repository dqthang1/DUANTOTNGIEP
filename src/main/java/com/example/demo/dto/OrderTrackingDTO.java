package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderTrackingDTO {
    private String orderCode;
    private String status;
    private LocalDateTime createdAt;
    private BigDecimal totalAmount;
    private String trackingNumber;
    private List<OrderItemDTO> items;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemDTO {
        private String productName;
        private Integer quantity;
        private BigDecimal price;
    }
}
