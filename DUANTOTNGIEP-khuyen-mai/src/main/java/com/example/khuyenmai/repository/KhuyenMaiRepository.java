package com.example.khuyenmai.repository;

import com.example.khuyenmai.entity.KhuyenMai;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface KhuyenMaiRepository extends JpaRepository<KhuyenMai, Long> {
    List<KhuyenMai> findByTenContainingIgnoreCase(String ten);
}
