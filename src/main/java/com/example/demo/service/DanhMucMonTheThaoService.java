package com.example.demo.service;

import com.example.demo.entity.DanhMucMonTheThao;
import com.example.demo.repository.DanhMucMonTheThaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class DanhMucMonTheThaoService {
    
    @Autowired
    private DanhMucMonTheThaoRepository danhMucMonTheThaoRepository;
    
    public List<DanhMucMonTheThao> getAllSports() {
        return danhMucMonTheThaoRepository.findAll();
    }
    
    public List<DanhMucMonTheThao> getAllActiveSports() {
        return danhMucMonTheThaoRepository.findByHoatDongTrueOrderByThuTuAsc();
    }
    
    public Optional<DanhMucMonTheThao> getSportById(Long id) {
        return danhMucMonTheThaoRepository.findById(id);
    }
    
    public Optional<DanhMucMonTheThao> getSportByName(String name) {
        return danhMucMonTheThaoRepository.findByTen(name);
    }
    
    public DanhMucMonTheThao saveSport(DanhMucMonTheThao sport) {
        return danhMucMonTheThaoRepository.save(sport);
    }
    
    public void deleteSport(Long id) {
        danhMucMonTheThaoRepository.deleteById(id);
    }
    
    public List<DanhMucMonTheThao> searchSports(String keyword) {
        return danhMucMonTheThaoRepository.searchByKeyword(keyword);
    }
    
    public Long countProductsBySport(Long sportId) {
        return danhMucMonTheThaoRepository.countProductsByMonTheThao(sportId);
    }
}
