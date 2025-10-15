package com.example.datn_qlkh.service;

import com.example.datn_qlkh.entity.DiaChi;
import java.util.List;

public interface DiaChiService {
    List<DiaChi> getAllByUser(Long nguoiDungId);
    DiaChi getDefaultByUser(Long nguoiDungId);
    DiaChi saveOrUpdate(DiaChi diaChi);
    void delete(Long id, Long nguoiDungId);
    void setDefault(Long id, Long nguoiDungId);
}
