package com.example.demo.controller;

import com.example.demo.dto.OrderTrackingDTO;
import com.example.demo.entity.Order;
import com.example.demo.entity.User;
import com.example.demo.repository.OrderRepository;
import com.example.demo.service.CartService;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import jakarta.mail.MessagingException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/hotline")
@RequiredArgsConstructor
@Slf4j
public class HotlineController {

    private final UserService userService;
    private final CartService cartService;
    private final JavaMailSender mailSender;
    private final OrderRepository orderRepository;
    private final TemplateEngine templateEngine;

    @GetMapping
    public String hotline(Model model, Authentication authentication) {
        if (authentication != null) {
            User user = getCurrentUser(authentication);
            addUserAttributesToModel(model, user);
        }
        
        // Thêm thông tin hotline
        model.addAttribute("hotlineInfo", getHotlineInfo());
        model.addAttribute("workingHours", getWorkingHours());
        model.addAttribute("departments", getDepartments());
        
        return "hotline";
    }

    @PostMapping("/contact")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> submitContact(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String phone,
            @RequestParam String subject,
            @RequestParam String message,
            @RequestParam String department,
            Authentication authentication,
            HttpServletRequest request,
            HttpServletResponse response) {
        try {
            // Kiểm tra các trường bắt buộc
            if (name.trim().isEmpty() || email.trim().isEmpty() || message.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false, 
                    "message", "Vui lòng điền đầy đủ thông tin bắt buộc"
                ));
            }

            // Kiểm tra định dạng email
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false, 
                    "message", "Email không hợp lệ"
                ));
            }

            // Tạo mã tham chiếu
            String referenceCode = generateReferenceCode();
            
            // Gửi email thông báo đến team hỗ trợ
            sendContactEmailToSupport(name, email, phone, subject, message, department, referenceCode);
            
            // Gửi email tự động phản hồi cho khách hàng
            sendAutoReplyEmail(name, email, subject, department, referenceCode, request, response);
            
            return ResponseEntity.ok(Map.of(
                "success", true, 
                "message", "Đã nhận yêu cầu! Mã " + referenceCode + ". Chúng tôi sẽ phản hồi trong 24 giờ làm việc.",
                "referenceCode", referenceCode
            ));
        } catch (Exception e) {
            log.error("Lỗi khi gửi form liên hệ", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false, 
                "message", "Có lỗi xảy ra khi gửi liên hệ. Vui lòng thử lại sau."
            ));
        }
    }

    private String generateReferenceCode() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        // Sequence đơn giản dựa trên thời gian hiện tại (trong production, sử dụng database sequence)
        String sequence = String.format("%03d", (int) (System.currentTimeMillis() % 1000));
        return "HT-" + dateStr + "-" + sequence;
    }

    private void sendContactEmailToSupport(String name, String email, String phone, String subject, String message, String department, String referenceCode) throws MessagingException {
        try {
            var mailMessage = mailSender.createMimeMessage();
            var helper = new MimeMessageHelper(mailMessage, true, "UTF-8");
            
            helper.setTo("datnfpolysd45@gmail.com"); // Email hỗ trợ chính thức
            helper.setSubject("Liên hệ từ khách hàng - " + subject + " [" + referenceCode + "]");
            
            String emailContent = String.format("""
                Thông tin liên hệ từ khách hàng:
                
                Mã tham chiếu: %s
                Họ tên: %s
                Email: %s
                Số điện thoại: %s
                Chủ đề: %s
                Bộ phận: %s
                Thời gian: %s
                
                Nội dung:
                %s
                
                ---
                Email được gửi tự động từ hệ thống.
                """, 
                referenceCode, name, email, phone, subject, department, 
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")), 
                message);
            
            helper.setText(emailContent, false);
            mailSender.send(mailMessage);
            
            log.info("Đã gửi email thông báo hỗ trợ thành công cho: {} [{}]", email, referenceCode);
        } catch (Exception e) {
            log.error("Lỗi khi gửi email thông báo hỗ trợ", e);
            throw e;
        }
    }

    private void sendAutoReplyEmail(String name, String email, String subject, String department, String referenceCode, HttpServletRequest request, HttpServletResponse response) throws MessagingException {
        try {
            var mailMessage = mailSender.createMimeMessage();
            var helper = new MimeMessageHelper(mailMessage, true, "UTF-8");
            
            helper.setTo(email);
            helper.setSubject("[Activewear] Xác nhận yêu cầu " + referenceCode);
            
            // Chuẩn bị context cho template
            ServletContext servletContext = request.getServletContext();
            var webApplication = JakartaServletWebApplication.buildApplication(servletContext);
            var webExchange = webApplication.buildExchange(request, response);
            WebContext context = new WebContext(webExchange);
            context.setVariable("name", name);
            context.setVariable("email", email);
            context.setVariable("subject", getSubjectDisplayName(subject));
            context.setVariable("department", getDepartmentDisplayName(department));
            context.setVariable("referenceCode", referenceCode);
            context.setVariable("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
            
            // Xử lý template
            String htmlContent = templateEngine.process("email/contact-confirmation", context);
            
            helper.setText(htmlContent, true);
            mailSender.send(mailMessage);
            
            log.info("Đã gửi email tự động phản hồi thành công đến: {} [{}]", email, referenceCode);
        } catch (Exception e) {
            log.error("Lỗi khi gửi email tự động phản hồi", e);
            throw e;
        }
    }

    private String getSubjectDisplayName(String subject) {
        return switch (subject) {
            case "order_support" -> "Hỗ trợ đơn hàng";
            case "complaint" -> "Khiếu nại";
            case "product" -> "Sản phẩm";
            case "partnership" -> "Đối tác";
            case "other" -> "Khác";
            default -> subject;
        };
    }

    private String getDepartmentDisplayName(String department) {
        return switch (department) {
            case "customer_service" -> "Dịch vụ khách hàng (CSKH)";
            case "technical_support" -> "Hỗ trợ kỹ thuật";
            case "sales" -> "Bán hàng";
            case "accounting" -> "Kế toán";
            default -> department;
        };
    }

    private User getCurrentUser(Authentication authentication) {
        String email = authentication.getName();
        return userService.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private void addUserAttributesToModel(Model model, User user) {
        if (user != null) {
            model.addAttribute("user", user);
            model.addAttribute("cartItemCount", cartService.getCartItemCount(user.getId()));
            
            if (user.getVaiTro() != null) {
                String roleName = user.getVaiTro().getTenVaiTro();
                model.addAttribute("userRole", roleName);
                boolean isAdmin = "ADMIN".equalsIgnoreCase(roleName);
                boolean isStaff = "STAFF".equalsIgnoreCase(roleName);
                model.addAttribute("isAdmin", isAdmin);
                model.addAttribute("isStaff", isStaff);
            }
        }
    }

    private Map<String, Object> getHotlineInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("mainPhone", "1900 1234");
        info.put("mainPhoneDisplay", "1900 1234");
        info.put("email", "datnfpolysd45@gmail.com");
        info.put("address", "123 Đường ABC, Quận 1, TP.HCM");
        info.put("website", "www.example.com");
        return info;
    }

    private Map<String, Object> getWorkingHours() {
        Map<String, Object> hours = new HashMap<>();
        hours.put("weekdays", "8:00 - 22:00");
        hours.put("weekends", "9:00 - 21:00");
        hours.put("holidays", "10:00 - 18:00");
        return hours;
    }

    private Map<String, String> getDepartments() {
        Map<String, String> departments = new HashMap<>();
        departments.put("customer_service", "Dịch vụ khách hàng");
        departments.put("technical_support", "Hỗ trợ kỹ thuật");
        departments.put("sales", "Bán hàng");
        departments.put("complaint", "Khiếu nại");
        departments.put("partnership", "Đối tác");
        return departments;
    }

    /**
     * API: Tra cứu đơn hàng
     */
    @GetMapping("/api/orders/track")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> trackOrder(
            @RequestParam String code,
            @RequestParam(required = false) String contact) {
        try {
            // Tìm đơn hàng theo mã
            Order order = orderRepository.findByMaDonHang(code)
                    .orElse(null);

            if (order == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Không tìm thấy đơn hàng với mã: " + code
                ));
            }

            // Bảo mật cơ bản: nếu có thông tin liên hệ, xác minh khớp
            if (contact != null && !contact.trim().isEmpty()) {
                String orderContact = order.getNguoiDung().getEmail();
                if (!orderContact.equals(contact.trim()) && 
                    !order.getNguoiDung().getSoDienThoai().equals(contact.trim())) {
                    return ResponseEntity.badRequest().body(Map.of(
                        "success", false,
                        "message", "Thông tin liên hệ không khớp với đơn hàng"
                    ));
                }
            }

            // Xây dựng tracking DTO
            OrderTrackingDTO trackingDTO = new OrderTrackingDTO();
            trackingDTO.setOrderCode(order.getMaDonHang());
            trackingDTO.setStatus(order.getTrangThai());
            trackingDTO.setCreatedAt(order.getNgayDatHang());
            trackingDTO.setTotalAmount(order.getTongTien());
            trackingDTO.setTrackingNumber(null); // Không có trường tracking number trong Order entity

            // Map các item đơn hàng
            List<OrderTrackingDTO.OrderItemDTO> items = order.getOrderItems()
                    .stream()
                    .map(item -> new OrderTrackingDTO.OrderItemDTO(
                            item.getTenSanPham(),
                            item.getSoLuong(),
                            item.getGiaBan()
                    ))
                    .collect(java.util.stream.Collectors.toList());
            trackingDTO.setItems(items);

            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", trackingDTO
            ));

        } catch (Exception e) {
            log.error("Lỗi khi tra cứu đơn hàng", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi tra cứu đơn hàng"
            ));
        }
    }
}
