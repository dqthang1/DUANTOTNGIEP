package com.example.datn_qlkh.controller;

import com.example.datn_qlkh.entity.NguoiDung;
import com.example.datn_qlkh.repository.NguoiDungRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final NguoiDungRepository userRepo;

    public HomeController(NguoiDungRepository userRepo) {
        this.userRepo = userRepo;
    }

    @GetMapping("/")
    public String home(Model model, Authentication authentication) {
        model.addAttribute("title", "Activewear - Cửa hàng áo thể thao");

        if (authentication != null && authentication.isAuthenticated()) {
            Object principal = authentication.getPrincipal();

            if (principal instanceof OidcUser) {
                OidcUser oidc = (OidcUser) principal;
                String email = (String) oidc.getAttributes().get("email");
                NguoiDung user = userRepo.findByEmail(email).orElse(null);
                model.addAttribute("currentUser", user);
            } else if (principal instanceof OAuth2User) {
                OAuth2User oauth2User = (OAuth2User) principal;
                String email = (String) oauth2User.getAttributes().get("email");
                NguoiDung user = userRepo.findByEmail(email).orElse(null);
                model.addAttribute("currentUser", user);
            }
            else {
                String email = authentication.getName();
                NguoiDung user = userRepo.findByEmail(email).orElse(null);
                model.addAttribute("currentUser", user);
            }
        }

        return "home"; // -> templates/home.html
    }
}

