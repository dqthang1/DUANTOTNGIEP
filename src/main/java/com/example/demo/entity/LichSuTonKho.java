package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "lich_su_ton_kho")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LichSuTonKho {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_san_pham", nullable = false)
    private Product sanPham;
    
    @Column(name = "so_luong_cu", nullable = false)
    private Integer soLuongCu;
    
    @Column(name = "so_luong_moi", nullable = false)
    private Integer soLuongMoi;
    
    @Column(name = "so_luong_thay_doi", nullable = false)
    private Integer soLuongThayDoi;
    
    @Column(name = "nguoi_thay_doi")
    private Long nguoiThayDoi;
    
    @Column(name = "ly_do", length = 500)
    private String lyDo;
    
    @Column(name = "loai_thay_doi", nullable = false, length = 50)
    private String loaiThayDoi; // NHAP_KHO, XUAT_KHO, DIEU_CHINH, BAN_HANG, TRA_HANG
    
    @Column(name = "ngay_thay_doi", nullable = false)
    private LocalDateTime ngayThayDoi;
    
    public enum LoaiThayDoi {
        NHAP_KHO("Nhập kho"),
        XUAT_KHO("Xuất kho"),
        DIEU_CHINH("Điều chỉnh"),
        BAN_HANG("Bán hàng"),
        TRA_HANG("Trả hàng"),
        HUY_DON("Hủy đơn"),
        KIEM_KE("Kiểm kê");
        
        private final String displayName;
        
        LoaiThayDoi(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
}


