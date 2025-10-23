package com.example.demo.controller;

import com.example.demo.entity.*;
import com.example.demo.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/admin")
@Slf4j
public class AdminController {
    
    @Autowired
    private ProductManagementService productManagementService;
    
    @Autowired
    private DanhMucMonTheThaoService danhMucMonTheThaoService;
    
    @Autowired
    private BannerService bannerService;
    
    @Autowired
    private DanhMucService danhMucService;
    
    @Autowired
    private ThuongHieuService thuongHieuService;
    
    // ============= DASHBOARD =============
    @GetMapping
    public String dashboard(Model model) {
        // Thống kê tổng quan
        long totalProducts = productManagementService.countAllProducts();
        long activeProducts = productManagementService.countActiveProducts();
        long totalCategories = danhMucService.countActiveCategories();
        long totalBrands = thuongHieuService.countActiveBrands();
        
        model.addAttribute("totalProducts", totalProducts);
        model.addAttribute("activeProducts", activeProducts);
        model.addAttribute("totalCategories", totalCategories);
        model.addAttribute("totalBrands", totalBrands);
        
        return "admin/dashboard";
    }
    
    
    // ============= QUẢN LÝ DANH MỤC MÔN THỂ THAO =============
    @GetMapping("/sports")
    public String sports(Model model) {
        List<DanhMucMonTheThao> sports = danhMucMonTheThaoService.getAllSports();
        model.addAttribute("sports", sports);
        return "admin/sports/index";
    }
    
    @GetMapping("/sports/create")
    public String createSportForm(Model model) {
        model.addAttribute("sport", new DanhMucMonTheThao());
        return "admin/sports/create";
    }
    
    @PostMapping("/sports/create")
    public String createSport(@ModelAttribute DanhMucMonTheThao sport) {
        sport.setNgayTao(LocalDateTime.now());
        sport.setHoatDong(true);
        danhMucMonTheThaoService.saveSport(sport);
        return "redirect:/admin/sports?success=created";
    }
    
    @GetMapping("/sports/{id}/edit")
    public String editSportForm(@PathVariable Long id, Model model) {
        Optional<DanhMucMonTheThao> sportOpt = danhMucMonTheThaoService.getSportById(id);
        if (sportOpt.isEmpty()) {
            return "redirect:/admin/sports?error=notfound";
        }
        model.addAttribute("sport", sportOpt.get());
        return "admin/sports/edit";
    }
    
    @PostMapping("/sports/{id}/edit")
    public String updateSport(@PathVariable Long id, @ModelAttribute DanhMucMonTheThao sport) {
        Optional<DanhMucMonTheThao> existingSportOpt = danhMucMonTheThaoService.getSportById(id);
        if (existingSportOpt.isEmpty()) {
            return "redirect:/admin/sports?error=notfound";
        }
        
        DanhMucMonTheThao existingSport = existingSportOpt.get();
        existingSport.setTen(sport.getTen());
        existingSport.setMoTa(sport.getMoTa());
        existingSport.setHinhAnh(sport.getHinhAnh());
        existingSport.setThuTu(sport.getThuTu());
        existingSport.setHoatDong(sport.getHoatDong());
        existingSport.setNgayCapNhat(LocalDateTime.now());
        
        danhMucMonTheThaoService.saveSport(existingSport);
        return "redirect:/admin/sports?success=updated";
    }
    
    @PostMapping("/sports/{id}/delete")
    public String deleteSport(@PathVariable Long id) {
        danhMucMonTheThaoService.deleteSport(id);
        return "redirect:/admin/sports?success=deleted";
    }
    
    // ============= QUẢN LÝ BANNER =============
    @GetMapping("/banners")
    public String banners(Model model) {
        List<Banner> banners = bannerService.getAllBanners();
        model.addAttribute("banners", banners);
        return "admin/banners/index";
    }
    
    @GetMapping("/banners/create")
    public String createBannerForm(Model model) {
        model.addAttribute("banner", new Banner());
        return "admin/banners/create";
    }
    
    @PostMapping("/banners/create")
    public String createBanner(@ModelAttribute Banner banner) {
        banner.setNgayTao(LocalDateTime.now());
        banner.setHoatDong(true);
        bannerService.saveBanner(banner);
        return "redirect:/admin/banners?success=created";
    }
    
    @GetMapping("/banners/{id}/edit")
    public String editBannerForm(@PathVariable Long id, Model model) {
        Optional<Banner> bannerOpt = bannerService.getBannerById(id);
        if (bannerOpt.isEmpty()) {
            return "redirect:/admin/banners?error=notfound";
        }
        model.addAttribute("banner", bannerOpt.get());
        return "admin/banners/edit";
    }
    
    @PostMapping("/banners/{id}/edit")
    public String updateBanner(@PathVariable Long id, @ModelAttribute Banner banner) {
        Optional<Banner> existingBannerOpt = bannerService.getBannerById(id);
        if (existingBannerOpt.isEmpty()) {
            return "redirect:/admin/banners?error=notfound";
        }
        
        Banner existingBanner = existingBannerOpt.get();
        existingBanner.setTen(banner.getTen());
        existingBanner.setHinhAnh(banner.getHinhAnh());
        existingBanner.setMoTa(banner.getMoTa());
        existingBanner.setLink(banner.getLink());
        existingBanner.setViTri(banner.getViTri());
        existingBanner.setThuTu(banner.getThuTu());
        existingBanner.setHoatDong(banner.getHoatDong());
        existingBanner.setNgayCapNhat(LocalDateTime.now());
        
        bannerService.saveBanner(existingBanner);
        return "redirect:/admin/banners?success=updated";
    }
    
    @PostMapping("/banners/{id}/delete")
    public String deleteBanner(@PathVariable Long id) {
        bannerService.deleteBanner(id);
        return "redirect:/admin/banners?success=deleted";
    }
    
}
