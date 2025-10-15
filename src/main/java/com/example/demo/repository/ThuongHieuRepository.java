package com.example.demo.repository;

import com.example.demo.entity.ThuongHieu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ThuongHieuRepository extends JpaRepository<ThuongHieu, Long> {
    
    // Có thể thêm các method tùy chỉnh ở đây nếu cần
}
