package com.example.demo.controller;

import com.example.demo.entity.CartItem;
import com.example.demo.entity.Product;
import com.example.demo.entity.User;
import com.example.demo.service.CartService;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
@Slf4j
public class CartController {
    
    private final CartService cartService;
    private final UserService userService;
    
    /**
     * Lấy giỏ hàng của người dùng
     */
    @GetMapping
    @Transactional(readOnly = true)
    public ResponseEntity<Map<String, Object>> getCart(Authentication authentication) {
        try {
            log.info("Starting getCart for user: {}", authentication.getName());
            User user = getCurrentUser(authentication);
            log.info("User found: {}", user.getId());
            
            log.info("Getting cart items for user: {}", user.getId());
            List<CartItem> cartItems = cartService.getCartItems(user.getId());
            log.info("Cart items count: {}", cartItems.size());
            
            log.info("Getting cart total for user: {}", user.getId());
            BigDecimal total = cartService.getCartTotal(user.getId());
            log.info("Cart total: {}", total);
            
            log.info("Getting cart item count for user: {}", user.getId());
            Integer itemCount = cartService.getCartItemCount(user.getId());
            log.info("Cart item count: {}", itemCount);

            // Build lightweight DTOs to avoid serializing JPA proxies
            log.info("Building DTOs for {} cart items", cartItems.size());
            List<Map<String, Object>> items = cartItems.stream().map(ci -> {
                try {
                    log.debug("Processing cart item: {}", ci.getId());
                    Map<String, Object> product = new HashMap<>();
                    Product sanPham = ci.getSanPham();
                    log.debug("Product for cart item {}: {}", ci.getId(), sanPham != null ? sanPham.getId() : "NULL");
                    
                    if (sanPham == null) {
                        log.error("Product is NULL for cart item: {}", ci.getId());
                        throw new RuntimeException("Product is NULL for cart item: " + ci.getId());
                    }
                    
                    product.put("id", sanPham.getId());
                    product.put("ten", sanPham.getTen());
                    
                    // Try to get image safely
                    try {
                        String anhChinh = sanPham.getAnhChinh();
                        product.put("anhChinh", anhChinh);
                        log.debug("Product image for {}: {}", sanPham.getId(), anhChinh);
                    } catch (Exception e) {
                        log.error("Error getting product image for {}: {}", sanPham.getId(), e.getMessage());
                        product.put("anhChinh", null);
                    }
                    
                    try {
                        BigDecimal gia = sanPham.getGia();
                        product.put("gia", gia != null ? gia.doubleValue() : 0.0);
                        log.debug("Product price for {}: {} (converted to double: {})", sanPham.getId(), gia, gia != null ? gia.doubleValue() : 0.0);
                    } catch (Exception e) {
                        log.error("Error getting product price for {}: {}", sanPham.getId(), e.getMessage());
                        product.put("gia", 0.0);
                    }

                    Map<String, Object> item = new HashMap<>();
                    item.put("id", ci.getId());
                    
                    try {
                        item.put("soLuong", ci.getSoLuong());
                        log.debug("Cart item quantity for {}: {}", ci.getId(), ci.getSoLuong());
                    } catch (Exception e) {
                        log.error("Error getting quantity for cart item {}: {}", ci.getId(), e.getMessage());
                        item.put("soLuong", 0);
                    }
                    
                    try {
                        BigDecimal giaBan = ci.getGiaBan();
                        item.put("gia", giaBan != null ? giaBan.doubleValue() : 0.0);
                        log.debug("Cart item price for {}: {} (converted to double: {})", ci.getId(), giaBan, giaBan != null ? giaBan.doubleValue() : 0.0);
                    } catch (Exception e) {
                        log.error("Error getting price for cart item {}: {}", ci.getId(), e.getMessage());
                        item.put("gia", 0.0);
                    }
                    
                    try {
                        item.put("kichThuoc", ci.getKichThuoc());
                        item.put("mauSac", ci.getMauSac());
                        log.debug("Cart item size/color for {}: {}/{}", ci.getId(), ci.getKichThuoc(), ci.getMauSac());
                    } catch (Exception e) {
                        log.error("Error getting size/color for cart item {}: {}", ci.getId(), e.getMessage());
                        item.put("kichThuoc", null);
                        item.put("mauSac", null);
                    }
                    
                    item.put("sanPham", product);
                    log.debug("Successfully processed cart item: {}", ci.getId());
                    return item;
                } catch (Exception e) {
                    log.error("Error processing cart item {}: {}", ci.getId(), e.getMessage());
                    log.error("Exception details: ", e);
                    throw e;
                }
            }).toList();

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("cartItems", items);
            response.put("total", total != null ? total.doubleValue() : 0.0);
            response.put("itemCount", itemCount);
            
            log.info("Successfully built response with {} items, total: {}, count: {}", 
                items.size(), total, itemCount);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting cart", e);
            log.error("Exception type: {}", e.getClass().getSimpleName());
            log.error("Exception message: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Thêm sản phẩm vào giỏ hàng
     */
    @PostMapping("/add")
    public ResponseEntity<Map<String, Object>> addToCart(
            @RequestParam Long productId,
            @RequestParam(defaultValue = "1") Integer quantity,
            @RequestParam(required = false) String size,
            @RequestParam(required = false) String color,
            @RequestParam(required = false) Long variantId,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            CartItem ci = cartService.addToCart(user.getId(), productId, quantity, size, color, variantId);

            Map<String, Object> product = new HashMap<>();
            product.put("id", ci.getSanPham().getId());
            product.put("ten", ci.getSanPham().getTen());
            product.put("anhChinh", ci.getSanPham().getAnhChinh());
            product.put("gia", ci.getSanPham().getGia() != null ? ci.getSanPham().getGia().doubleValue() : 0.0);

            Map<String, Object> item = new HashMap<>();
            item.put("id", ci.getId());
            item.put("soLuong", ci.getSoLuong());
            item.put("gia", ci.getGiaBan() != null ? ci.getGiaBan().doubleValue() : 0.0);
            item.put("kichThuoc", ci.getKichThuoc());
            item.put("mauSac", ci.getMauSac());
            item.put("sanPham", product);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã thêm sản phẩm vào giỏ hàng");
            response.put("cartItem", item);
            BigDecimal total = cartService.getCartTotal(user.getId());
            response.put("total", total != null ? total.doubleValue() : 0.0);
            response.put("itemCount", cartService.getCartItemCount(user.getId()));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error adding to cart", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Cập nhật số lượng sản phẩm trong giỏ hàng
     */
    @PutMapping("/update/{cartItemId}")
    public ResponseEntity<Map<String, Object>> updateCartItem(
            @PathVariable Long cartItemId,
            @RequestParam Integer quantity,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            CartItem ci = cartService.updateCartItemQuantity(cartItemId, quantity);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã cập nhật số lượng sản phẩm");
            if (ci != null) {
                Map<String, Object> product = new HashMap<>();
                product.put("id", ci.getSanPham().getId());
                product.put("ten", ci.getSanPham().getTen());
                product.put("anhChinh", ci.getSanPham().getAnhChinh());
                product.put("gia", ci.getSanPham().getGia());

                Map<String, Object> item = new HashMap<>();
                item.put("id", ci.getId());
                item.put("soLuong", ci.getSoLuong());
                item.put("gia", ci.getGiaBan());
                item.put("kichThuoc", ci.getKichThuoc());
                item.put("mauSac", ci.getMauSac());
                item.put("sanPham", product);
                response.put("cartItem", item);
            }
            response.put("total", cartService.getCartTotal(user.getId()));
            response.put("itemCount", cartService.getCartItemCount(user.getId()));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error updating cart item", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Xóa sản phẩm khỏi giỏ hàng
     */
    @DeleteMapping("/remove/{cartItemId}")
    public ResponseEntity<Map<String, Object>> removeFromCart(
            @PathVariable Long cartItemId,
            Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            cartService.removeFromCart(cartItemId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã xóa sản phẩm khỏi giỏ hàng");
            response.put("total", cartService.getCartTotal(user.getId()));
            response.put("itemCount", cartService.getCartItemCount(user.getId()));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error removing from cart", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Xóa toàn bộ giỏ hàng
     */
    @DeleteMapping("/clear")
    public ResponseEntity<Map<String, Object>> clearCart(Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            cartService.clearCart(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đã xóa toàn bộ giỏ hàng");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error clearing cart", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy số lượng sản phẩm trong giỏ hàng
     */
    @GetMapping("/count")
    public ResponseEntity<Map<String, Object>> getCartItemCount(Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            Integer itemCount = cartService.getCartItemCount(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("itemCount", itemCount);
            response.put("count", itemCount); // For compatibility with frontend
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting cart count", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    /**
     * Lấy tổng tiền giỏ hàng
     */
    @GetMapping("/total")
    public ResponseEntity<Map<String, Object>> getCartTotal(Authentication authentication) {
        try {
            User user = getCurrentUser(authentication);
            BigDecimal total = cartService.getCartTotal(user.getId());
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("total", total);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting cart total", e);
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
