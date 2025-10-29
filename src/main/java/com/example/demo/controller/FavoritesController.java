package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import com.example.demo.service.YeuThichService;
import com.example.demo.service.ProductService;
import com.example.demo.service.CartService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/favorites")
@RequiredArgsConstructor
@Slf4j
public class FavoritesController {
    
    private final YeuThichService yeuThichService;
    private final UserService userService;
    private final ProductService productService;
    private final CartService cartService;
    
    /**
     * Hiển thị trang favorites
     */
    @GetMapping
    @Transactional(readOnly = true)
    public String favoritesPage(Model model, Authentication authentication) {
        if (authentication != null) {
            User user = getCurrentUser(authentication);
            addUserAttributesToModel(model, user);
            var wishlist = yeuThichService.getWishlistByUserId(user.getId());
            model.addAttribute("favorites", wishlist);
            model.addAttribute("favoritesCount", wishlist.size());
        } else {
            model.addAttribute("user", null);
            model.addAttribute("favorites", java.util.Collections.emptyList());
            model.addAttribute("favoritesCount", 0);
            model.addAttribute("cartItemCount", 0);
            model.addAttribute("isAdmin", false);
            model.addAttribute("isStaff", false);
        }
        return "favorites";
    }
    
    /**
     * Thêm/xóa sản phẩm khỏi favorites (alias cho wishlist)
     */
    @PostMapping("/api/toggle")
    public ResponseEntity<Map<String, Object>> toggleFavorite(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {
        
        try {
            if (authentication == null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Vui lòng đăng nhập"));
            }
            
            User user = getCurrentUser(authentication);
            Long productId = Long.valueOf(request.get("productId").toString());
            
            boolean isInWishlist = yeuThichService.isInWishlist(user.getId(), productId);
            
            boolean result;
            if (isInWishlist) {
                result = yeuThichService.removeFromWishlist(user.getId(), productId);
            } else {
                result = yeuThichService.addToWishlist(user.getId(), productId);
            }
            
            if (result) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("isFavorite", !isInWishlist);
                response.put("message", !isInWishlist ? "Đã thêm vào yêu thích" : "Đã xóa khỏi yêu thích");
                
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Không thể thực hiện thao tác"));
            }
        } catch (Exception e) {
            log.error("Error toggling favorite", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * API lấy sản phẩm gợi ý
     */
    @GetMapping("/api/recommendations")
    public ResponseEntity<Map<String, Object>> getRecommendations(
            @RequestParam(defaultValue = "6") int limit,
            Authentication authentication) {
        
        try {
            var recommendations = productService.getRecommendedProducts(limit);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("products", recommendations);
            response.put("count", recommendations.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Lỗi khi lấy sản phẩm gợi ý", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
    
    private void addUserAttributesToModel(Model model, User user) {
        if (user != null) {
            model.addAttribute("user", user);
            model.addAttribute("cartItemCount", cartService.getCartItemCount(user.getId()));
            
            // Add role information
            if (user.getVaiTro() != null) {
                String roleName = user.getVaiTro().getTenVaiTro();
                model.addAttribute("userRole", roleName);
                
                boolean isAdmin = "ADMIN".equalsIgnoreCase(roleName);
                boolean isStaff = "STAFF".equalsIgnoreCase(roleName);
                
                model.addAttribute("isAdmin", isAdmin);
                model.addAttribute("isStaff", isStaff);
            } else {
                model.addAttribute("userRole", "USER");
                model.addAttribute("isAdmin", false);
                model.addAttribute("isStaff", false);
            }
        }
    }
}
