package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "yeu_thich")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class YeuThich {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ngay_them", nullable = false)
    private LocalDateTime ngayThem = LocalDateTime.now();
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nguoi_dung_id", nullable = false)
    private User nguoiDung;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "san_pham_id", nullable = false)
    private Product sanPham;
    
    // Unique constraint để tránh duplicate
    @Table(uniqueConstraints = @UniqueConstraint(columnNames = {"nguoi_dung_id", "san_pham_id"}))
    public static class YeuThichTable {}
}
