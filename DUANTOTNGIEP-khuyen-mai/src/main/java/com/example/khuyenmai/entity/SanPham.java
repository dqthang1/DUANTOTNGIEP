package com.example.khuyenmai.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
public class SanPham {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String ten;
    private Double gia;

    @ManyToOne
    @JoinColumn(name = "id_khuyenmai")
    private KhuyenMai khuyenMai;
}
