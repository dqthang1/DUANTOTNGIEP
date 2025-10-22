package com.example.khuyenmai.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Data
@Entity
public class KhuyenMai {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String ten;
    private String moTa;
    private Double phanTramGiam;
    private LocalDate ngayBatDau;
    private LocalDate ngayKetThuc;
}
