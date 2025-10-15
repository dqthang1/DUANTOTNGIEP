package com.example.demo.service;

import com.example.demo.entity.ThuongHieu;
import com.example.demo.repository.ThuongHieuRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ThuongHieuService {
    
    @Autowired
    private ThuongHieuRepository thuongHieuRepository;
    
    public List<ThuongHieu> getAllBrands() {
        return thuongHieuRepository.findAll();
    }
    
    public List<ThuongHieu> getAllActiveBrands() {
        // ThuongHieu không có field hoatDong, trả về tất cả
        return thuongHieuRepository.findAll();
    }
    
    public Optional<ThuongHieu> getBrandById(Long id) {
        return thuongHieuRepository.findById(id);
    }
    
    public ThuongHieu saveBrand(ThuongHieu thuongHieu) {
        return thuongHieuRepository.save(thuongHieu);
    }
    
    public void deleteBrand(Long id) {
        thuongHieuRepository.deleteById(id);
    }
    
    public long countActiveBrands() {
        // ThuongHieu không có field hoatDong, đếm tất cả
        return thuongHieuRepository.count();
    }
}
