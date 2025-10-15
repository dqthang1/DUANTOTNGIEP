package com.example.datn_qlkh.controller;

import com.example.datn_qlkh.entity.DiaChi;
import com.example.datn_qlkh.entity.NguoiDung;
import com.example.datn_qlkh.service.DiaChiService;
import com.example.datn_qlkh.service.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/profile")
public class ProfileController {

    private final UserService userService;
    private final DiaChiService diaChiService;

    public ProfileController(UserService userService, DiaChiService diaChiService) {
        this.userService = userService;
        this.diaChiService = diaChiService;
    }

    /**
     * Lấy email từ Authentication - hỗ trợ cả UserDetails, OAuth2User, OidcUser
     */
    private String getEmail(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) return null;

        Object principal = authentication.getPrincipal();

        if (principal instanceof UserDetails) {
            UserDetails userDetails = (UserDetails) principal;
            return userDetails.getUsername();
        }

        if (principal instanceof OidcUser) {
            OidcUser oidcUser = (OidcUser) principal;
            if (oidcUser.getEmail() != null) return oidcUser.getEmail();
            Object emailAttr = oidcUser.getAttributes().get("email");
            return emailAttr != null ? emailAttr.toString() : null;
        }

        if (principal instanceof OAuth2User) {
            OAuth2User oauth2User = (OAuth2User) principal;
            Object emailAttr = oauth2User.getAttributes().get("email");
            return emailAttr != null ? emailAttr.toString() : null;
        }

        return authentication.getName();
    }


    // 🟢 Hiển thị trang hồ sơ
    @GetMapping
    public String viewProfile(Authentication authentication, Model model) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        NguoiDung nguoiDung = userService.findByEmail(email);
        model.addAttribute("user", nguoiDung);
        model.addAttribute("activeTab", "personal");
        model.addAttribute("addresses", diaChiService.getAllByUser(nguoiDung.getId()));

        if (!model.containsAttribute("newAddress")) {
            model.addAttribute("newAddress", new DiaChi());
        }

        // 🟢 Xác định xem user có cần đặt mật khẩu lần đầu không
        boolean showSetPasswordForm = (
                nguoiDung.getMatKhau() == null ||
                nguoiDung.getMatKhau().isBlank() ||
                "GOOGLE_OAUTH_USER".equalsIgnoreCase(nguoiDung.getMatKhau())
        );
        model.addAttribute("showSetPasswordForm", showSetPasswordForm);

        return "profile/profile";
    }

    // 🟢 Cập nhật thông tin cá nhân
    @PostMapping("/update")
    public String updateProfile(@ModelAttribute("user") NguoiDung updatedUser,
                                Authentication authentication,
                                Model model) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        userService.updateUserInfo(email, updatedUser);

        model.addAttribute("user", userService.findByEmail(email));
        model.addAttribute("successMessage", "Cập nhật thông tin thành công!");
        model.addAttribute("activeTab", "personal");

        // ⚡ Không redirect — trả lại trang profile để hiện thông báo
        model.addAttribute("addresses", diaChiService.getAllByUser(userService.findByEmail(email).getId()));
        model.addAttribute("newAddress", new DiaChi());
        return "profile/profile";
    }

    // 🟡 Đổi mật khẩu
    @PostMapping("/change-password")
    public String changePassword(Authentication authentication,
                                 @RequestParam String oldPassword,
                                 @RequestParam String newPassword,
                                 @RequestParam String confirmPassword,
                                 Model model) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        try {
            userService.changePassword(email, oldPassword, newPassword, confirmPassword);
            model.addAttribute("successMessage", "Đổi mật khẩu thành công!");
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
        }

        model.addAttribute("user", userService.findByEmail(email));
        model.addAttribute("activeTab", "password");
        return "profile/profile";
    }

    // 🟢 Cập nhật ảnh đại diện
    @PostMapping("/avatar")
    public String updateAvatar(@RequestParam(value = "avatar", required = false) MultipartFile avatar,
                               @RequestParam(value = "avatarUrl", required = false) String avatarUrl,
                               Authentication authentication,
                               Model model) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        try {
            if ((avatar == null || avatar.isEmpty()) && (avatarUrl == null || avatarUrl.isBlank())) {
                throw new IllegalArgumentException("Vui lòng chọn ảnh hoặc nhập link ảnh.");
            }

            userService.updateAvatar(email, avatar, avatarUrl);
            model.addAttribute("successMessage", "Cập nhật ảnh đại diện thành công!");
        } catch (Exception e) {
            model.addAttribute("errorMessage", e.getMessage());
        }

        model.addAttribute("user", userService.findByEmail(email));
        model.addAttribute("activeTab", "personal");
        model.addAttribute("addresses", diaChiService.getAllByUser(userService.findByEmail(email).getId()));
        model.addAttribute("newAddress", new DiaChi());
        return "profile/profile";
    }

    // 🟢 Lưu hoặc cập nhật địa chỉ
    @PostMapping("/address/save")
    public String saveAddress(Authentication authentication,
                              @ModelAttribute("newAddress") DiaChi diaChi,
                              RedirectAttributes redirectAttributes) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        NguoiDung user = userService.findByEmail(email);
        diaChi.setNguoiDungId(user.getId());
        diaChiService.saveOrUpdate(diaChi);

        redirectAttributes.addFlashAttribute("successMessage", "Đã lưu địa chỉ thành công!");
        redirectAttributes.addFlashAttribute("activeTab", "address");
        return "redirect:/profile?tab=address";
    }

    // 🟢 API trả về địa chỉ theo ID (để edit)
    @GetMapping("/address/get/{id}")
    @ResponseBody
    public DiaChi getAddress(@PathVariable Long id, Authentication authentication) {
        String email = getEmail(authentication);
        if (email == null) {
            return null;
        }

        NguoiDung user = userService.findByEmail(email);
        return diaChiService.getAllByUser(user.getId())
                .stream()
                .filter(dc -> dc.getId().equals(id))
                .findFirst()
                .orElse(null);
    }

    // 🟠 Xóa địa chỉ
    @GetMapping("/address/delete/{id}")
    public String deleteAddress(@PathVariable Long id,
                                Authentication authentication,
                                RedirectAttributes redirectAttributes) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        NguoiDung user = userService.findByEmail(email);
        diaChiService.delete(id, user.getId());

        redirectAttributes.addFlashAttribute("successMessage", "Đã xóa địa chỉ!");
        redirectAttributes.addFlashAttribute("activeTab", "address");
        return "redirect:/profile?tab=address";
    }

    // 🟢 Đặt địa chỉ mặc định
    @GetMapping("/address/set-default/{id}")
    public String setDefaultAddress(@PathVariable Long id,
                                    Authentication authentication,
                                    RedirectAttributes redirectAttributes) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        NguoiDung user = userService.findByEmail(email);
        diaChiService.setDefault(id, user.getId());

        redirectAttributes.addFlashAttribute("successMessage", "Đã đặt địa chỉ mặc định!");
        redirectAttributes.addFlashAttribute("activeTab", "address");
        return "redirect:/profile?tab=address";
    }

    @PostMapping("/set-password")
    public String setPassword(Authentication authentication,
                              @RequestParam String newPassword,
                              @RequestParam String confirmPassword,
                              RedirectAttributes redirectAttributes) {
        String email = getEmail(authentication);
        if (email == null) {
            return "redirect:/auth/login";
        }

        try {
            userService.setInitialPassword(email, newPassword, confirmPassword);
            redirectAttributes.addFlashAttribute("successMessage", "Đặt mật khẩu thành công!");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }

        redirectAttributes.addFlashAttribute("activeTab", "password");
        return "redirect:/profile?tab=password";
    }

}
