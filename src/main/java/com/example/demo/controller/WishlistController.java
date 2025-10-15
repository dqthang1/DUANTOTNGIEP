package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import com.example.demo.service.YeuThichService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/wishlist")
@RequiredArgsConstructor
@Slf4j
public class WishlistController {
    
    private final YeuThichService yeuThichService;
    private final UserService userService;
    
    /**
     * Kiểm tra sản phẩm có trong wishlist không
     */
    @GetMapping("/check/{productId}")
    public ResponseEntity<Map<String, Object>> checkWishlistStatus(
            @PathVariable Long productId,
            Authentication authentication) {
        
        try {
            if (authentication == null) {
                return ResponseEntity.ok(Map.of("success", true, "isInWishlist", false));
            }
            
            User user = getCurrentUser(authentication);
            boolean isInWishlist = yeuThichService.isInWishlist(user.getId(), productId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("isInWishlist", isInWishlist);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error checking wishlist status", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Thêm/xóa sản phẩm khỏi wishlist
     */
    @PostMapping("/toggle/{productId}")
    public ResponseEntity<Map<String, Object>> toggleWishlist(
            @PathVariable Long productId,
            Authentication authentication) {
        
        try {
            if (authentication == null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Vui lòng đăng nhập"));
            }
            
            User user = getCurrentUser(authentication);
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
                response.put("isInWishlist", !isInWishlist);
                response.put("message", !isInWishlist ? "Đã thêm vào yêu thích" : "Đã xóa khỏi yêu thích");
                
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Không thể thực hiện thao tác"));
            }
        } catch (Exception e) {
            log.error("Error toggling wishlist", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy danh sách wishlist của user
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getWishlist(Authentication authentication) {
        try {
            if (authentication == null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Vui lòng đăng nhập"));
            }
            
            User user = getCurrentUser(authentication);
            var wishlist = yeuThichService.getWishlistByUserId(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("wishlist", wishlist);
            response.put("count", wishlist.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting wishlist", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Xóa sản phẩm khỏi wishlist
     */
    @DeleteMapping("/{productId}")
    public ResponseEntity<Map<String, Object>> removeFromWishlist(
            @PathVariable Long productId,
            Authentication authentication) {
        
        try {
            if (authentication == null) {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Vui lòng đăng nhập"));
            }
            
            User user = getCurrentUser(authentication);
            boolean result = yeuThichService.removeFromWishlist(user.getId(), productId);
            
            if (result) {
                return ResponseEntity.ok(Map.of("success", true, "message", "Đã xóa khỏi yêu thích"));
            } else {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Sản phẩm không có trong yêu thích"));
            }
        } catch (Exception e) {
            log.error("Error removing from wishlist", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
