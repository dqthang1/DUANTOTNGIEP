package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class InventoryHistoryResponse {
    private Long id;
    private Long productId;
    private String productName;
    private String productCode;
    private Integer soLuongCu;
    private Integer soLuongMoi;
    private Integer soLuongThayDoi;
    private String loaiThayDoi;
    private String lyDo;
    private Long nguoiThayDoi;
    private LocalDateTime ngayThayDoi;
}


