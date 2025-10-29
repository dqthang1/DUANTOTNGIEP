package com.example.demo.service;

import com.example.demo.entity.*;
import com.example.demo.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CartService cartService;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final DiaChiRepository diaChiRepository;
    
    // Cache for idempotency keys (in production, use Redis)
    private final ConcurrentHashMap<String, IdempotencyEntry> idempotencyCache = new ConcurrentHashMap<>();
    
    // Idempotency entry class
    private static class IdempotencyEntry {
        private final String orderId;
        private final LocalDateTime createdAt;
        
        public IdempotencyEntry(String orderId) {
            this.orderId = orderId;
            this.createdAt = LocalDateTime.now();
        }
        
        public String getOrderId() { return orderId; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        
        public boolean isExpired() {
            return createdAt.isBefore(LocalDateTime.now().minusMinutes(5)); // 5 minutes expiry
        }
    }
    
    /**
     * Tạo đơn hàng từ giỏ hàng với idempotency check
     */
    public Order createOrderFromCart(Long userId, Long addressId, String paymentMethod, String notes, String idempotencyKey) {
        // Check idempotency
        if (idempotencyKey != null && !idempotencyKey.isEmpty()) {
            IdempotencyEntry existingEntry = idempotencyCache.get(idempotencyKey);
            if (existingEntry != null && !existingEntry.isExpired()) {
                log.info("Duplicate order request detected for key: {}", idempotencyKey);
                // Return existing order
                return orderRepository.findById(Long.parseLong(existingEntry.getOrderId()))
                    .orElseThrow(() -> new RuntimeException("Order not found"));
            }
        }
        
        return createOrderFromCartInternal(userId, addressId, paymentMethod, notes, idempotencyKey);
    }
    
    /**
     * Tạo đơn hàng từ giỏ hàng (legacy method for backward compatibility)
     */
    public Order createOrderFromCart(Long userId, Long addressId, String paymentMethod, String notes) {
        return createOrderFromCartInternal(userId, addressId, paymentMethod, notes, null);
    }
    
    /**
     * Internal method to create order from cart
     */
    private Order createOrderFromCartInternal(Long userId, Long addressId, String paymentMethod, String notes, String idempotencyKey) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Lấy địa chỉ giao hàng (ưu tiên addressId, fallback địa chỉ mặc định của user)
        Optional<DiaChi> addressOpt = Optional.empty();
        if (addressId != null) {
            addressOpt = diaChiRepository.findById(addressId);
        }
        if (addressOpt.isEmpty()) {
            addressOpt = diaChiRepository.findDefaultByUserId(userId);
        }
        DiaChi address = addressOpt.orElseThrow(() -> new RuntimeException("Address not found"));
        
        // Lấy giỏ hàng
        List<CartItem> cartItems = cartService.getCartItems(userId);
        if (cartItems.isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }
        
        // Tạo đơn hàng
        Order order = new Order();
        order.setMaDonHang(generateOrderCode());
        order.setNguoiDung(user);
        order.setTenNguoiNhan(address.getTenNguoiNhan());
        order.setSoDienThoai(address.getSoDienThoai());
        order.setDiaChiGiaoHang(buildFullAddress(address));
        order.setPhuongThucThanhToan(paymentMethod);
        order.setGhiChu(notes);
        order.setTrangThai("CHO_XAC_NHAN");
        
        // Tính tổng tiền
        BigDecimal totalAmount = cartItems.stream()
                .map(CartItem::getThanhTien)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        order.setTongTien(totalAmount);
        
        // Tính phí vận chuyển
        BigDecimal shippingFee = calculateShippingFee(totalAmount, address.getTinhThanh());
        order.setPhiVanChuyen(shippingFee);
        order.setTongThanhToan(totalAmount.add(shippingFee));
        
        order = orderRepository.save(order);
        
        // Tạo chi tiết đơn hàng và cập nhật tồn kho
        for (CartItem cartItem : cartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setDonHang(order);
            orderItem.setSanPham(cartItem.getSanPham());
            orderItem.setTenSanPham(cartItem.getSanPham().getTen());
            orderItem.setSoLuong(cartItem.getSoLuong());
            orderItem.setGiaBan(cartItem.getGiaBan());
            orderItem.setThanhTien(cartItem.getThanhTien());
            orderItem.setKichThuoc(cartItem.getKichThuoc());
            orderItem.setMauSac(cartItem.getMauSac());
            orderItem.setBienTheId(cartItem.getBienTheId()); // Thêm bien_the_id
            orderItemRepository.save(orderItem);
            
            // Cập nhật tồn kho
            Product product = cartItem.getSanPham();
            product.setSoLuongTon(product.getSoLuongTon() - cartItem.getSoLuong());
            product.setDaBan(product.getDaBan() + cartItem.getSoLuong());
            productRepository.save(product);
        }
        
        // Xóa giỏ hàng
        cartService.clearCart(userId);
        
        // Store idempotency key if provided
        if (idempotencyKey != null && !idempotencyKey.isEmpty()) {
            idempotencyCache.put(idempotencyKey, new IdempotencyEntry(order.getId().toString()));
            log.info("Stored idempotency key: {} for order: {}", idempotencyKey, order.getId());
        }
        
        log.info("Created order {} for user {}", order.getMaDonHang(), user.getEmail());
        return order;
    }
    
    /**
     * Lấy danh sách đơn hàng của người dùng
     */
    public List<Order> getUserOrders(Long userId) {
        // Use JOIN FETCH query to eagerly load orderItems and products
        List<Order> orders = orderRepository.findByNguoiDungIdWithItems(userId);
        return orders;
    }
    
    /**
     * Lấy chi tiết đơn hàng
     */
    public Optional<Order> getOrderById(Long orderId) {
        return orderRepository.findByIdWithItems(orderId);
    }
    
    /**
     * Cleanup expired idempotency keys
     */
    public void cleanupExpiredIdempotencyKeys() {
        idempotencyCache.entrySet().removeIf(entry -> entry.getValue().isExpired());
        log.info("Cleaned up expired idempotency keys");
    }
    
    /**
     * Lấy đơn hàng theo mã đơn hàng
     */
    public Optional<Order> getOrderByMaDonHang(String maDonHang) {
        return orderRepository.findByMaDonHangWithItems(maDonHang);
    }
    
    /**
     * Lưu đơn hàng
     */
    public Order saveOrder(Order order) {
        return orderRepository.save(order);
    }
    
    /**
     * Lấy đơn hàng theo mã đơn hàng
     */
    public Optional<Order> getOrderByCode(String orderCode) {
        return orderRepository.findByMaDonHangWithItems(orderCode);
    }
    
    /**
     * Cập nhật trạng thái đơn hàng
     */
    public Order updateOrderStatus(Long orderId, String newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        order.setTrangThai(newStatus);
        return orderRepository.save(order);
    }
    
    /**
     * Hủy đơn hàng
     */
    public Order cancelOrder(Long orderId, String reason) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        if (!"CHO_XAC_NHAN".equals(order.getTrangThai())) {
            throw new RuntimeException("Cannot cancel order with status: " + order.getTrangThai());
        }
        
        // Hoàn trả tồn kho
        List<OrderItem> orderItems = orderItemRepository.findByDonHang(order);
        for (OrderItem item : orderItems) {
            Product product = item.getSanPham();
            product.setSoLuongTon(product.getSoLuongTon() + item.getSoLuong());
            product.setDaBan(product.getDaBan() - item.getSoLuong());
            productRepository.save(product);
        }
        
        order.setTrangThai("DA_HUY");
        order.setGhiChu(reason);
        
        log.info("Cancelled order {} for reason: {}", order.getMaDonHang(), reason);
        return orderRepository.save(order);
    }
    
    /**
     * Tính phí vận chuyển
     */
    private BigDecimal calculateShippingFee(BigDecimal orderTotal, String province) {
        // Miễn phí vận chuyển cho đơn hàng trên 500,000 VNĐ
        if (orderTotal.compareTo(BigDecimal.valueOf(500000)) >= 0) {
            return BigDecimal.ZERO;
        }
        
        // Phí vận chuyển theo tỉnh thành
        switch (province) {
            case "TP.HCM":
            case "Hà Nội":
                return BigDecimal.valueOf(30000);
            case "Đà Nẵng":
            case "Cần Thơ":
                return BigDecimal.valueOf(40000);
            default:
                return BigDecimal.valueOf(50000);
        }
    }
    
    /**
     * Tạo mã đơn hàng
     */
    private String generateOrderCode() {
        return "DH" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }
    
    /**
     * Xây dựng địa chỉ đầy đủ
     */
    private String buildFullAddress(DiaChi address) {
        StringBuilder fullAddress = new StringBuilder();
        if (address.getDiaChiChiTiet() != null) {
            fullAddress.append(address.getDiaChiChiTiet());
        }
        if (address.getQuanHuyen() != null) {
            fullAddress.append(", ").append(address.getQuanHuyen());
        }
        if (address.getTinhThanh() != null) {
            fullAddress.append(", ").append(address.getTinhThanh());
        }
        return fullAddress.toString();
    }
    
    /**
     * Lấy thống kê đơn hàng
     */
    public OrderStats getOrderStats(Long userId) {
        List<Order> orders = getUserOrders(userId);
        
        long totalOrders = orders.size();
        long pendingOrders = orders.stream().filter(o -> "CHO_XAC_NHAN".equals(o.getTrangThai())).count();
        long completedOrders = orders.stream().filter(o -> "DA_GIAO".equals(o.getTrangThai())).count();
        long cancelledOrders = orders.stream().filter(o -> "DA_HUY".equals(o.getTrangThai())).count();
        
        BigDecimal totalSpent = orders.stream()
                .filter(o -> "DA_GIAO".equals(o.getTrangThai()))
                .map(Order::getTongTien)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return new OrderStats(totalOrders, pendingOrders, completedOrders, cancelledOrders, totalSpent);
    }
    
    /**
     * Inner class cho thống kê đơn hàng
     */
    public static class OrderStats {
        public final long totalOrders;
        public final long pendingOrders;
        public final long completedOrders;
        public final long cancelledOrders;
        public final BigDecimal totalSpent;
        
        public OrderStats(long totalOrders, long pendingOrders, long completedOrders, 
                         long cancelledOrders, BigDecimal totalSpent) {
            this.totalOrders = totalOrders;
            this.pendingOrders = pendingOrders;
            this.completedOrders = completedOrders;
            this.cancelledOrders = cancelledOrders;
            this.totalSpent = totalSpent;
        }
    }
}
