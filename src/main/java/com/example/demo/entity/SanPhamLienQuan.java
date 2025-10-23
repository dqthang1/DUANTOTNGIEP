package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "san_pham_lien_quan")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SanPhamLienQuan {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_san_pham", nullable = false)
    private Product sanPhamGoc;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_san_pham_lien_quan", nullable = false)
    private Product sanPhamLienQuan;
    
    @Column(name = "loai", nullable = false, length = 50)
    private String loai;
    
    @Column(name = "thu_tu", nullable = false)
    private Integer thuTu = 0;
    
    @Column(name = "tu_dong", nullable = false)
    private Boolean tuDong = false;
    
    @Column(name = "do_lien_quan", precision = 5, scale = 4)
    private BigDecimal doLienQuan;
    
    @Column(name = "ngay_them", nullable = false)
    private LocalDateTime ngayThem;
    
    public enum LoaiLienQuan {
        CUNG_DANH_MUC("Cùng danh mục"),
        CUNG_THUONG_HIEU("Cùng thương hiệu"),
        CUNG_MON_THE_THAO("Cùng môn thể thao"),
        TUONG_TU("Tương tự"),
        KHUYEN_NGHI("Khuyến nghị"),
        THAY_THE("Thay thế"),
        PHU_HOP("Phù hợp"),
        MANUAL("Thủ công");
        
        private final String displayName;
        
        LoaiLienQuan(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    // Helper methods
    public boolean isActive() {
        return sanPhamLienQuan != null && sanPhamLienQuan.getHoatDong();
    }
    
    public int getWeight() {
        int weight = thuTu != null ? thuTu : 0;
        
        // Tăng trọng số dựa trên loại liên quan
        switch (loai) {
            case "CUNG_DANH_MUC":
                weight += 10;
                break;
            case "CUNG_THUONG_HIEU":
                weight += 8;
                break;
            case "CUNG_MON_THE_THAO":
                weight += 6;
                break;
            case "KHUYEN_NGHI":
                weight += 15;
                break;
            case "THAY_THE":
                weight += 12;
                break;
            case "PHU_HOP":
                weight += 5;
                break;
            case "TUONG_TU":
                weight += 3;
                break;
            case "MANUAL":
                weight += 20; // Thủ công có trọng số cao nhất
                break;
        }
        
        return weight;
    }
}
