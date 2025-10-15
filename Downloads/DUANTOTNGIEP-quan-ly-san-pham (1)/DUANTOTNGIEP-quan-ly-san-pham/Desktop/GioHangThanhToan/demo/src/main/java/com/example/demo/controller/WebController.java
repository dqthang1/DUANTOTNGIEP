package com.example.demo.controller;

import com.example.demo.entity.Product;
import com.example.demo.entity.User;
import com.example.demo.service.CartService;
import com.example.demo.service.ProductService;
import com.example.demo.service.UserService;
import com.example.demo.service.OtpService;
import com.example.demo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Optional;

@Controller
@RequiredArgsConstructor
@Slf4j
public class WebController {
    
    private final UserService userService;
    private final CartService cartService;
    private final ProductService productService;
    private final OtpService otpService;
    private final UserRepository userRepository;
    
    @GetMapping("/")
    public String home(Model model, Authentication authentication) {
        if (authentication != null) {
            User user = getCurrentUser(authentication);
            addUserAttributesToModel(model, user);
        }
        return "index";
    }
    
    @GetMapping("/products")
    public String products(Model model, Authentication authentication) {
        if (authentication != null) {
            User user = getCurrentUser(authentication);
            addUserAttributesToModel(model, user);
        }
        return "products";
    }

    @GetMapping("/products/{id}")
    public String productDetails(@PathVariable Long id, Model model, Authentication authentication) {
        if (authentication != null) {
            User user = getCurrentUser(authentication);
            addUserAttributesToModel(model, user);
        }
        
        // Load product details
        var productOpt = productService.findById(id);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            model.addAttribute("product", product);
            
            // Load product images
            model.addAttribute("productImages", product.getAnhSanPhams());
        }
        
        return "product-detail";
    }
    
    @GetMapping("/cart")
    public String cart(Model model, Authentication authentication) {
        if (authentication == null) {
            return "redirect:/login";
        }
        
        User user = getCurrentUser(authentication);
        addUserAttributesToModel(model, user);
        
        return "cart";
    }
    
    @GetMapping("/checkout")
    public String checkout(Model model, Authentication authentication) {
        if (authentication == null) {
            return "redirect:/login";
        }
        
        User user = getCurrentUser(authentication);
        addUserAttributesToModel(model, user);
        
        return "checkout";
    }
    
    @GetMapping("/orders")
    public String orders(Model model, Authentication authentication) {
        if (authentication == null) {
            return "redirect:/login";
        }
        
        User user = getCurrentUser(authentication);
        addUserAttributesToModel(model, user);
        
        return "orders";
    }
    
    @GetMapping("/orders/{orderId}")
    public String orderDetails(@PathVariable Long orderId, Model model, Authentication authentication) {
        if (authentication == null) {
            return "redirect:/login";
        }
        
        User user = getCurrentUser(authentication);
        addUserAttributesToModel(model, user);
        model.addAttribute("orderId", orderId);
        
        return "order-details";
    }
    
    @GetMapping("/login")
    public String login(Authentication authentication) {
        // Nếu đã đăng nhập thì redirect về trang chủ
        if (authentication != null && authentication.isAuthenticated()) {
            return "redirect:/";
        }
        return "login";
    }
    
    @GetMapping("/register")
    public String register(Authentication authentication) {
        // Nếu đã đăng nhập thì redirect về trang chủ
        if (authentication != null && authentication.isAuthenticated()) {
            return "redirect:/";
        }
        return "register";
    }
    
    @PostMapping("/register")
    public String registerUser(
            @RequestParam String ten,
            @RequestParam String email,
            @RequestParam String soDienThoai,
            @RequestParam(required = false) String ngaySinh,
            @RequestParam(required = false) String gioiTinh,
            @RequestParam String matKhau,
            @RequestParam String confirmMatKhau,
            Model model) {
        
        try {
            // Kiểm tra mật khẩu khớp
            if (!matKhau.equals(confirmMatKhau)) {
                model.addAttribute("error", "Mật khẩu xác nhận không khớp!");
                return "register";
            }
            
            // Kiểm tra email đã tồn tại chưa
            if (userService.findByEmail(email).isPresent()) {
                model.addAttribute("error", "Email này đã được sử dụng!");
                return "register";
            }
            
            // Tạo user mới với email chưa được xác nhận
            User newUser = new User();
            newUser.setTen(ten);
            newUser.setEmail(email);
            newUser.setSoDienThoai(soDienThoai);
            newUser.setNgaySinh(ngaySinh != null && !ngaySinh.isEmpty() ? 
                java.time.LocalDate.parse(ngaySinh) : null);
            newUser.setGioiTinh(gioiTinh != null ? gioiTinh : "Nam");
            newUser.setMatKhau(matKhau); // UserService sẽ encode password
            newUser.setHoatDong(false); // Inactive until email verified
            newUser.setEmailVerified(false); // Email not verified yet
            newUser.setVaiTro(userService.getDefaultRole()); // Set default role
            
            // Lưu user
            User savedUser = userService.save(newUser);
            
            if (savedUser != null) {
                // Gửi OTP để xác nhận email
                boolean otpSent = otpService.sendRegistrationOtp(email);
                
                if (otpSent) {
                    model.addAttribute("success", "Đăng ký thành công! Vui lòng kiểm tra email để xác nhận tài khoản.");
                    model.addAttribute("email", email);
                    return "otp-verification";
                } else {
                    // Nếu gửi OTP thất bại, xóa user đã tạo
                    userRepository.deleteById(savedUser.getId());
                    model.addAttribute("error", "Không thể gửi mã xác nhận. Vui lòng thử lại sau!");
                    return "register";
                }
            } else {
                model.addAttribute("error", "Có lỗi xảy ra khi đăng ký. Vui lòng thử lại!");
                return "register";
            }
            
        } catch (Exception e) {
            log.error("Error during registration", e);
            model.addAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            return "register";
        }
    }
    
    // OTP Verification endpoints
    @GetMapping("/otp-verification")
    public String otpVerificationPage(@RequestParam(required = false) String email, Model model) {
        if (email == null || email.isEmpty()) {
            return "redirect:/register";
        }
        model.addAttribute("email", email);
        return "otp-verification";
    }
    
    @PostMapping("/verify-otp")
    public String verifyOtp(@RequestParam String email, @RequestParam String otpCode, Model model) {
        try {
            boolean verified = otpService.verifyRegistrationOtp(email, otpCode);
            
            if (verified) {
                // Lấy thông tin user để hiển thị trong thông báo
                Optional<User> userOpt = userService.findByEmail(email);
                if (userOpt.isPresent()) {
                    model.addAttribute("user", userOpt.get());
                    model.addAttribute("email", email);
                    return "registration-success";
                } else {
                    model.addAttribute("success", "Email đã được xác nhận thành công! Bạn có thể đăng nhập ngay bây giờ.");
                    return "login";
                }
            } else {
                model.addAttribute("error", "Mã xác nhận không đúng hoặc đã hết hạn. Vui lòng thử lại!");
                model.addAttribute("email", email);
                return "otp-verification";
            }
            
        } catch (Exception e) {
            log.error("Error verifying OTP for {}", email, e);
            model.addAttribute("error", "Có lỗi xảy ra khi xác nhận. Vui lòng thử lại!");
            model.addAttribute("email", email);
            return "otp-verification";
        }
    }
    
    @PostMapping("/resend-otp")
    public String resendOtp(@RequestParam String email, Model model) {
        try {
            boolean otpSent = otpService.resendOtp(email);
            
            if (otpSent) {
                model.addAttribute("success", "Mã xác nhận mới đã được gửi đến email của bạn!");
                model.addAttribute("email", email);
                return "otp-verification";
            } else {
                model.addAttribute("error", "Không thể gửi lại mã xác nhận. Vui lòng thử lại sau ít phút!");
                model.addAttribute("email", email);
                return "otp-verification";
            }
            
        } catch (Exception e) {
            log.error("Error resending OTP to {}", email, e);
            model.addAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại!");
            model.addAttribute("email", email);
            return "otp-verification";
        }
    }
    
    // Registration success page
    @GetMapping("/registration-success")
    public String registrationSuccess(@RequestParam(required = false) String email, Model model) {
        if (email != null && !email.isEmpty()) {
            Optional<User> userOpt = userService.findByEmail(email);
            if (userOpt.isPresent()) {
                model.addAttribute("user", userOpt.get());
                model.addAttribute("email", email);
                return "registration-success";
            }
        }
        
        // Redirect to login if no email provided or user not found
        model.addAttribute("success", "Đăng ký thành công! Bạn có thể đăng nhập ngay bây giờ.");
        return "login";
    }
    
    // Debug endpoint để kiểm tra thông tin user
    @GetMapping("/debug/user")
    public String debugUser(Model model, Authentication authentication) {
        if (authentication == null) {
            model.addAttribute("message", "Chưa đăng nhập");
            return "debug-user";
        }
        
        User user = getCurrentUser(authentication);
        model.addAttribute("user", user);
        
        if (user.getVaiTro() != null) {
            String roleName = user.getVaiTro().getTenVaiTro();
            model.addAttribute("userRole", roleName);
            model.addAttribute("isAdmin", "ADMIN".equalsIgnoreCase(roleName));
            model.addAttribute("isStaff", "STAFF".equalsIgnoreCase(roleName));
        } else {
            model.addAttribute("userRole", "NULL");
            model.addAttribute("isAdmin", false);
            model.addAttribute("isStaff", false);
        }
        
        return "debug-user";
    }
    
    // Debug endpoint để kiểm tra user theo email
    @GetMapping("/debug/user-by-email")
    public String debugUserByEmail(@RequestParam String email, Model model) {
        Optional<User> userOpt = userService.findByEmail(email);
        
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            model.addAttribute("user", user);
            model.addAttribute("found", true);
            model.addAttribute("email", email);
            
            // Kiểm tra các điều kiện đăng nhập
            model.addAttribute("isActive", user.getHoatDong());
            model.addAttribute("isEmailVerified", user.getEmailVerified());
            model.addAttribute("hasRole", user.getVaiTro() != null);
            model.addAttribute("roleName", user.getVaiTro() != null ? user.getVaiTro().getTenVaiTro() : "NULL");
            
            // Kiểm tra password có được encode không
            String password = user.getMatKhau();
            model.addAttribute("passwordLength", password != null ? password.length() : 0);
            model.addAttribute("isPasswordEncoded", password != null && password.startsWith("$2a$"));
            
        } else {
            model.addAttribute("found", false);
            model.addAttribute("email", email);
        }
        
        return "debug-user-by-email";
    }
    
    // Endpoint để kích hoạt tài khoản user (fix cho user cũ)
    @PostMapping("/debug/activate-user")
    public String activateUser(@RequestParam String email, Model model) {
        try {
            Optional<User> userOpt = userService.findByEmail(email);
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                user.setHoatDong(true);
                user.setEmailVerified(true);
                userService.save(user);
                
                // Reload user data after activation
                userOpt = userService.findByEmail(email);
                if (userOpt.isPresent()) {
                    User updatedUser = userOpt.get();
                    model.addAttribute("user", updatedUser);
                    model.addAttribute("found", true);
                    
                    // Kiểm tra các điều kiện đăng nhập sau khi kích hoạt
                    model.addAttribute("isActive", updatedUser.getHoatDong());
                    model.addAttribute("isEmailVerified", updatedUser.getEmailVerified());
                    model.addAttribute("hasRole", updatedUser.getVaiTro() != null);
                    model.addAttribute("roleName", updatedUser.getVaiTro() != null ? updatedUser.getVaiTro().getTenVaiTro() : "NULL");
                    
                    // Kiểm tra password có được encode không
                    String password = updatedUser.getMatKhau();
                    model.addAttribute("passwordLength", password != null ? password.length() : 0);
                    model.addAttribute("isPasswordEncoded", password != null && password.startsWith("$2a$"));
                }
                
                model.addAttribute("success", "Tài khoản đã được kích hoạt thành công!");
                model.addAttribute("email", email);
                log.info("Manually activated user account: {}", email);
            } else {
                model.addAttribute("found", false);
                model.addAttribute("error", "Không tìm thấy user với email: " + email);
                model.addAttribute("email", email);
            }
        } catch (Exception e) {
            model.addAttribute("found", false);
            model.addAttribute("error", "Có lỗi xảy ra khi kích hoạt tài khoản: " + e.getMessage());
            model.addAttribute("email", email);
            log.error("Error activating user account: {}", email, e);
        }
        
        return "debug-user-by-email";
    }
    
    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        log.info("Getting user for email: {}", email);
        
        // Sử dụng findActiveUserByEmail để đảm bảo user active
        User user = userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        log.info("Found user: {}, Active: {}, Role: {}", user.getEmail(), user.getHoatDong(),
            user.getVaiTro() != null ? user.getVaiTro().getTenVaiTro() : "NULL");
        
        return user;
    }
    
    private void addUserAttributesToModel(Model model, User user) {
        if (user != null) {
            model.addAttribute("user", user);
            model.addAttribute("cartItemCount", cartService.getCartItemCount(user.getId()));
            
            // Debug: Log thông tin user và role
            log.info("User: {}, Role: {}", user.getEmail(), 
                user.getVaiTro() != null ? user.getVaiTro().getTenVaiTro() : "NULL");
            
            // Thêm thông tin role để template có thể kiểm tra
            if (user.getVaiTro() != null) {
                String roleName = user.getVaiTro().getTenVaiTro();
                model.addAttribute("userRole", roleName);
                
                // So sánh không phân biệt hoa thường để tránh lỗi
                boolean isAdmin = "ADMIN".equalsIgnoreCase(roleName);
                boolean isStaff = "STAFF".equalsIgnoreCase(roleName);
                
                model.addAttribute("isAdmin", isAdmin);
                model.addAttribute("isStaff", isStaff);
                
                log.info("Role check - Role: {}, isAdmin: {}, isStaff: {}", 
                    roleName, isAdmin, isStaff);
            } else {
                log.warn("User {} has no role assigned!", user.getEmail());
                model.addAttribute("userRole", "USER");
                model.addAttribute("isAdmin", false);
                model.addAttribute("isStaff", false);
            }
        }
    }
}
