package com.example.demo.service;

import com.example.demo.entity.Banner;
import com.example.demo.repository.BannerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BannerService {
    
    @Autowired
    private BannerRepository bannerRepository;
    
    public List<Banner> getAllBanners() {
        return bannerRepository.findAll();
    }
    
    public List<Banner> getAllActiveBanners() {
        return bannerRepository.findByHoatDongTrueOrderByThuTuAsc();
    }
    
    public List<Banner> getBannersByPosition(String position) {
        return bannerRepository.findActiveBannersByPosition(position);
    }
    
    public Optional<Banner> getBannerById(Long id) {
        return bannerRepository.findById(id);
    }
    
    public Banner saveBanner(Banner banner) {
        return bannerRepository.save(banner);
    }
    
    public void deleteBanner(Long id) {
        bannerRepository.deleteById(id);
    }
    
    public List<Banner> getMainBanners() {
        return getBannersByPosition("main");
    }
    
    public List<Banner> getHeaderBanners() {
        return getBannersByPosition("header");
    }
    
    public List<Banner> getSidebarBanners() {
        return getBannersByPosition("sidebar");
    }
}
