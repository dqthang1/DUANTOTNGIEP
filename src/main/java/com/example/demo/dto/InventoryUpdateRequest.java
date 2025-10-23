package com.example.demo.dto;

import lombok.Data;

@Data
public class InventoryUpdateRequest {
    private Long productId;
    private Integer quantity;
    private String lyDo;          // Lý do thay đổi
    private String loaiThayDoi;   // NHAP_KHO, XUAT_KHO, DIEU_CHINH, KIEM_KE
}

