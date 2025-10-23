package com.example.demo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "san_pham")
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Product {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ma_san_pham", nullable = false, unique = true)
    private String maSanPham;
    
    @Column(name = "ten", nullable = false)
    private String ten;
    
    @Column(name = "slug", nullable = false)
    private String slug;
    
    @Column(name = "mo_ta", columnDefinition = "TEXT")
    private String moTa;
    
    @Column(name = "mo_ta_ngan")
    private String moTaNgan;
    
    @Column(name = "gia", precision = 19, scale = 4)
    private BigDecimal gia;
    
    @Column(name = "gia_goc", precision = 19, scale = 4)
    private BigDecimal giaGoc;
    
    @Column(name = "anh_chinh")
    private String anhChinh;
    
    @Column(name = "so_luong_ton", nullable = false)
    private Integer soLuongTon = 0;
    
    @Column(name = "chat_lieu")
    private String chatLieu;
    
    @Column(name = "xuat_xu")
    private String xuatXu;
    
    @Column(name = "trong_luong", precision = 19, scale = 4)
    private BigDecimal trongLuong;
    
    @Column(name = "kich_thuoc")
    private String kichThuoc;
    
    @Column(name = "luot_xem", nullable = false)
    private Integer luotXem = 0;
    
    @Column(name = "da_ban", nullable = false)
    private Integer daBan = 0;
    
    @Column(name = "diem_trung_binh", precision = 19, scale = 4)
    private BigDecimal diemTrungBinh;
    
    @Column(name = "so_danh_gia", nullable = false)
    private Integer soDanhGia = 0;
    
    @Column(name = "hoat_dong", nullable = false)
    private Boolean hoatDong = true;
    
    @Column(name = "noi_bat", nullable = false)
    private Boolean noiBat = false;
    
    @Column(name = "ban_chay", nullable = false)
    private Boolean banChay = false;
    
    @Column(name = "moi_ve", nullable = false)
    private Boolean moiVe = false;
    
    @Column(name = "ngay_tao", nullable = false)
    private LocalDateTime ngayTao = LocalDateTime.now();
    
    @Column(name = "ngay_cap_nhat")
    private LocalDateTime ngayCapNhat;
    
    @Column(name = "nguoi_tao")
    private Long nguoiTao;
    
    @Column(name = "nguoi_cap_nhat")
    private Long nguoiCapNhat;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_danh_muc")
    @JsonBackReference("product-danhmuc")
    private DanhMuc danhMuc;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_thuong_hieu")
    @JsonBackReference("product-thuonghieu")
    private ThuongHieu thuongHieu;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_mon_the_thao")
    @JsonBackReference("product-monTheThao")
    private DanhMucMonTheThao monTheThao;
    
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("bienthe-sanpham")
    @JsonIgnore
    private List<BienTheSanPham> bienTheSanPhams;
    
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonManagedReference("anh-sanpham")
    @JsonIgnore
    private List<AnhSanPham> anhSanPhams;
    
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<CartItem> cartItems;
    
    @OneToMany(mappedBy = "sanPham", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<OrderItem> orderItems;
    
    @PreUpdate
    public void preUpdate() {
        ngayCapNhat = LocalDateTime.now();
    }
}
