package com.example.demo.service;

import com.example.demo.entity.DanhMuc;
import com.example.demo.repository.DanhMucRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class DanhMucService {
    
    @Autowired
    private DanhMucRepository danhMucRepository;
    
    public List<DanhMuc> getAllCategories() {
        return danhMucRepository.findAll();
    }
    
    public List<DanhMuc> getAllActiveCategories() {
        return danhMucRepository.findByHoatDongTrueOrderByThuTuAsc();
    }
    
    public Optional<DanhMuc> getCategoryById(Long id) {
        return danhMucRepository.findById(id);
    }
    
    public DanhMuc saveCategory(DanhMuc danhMuc) {
        return danhMucRepository.save(danhMuc);
    }
    
    public void deleteCategory(Long id) {
        danhMucRepository.deleteById(id);
    }
    
    public long countActiveCategories() {
        return danhMucRepository.countByHoatDongTrue();
    }
}
