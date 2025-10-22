package com.example.khuyenmai.controller;

import com.example.khuyenmai.entity.KhuyenMai;
import com.example.khuyenmai.entity.SanPham;
import com.example.khuyenmai.service.KhuyenMaiService;
import com.example.khuyenmai.service.SanPhamService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/sanpham")
public class SanPhamController {
    private final SanPhamService spService;
    private final KhuyenMaiService kmService;

    public SanPhamController(SanPhamService spService, KhuyenMaiService kmService) {
        this.spService = spService;
        this.kmService = kmService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("listSP", spService.getAll());
        model.addAttribute("listKM", kmService.getAll());
        model.addAttribute("newSP", new SanPham());
        return "sanpham";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute SanPham sp) {
        spService.save(sp);
        return "redirect:/sanpham";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id) {
        spService.delete(id);
        return "redirect:/sanpham";
    }

    @GetMapping("/apdung/{idSp}/{idKm}")
    public String apDung(@PathVariable Long idSp, @PathVariable Long idKm) {
        kmService.findById(idKm).ifPresent(km -> spService.apDungKhuyenMai(idSp, km));
        return "redirect:/sanpham";
    }

    @GetMapping("/huy/{idSp}")
    public String huy(@PathVariable Long idSp) {
        spService.huyKhuyenMai(idSp);
        return "redirect:/sanpham";
    }
}
