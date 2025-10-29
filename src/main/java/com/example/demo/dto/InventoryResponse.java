package com.example.demo.dto;

import lombok.Data;

@Data
public class InventoryResponse {
    private Long productId;
    private String productName;
    private String productCode;
    private String imagePath;
    private Integer currentStock;
    private Integer totalVariantsStock;
    private Integer variantsCount;
    private String status; // IN_STOCK, LOW_STOCK, OUT_OF_STOCK
    private String category;
    private String brand;
    private Boolean active;
}


