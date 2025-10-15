package com.example.datn_qlkh.controller;

import com.example.datn_qlkh.dto.RegistrationDto;
import com.example.datn_qlkh.service.UserService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/register")
    public String showRegistrationForm(Model model) {
        model.addAttribute("registrationDto", new RegistrationDto());
        return "auth/register"; // resources/templates/auth/register.html
    }

    @PostMapping("/register")
    public String registerUser(@Valid @ModelAttribute("registrationDto") RegistrationDto dto,
                               BindingResult result,
                               Model model) {
        if (result.hasErrors()) {
            return "auth/register";
        }

        try {
            userService.register(dto);
            model.addAttribute("successMessage", "Đăng ký thành công. Vui lòng đăng nhập.");
            return "auth/login"; // redirect to login page or show success
        } catch (IllegalArgumentException ex) {
            result.rejectValue("email", "error.registrationDto", ex.getMessage());
            return "auth/register";
        } catch (Exception ex) {
            model.addAttribute("errorMessage", "Có lỗi trong quá trình đăng ký. Vui lòng thử lại.");
            return "auth/register";
        }
    }

    @GetMapping("/login")
    public String loginPage() {
        return "auth/login";
    }
}
