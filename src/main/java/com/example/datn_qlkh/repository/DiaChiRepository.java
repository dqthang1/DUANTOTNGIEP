package com.example.datn_qlkh.repository;

import com.example.datn_qlkh.entity.DiaChi;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DiaChiRepository extends JpaRepository<DiaChi, Long> {
    List<DiaChi> findByNguoiDungIdOrderByNgayTaoDesc(Long nguoiDungId);
    DiaChi findByNguoiDungIdAndMacDinhTrue(Long nguoiDungId);
}
