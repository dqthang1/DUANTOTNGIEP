package com.example.demo.controller;

import com.example.demo.entity.Order;
import com.example.demo.entity.ThanhToan;
import com.example.demo.repository.ThanhToanRepository;
import com.example.demo.service.EmailService;
import com.example.demo.service.OrderService;
import com.example.demo.service.VNPayService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/payment")
@RequiredArgsConstructor
@Slf4j
public class VNPayController {

    private final VNPayService vnPayService;
    private final OrderService orderService;
    private final ThanhToanRepository thanhToanRepository;
    private final EmailService emailService;

    /**
     * Tạo URL thanh toán VNPay cho đơn hàng
     */
    @PostMapping("/vnpay/create")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createPayment(
            @RequestParam Long orderId,
            @RequestParam String ipAddress,
            Authentication authentication) {
        
        try {
            log.info("Creating VNPay payment for order ID: {}", orderId);
            
            // Lấy thông tin đơn hàng
            Order order = orderService.getOrderById(orderId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
            
            log.info("Order found. Status: {}", order.getTrangThai());
            
            // Kiểm tra quyền sở hữu đơn hàng
            String userEmail = authentication.getName();
            log.info("User email: {}", userEmail);
            
            // Safe access to nguoiDung
            if (order.getNguoiDung() == null) {
                log.error("Order has no user!");
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "Đơn hàng không hợp lệ"));
            }
            
            if (!order.getNguoiDung().getEmail().equals(userEmail)) {
                log.warn("User email mismatch. Order user: {}, Current user: {}", 
                         order.getNguoiDung().getEmail(), userEmail);
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "Bạn không có quyền truy cập đơn hàng này"));
            }
            
            // Kiểm tra trạng thái đơn hàng
            if (!"PENDING".equals(order.getTrangThai()) && !"CHO_XAC_NHAN".equals(order.getTrangThai())) {
                log.warn("Invalid order status: {}", order.getTrangThai());
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "message", "Đơn hàng không thể thanh toán. Trạng thái hiện tại: " + order.getTrangThai()));
            }
            
            // Tạo thanh toán record
            ThanhToan thanhToan = new ThanhToan();
            thanhToan.setMaGiaoDich(UUID.randomUUID().toString());
            thanhToan.setSoTien(order.getTongThanhToan());
            thanhToan.setPhuongThuc("VNPAY");
            thanhToan.setTrangThai("CHO_XU_LY");
            thanhToan.setDonHang(order); // Set order object
            thanhToan.setNgayTao(LocalDateTime.now());
            
            log.info("Saving payment record for order ID: {}", order.getId());
            thanhToanRepository.save(thanhToan);
            log.info("Payment record saved successfully with ID: {}", thanhToan.getId());
            
            // Tạo URL thanh toán
            String paymentUrl = vnPayService.createPaymentUrl(order, ipAddress);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("paymentUrl", paymentUrl);
            response.put("message", "Tạo URL thanh toán thành công");
            
            log.info("Created VNPay payment for order: {}", order.getMaDonHang());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error creating VNPay payment", e);
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "Có lỗi xảy ra khi tạo thanh toán: " + e.getMessage()));
        }
    }

    /**
     * Xử lý kết quả thanh toán từ VNPay
     */
    @GetMapping("/vnpay-return")
    public String handlePaymentReturn(
            @RequestParam Map<String, String> vnpParams,
            Model model) {
        
        try {
            log.info("VNPay return with params: {}", vnpParams);
            
            // Lấy thông tin kết quả thanh toán
            Map<String, Object> paymentResult = vnPayService.getPaymentResult(vnpParams);
            
            String orderId = (String) paymentResult.get("orderId");
            boolean isSuccess = (Boolean) paymentResult.get("isSuccess");
            String message = (String) paymentResult.get("message");
            
            // Tìm đơn hàng
            Order order = orderService.getOrderByMaDonHang(orderId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
            
            // Tìm thanh toán
            ThanhToan thanhToan = thanhToanRepository.findByDonHangIdOrderByNgayTaoDesc(order.getId())
                    .stream()
                    .findFirst()
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin thanh toán"));
            
            // Cập nhật thông tin thanh toán
            thanhToan.setMaGiaoDich((String) paymentResult.get("transactionNo"));
            thanhToan.setThongTinThem("Response: " + paymentResult.get("responseCode") + " - " + message);
            
            if (isSuccess) {
                thanhToan.setTrangThai("THANH_CONG");
                thanhToan.setNgayCapNhat(LocalDateTime.now());
                
                // Cập nhật trạng thái đơn hàng
                order.setTrangThai("DA_XAC_NHAN");
                orderService.saveOrder(order);
                
                // Gửi email xác nhận đơn hàng sau khi thanh toán thành công
                try {
                    emailService.sendOrderConfirmationEmail(order);
                    log.info("Order confirmation email sent for order: {}", order.getMaDonHang());
                } catch (Exception e) {
                    log.error("Failed to send order confirmation email for order: {}", order.getMaDonHang(), e);
                }
                
                log.info("Payment successful for order: {}", order.getMaDonHang());
            } else {
                thanhToan.setTrangThai("THAT_BAI");
                log.warn("Payment failed for order: {}", order.getMaDonHang());
            }
            
            thanhToanRepository.save(thanhToan);
            
            // Truyền dữ liệu vào model
            model.addAttribute("order", order);
            model.addAttribute("paymentResult", paymentResult);
            model.addAttribute("isSuccess", isSuccess);
            model.addAttribute("message", message);
            
            return "payment/result";
            
        } catch (Exception e) {
            log.error("Error handling VNPay return", e);
            model.addAttribute("isSuccess", false);
            model.addAttribute("message", "Có lỗi xảy ra khi xử lý kết quả thanh toán: " + e.getMessage());
            return "payment/result";
        }
    }

    /**
     * API để kiểm tra trạng thái thanh toán
     */
    @GetMapping("/status/{orderId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getPaymentStatus(@PathVariable Long orderId) {
        try {
            Order order = orderService.getOrderById(orderId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
            
            ThanhToan thanhToan = thanhToanRepository.findByDonHangIdOrderByNgayTaoDesc(orderId)
                    .stream()
                    .findFirst()
                    .orElse(null);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("orderId", orderId);
            response.put("orderStatus", order.getTrangThai());
            response.put("isPaid", "SUCCESS".equals(thanhToan != null ? thanhToan.getTrangThai() : ""));
            
            if (thanhToan != null) {
                response.put("paymentStatus", thanhToan.getTrangThai());
                response.put("paymentMethod", thanhToan.getPhuongThuc());
                response.put("paymentDate", thanhToan.getNgayCapNhat());
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error getting payment status", e);
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
