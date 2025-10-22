package com.example.khuyenmai.controller;

import com.example.khuyenmai.entity.KhuyenMai;
import com.example.khuyenmai.service.KhuyenMaiService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/khuyenmai")
public class KhuyenMaiController {
    private final KhuyenMaiService service;

    public KhuyenMaiController(KhuyenMaiService service) {
        this.service = service;
    }

    @GetMapping
    public String index(Model model, @RequestParam(required = false) String search) {
        model.addAttribute("list",
                (search == null || search.isEmpty()) ? service.getAll() : service.search(search));
        model.addAttribute("newKM", new KhuyenMai());
        return "khuyenmai";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute KhuyenMai km) {
        service.save(km);
        return "redirect:/khuyenmai";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            service.delete(id);
            redirectAttributes.addFlashAttribute("success", "Xóa khuyến mãi thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Không thể xóa khuyến mãi vì vẫn có sản phẩm đang áp dụng!");
        }
        return "redirect:/khuyenmai";
    }

}
