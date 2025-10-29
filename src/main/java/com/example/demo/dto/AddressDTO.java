package com.example.demo.dto;

import com.example.demo.entity.DiaChi;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddressDTO {
    
    private Long id;
    private String tenNguoiNhan;
    private String soDienThoai;
    private String diaChiChiTiet;
    private String tinhThanh;
    private String quanHuyen;
    private String phuongXa;
    private Boolean laDiaChiMacDinh;
    private String ghiChu;
    private LocalDateTime ngayTao;
    private LocalDateTime ngayCapNhat;
    
    /**
     * Convert từ DiaChi entity sang DTO
     */
    public static AddressDTO fromEntity(DiaChi diaChi) {
        if (diaChi == null) {
            return null;
        }
        
        AddressDTO dto = new AddressDTO();
        dto.setId(diaChi.getId());
        dto.setTenNguoiNhan(diaChi.getTenNguoiNhan());
        dto.setSoDienThoai(diaChi.getSoDienThoai());
        dto.setDiaChiChiTiet(diaChi.getDiaChiChiTiet());
        dto.setTinhThanh(diaChi.getTinhThanh());
        dto.setQuanHuyen(diaChi.getQuanHuyen());
        dto.setPhuongXa(diaChi.getPhuongXa());
        dto.setLaDiaChiMacDinh(diaChi.getLaDiaChiMacDinh());
        dto.setGhiChu(diaChi.getGhiChu());
        dto.setNgayTao(diaChi.getNgayTao());
        dto.setNgayCapNhat(diaChi.getNgayCapNhat());
        
        return dto;
    }
}

