package com.example.demo.service;

import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class CartService {
    
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final BienTheSanPhamRepository bienTheSanPhamRepository;
    
    /**
     * Lấy giỏ hàng của người dùng
     */
    public Optional<Cart> getCartByUser(User user) {
        return cartRepository.findByNguoiDung(user);
    }
    
    /**
     * Tạo giỏ hàng mới cho người dùng
     */
    public Cart createCart(User user) {
        Cart cart = new Cart();
        cart.setNguoiDung(user);
        return cartRepository.save(cart);
    }
    
    /**
     * Lấy hoặc tạo giỏ hàng cho người dùng
     */
    public Cart getOrCreateCart(User user) {
        return cartRepository.findByNguoiDung(user)
                .orElseGet(() -> createCart(user));
    }
    
    /**
     * Thêm sản phẩm vào giỏ hàng
     */
    public CartItem addToCart(Long userId, Long productId, Integer quantity, String size, String color, Long variantId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        // Validate stock
        if (!product.getHoatDong()) {
            throw new RuntimeException("Product not available");
        }
        
        // If variantId is provided, check variant stock, otherwise check product stock
        if (variantId != null) {
            BienTheSanPham variant = bienTheSanPhamRepository.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Variant not found"));
            
            if (variant.getSoLuongTon() < quantity) {
                throw new RuntimeException("Insufficient variant stock");
            }
        } else if (product.getSoLuongTon() < quantity) {
            throw new RuntimeException("Insufficient product stock");
        }
        
        Cart cart = getOrCreateCart(user);
        
        // Kiểm tra xem sản phẩm với variant này đã có trong giỏ chưa
        Optional<CartItem> existingItem;
        if (variantId != null) {
            existingItem = cartItemRepository.findByGioHangIdAndBienTheId(cart.getId(), variantId);
        } else {
            existingItem = cartItemRepository.findByCartAndProductAndVariants(cart.getId(), productId, size, color);
        }
        
        if (existingItem.isPresent()) {
            // Tăng số lượng nếu đã có
            CartItem item = existingItem.get();
            item.setSoLuong(item.getSoLuong() + quantity);
            return cartItemRepository.save(item);
        } else {
            // Tạo mới
            CartItem newItem = new CartItem();
            newItem.setGioHang(cart);
            newItem.setSanPham(product);
            newItem.setSoLuong(quantity);
            newItem.setKichThuoc(size);
            newItem.setMauSac(color);
            newItem.setBienTheId(variantId);
            
            // Set giá: ưu tiên variant price, fallback to product price
            if (variantId != null) {
                BienTheSanPham variant = bienTheSanPhamRepository.findById(variantId).get();
                newItem.setGiaBan(variant.getGiaKhuyenMai() != null ? variant.getGiaKhuyenMai() : variant.getGiaBan());
            } else {
                newItem.setGiaBan(product.getGia());
            }
            
            return cartItemRepository.save(newItem);
        }
    }
    
    /**
     * Cập nhật số lượng sản phẩm trong giỏ hàng
     */
    public CartItem updateCartItemQuantity(Long cartItemId, Integer newQuantity) {
        CartItem cartItem = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        
        if (newQuantity <= 0) {
            cartItemRepository.delete(cartItem);
            return null;
        }
        
        // Kiểm tra tồn kho
        if (cartItem.getSanPham().getSoLuongTon() < newQuantity) {
            throw new RuntimeException("Insufficient stock");
        }
        
        cartItem.setSoLuong(newQuantity);
        return cartItemRepository.save(cartItem);
    }
    
    /**
     * Xóa sản phẩm khỏi giỏ hàng
     */
    public void removeFromCart(Long cartItemId) {
        cartItemRepository.deleteById(cartItemId);
    }
    
    /**
     * Xóa toàn bộ giỏ hàng
     */
    public void clearCart(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Optional<Cart> cartOpt = cartRepository.findByNguoiDung(user);
        if (cartOpt.isPresent()) {
            cartItemRepository.deleteByGioHang(cartOpt.get());
        }
    }
    
    /**
     * Lấy danh sách sản phẩm trong giỏ hàng
     */
    @Transactional(readOnly = true)
    public List<CartItem> getCartItems(Long userId) {
        log.info("Getting cart items for user: {}", userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        log.info("User found: {}", user.getId());
        
        Optional<Cart> cartOpt = cartRepository.findByNguoiDung(user);
        log.info("Cart found: {}", cartOpt.isPresent());
        
        if (cartOpt.isPresent()) {
            Cart cart = cartOpt.get();
            log.info("Cart ID: {}", cart.getId());
            List<CartItem> items = cartItemRepository.findByGioHang(cart);
            log.info("Found {} cart items", items.size());
            for (CartItem item : items) {
                log.debug("Cart item {} - Product: {}", item.getId(), item.getSanPham() != null ? item.getSanPham().getId() : "NULL");
                if (item.getSanPham() != null) {
                    log.debug("Product details - ID: {}, Name: {}, Image: {}", 
                        item.getSanPham().getId(), 
                        item.getSanPham().getTen(),
                        item.getSanPham().getAnhChinh());
                }
            }
            return items;
        }
        log.info("No cart found for user: {}", userId);
        return List.of();
    }
    
    /**
     * Tính tổng tiền giỏ hàng
     */
    @Transactional(readOnly = true)
    public BigDecimal getCartTotal(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Optional<Cart> cartOpt = cartRepository.findByNguoiDung(user);
        if (cartOpt.isPresent()) {
            Double total = cartItemRepository.getTotalAmountByCartId(cartOpt.get().getId());
            return total != null ? BigDecimal.valueOf(total) : BigDecimal.ZERO;
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Đếm số lượng sản phẩm trong giỏ hàng
     */
    @Transactional(readOnly = true)
    public Integer getCartItemCount(Long userId) {
        List<CartItem> items = getCartItems(userId);
        return items.stream()
                .mapToInt(CartItem::getSoLuong)
                .sum();
    }
}
