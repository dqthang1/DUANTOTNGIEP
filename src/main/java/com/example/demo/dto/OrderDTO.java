package com.example.demo.dto;

import com.example.demo.entity.Order;
import com.example.demo.entity.OrderItem;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderDTO {
    
    private Long id;
    private String maDonHang;
    private BigDecimal tongTien;
    private BigDecimal phiVanChuyen;
    private BigDecimal tongThanhToan;
    private String tenNguoiNhan;
    private String soDienThoai;
    private String diaChiGiaoHang;
    private String trangThai;
    private String phuongThucThanhToan;
    private String ghiChu;
    private LocalDateTime ngayDatHang;
    private LocalDateTime ngayGiaoHang;
    private LocalDateTime ngayCapNhat;
    private Long vanChuyenId;
    private List<OrderItemDTO> orderItems;
    
    /**
     * Convert từ Order entity sang DTO
     */
    public static OrderDTO fromEntity(Order order) {
        if (order == null) {
            return null;
        }
        
        OrderDTO dto = new OrderDTO();
        dto.setId(order.getId());
        dto.setMaDonHang(order.getMaDonHang());
        dto.setTongTien(order.getTongTien());
        dto.setPhiVanChuyen(order.getPhiVanChuyen());
        dto.setTongThanhToan(order.getTongThanhToan());
        dto.setTenNguoiNhan(order.getTenNguoiNhan());
        dto.setSoDienThoai(order.getSoDienThoai());
        dto.setDiaChiGiaoHang(order.getDiaChiGiaoHang());
        dto.setTrangThai(order.getTrangThai());
        dto.setPhuongThucThanhToan(order.getPhuongThucThanhToan());
        dto.setGhiChu(order.getGhiChu());
        dto.setNgayDatHang(order.getNgayDatHang());
        dto.setNgayGiaoHang(order.getNgayGiaoHang());
        dto.setNgayCapNhat(order.getNgayCapNhat());
        dto.setVanChuyenId(order.getVanChuyenId());
        
        // Convert order items
        if (order.getOrderItems() != null) {
            dto.setOrderItems(order.getOrderItems().stream()
                    .map(OrderItemDTO::fromEntity)
                    .collect(Collectors.toList()));
        }
        
        return dto;
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemDTO {
        private Long id;
        private Long productId;
        private String productName;
        private String productImage;
        private Integer soLuong;
        private BigDecimal donGia;
        private BigDecimal thanhTien;
        private String kichCo;
        private String mauSac;
        private Long variantId;
        
        public static OrderItemDTO fromEntity(OrderItem item) {
            if (item == null) {
                return null;
            }
            
            OrderItemDTO dto = new OrderItemDTO();
            dto.setId(item.getId());
            
            // Safely get product ID, name and image without triggering lazy load
            try {
                if (item.getSanPham() != null) {
                    dto.setProductId(item.getSanPham().getId());
                    dto.setProductName(item.getSanPham().getTen());
                    dto.setProductImage(item.getSanPham().getAnhChinh());
                } else {
                    dto.setProductId(null);
                    dto.setProductName(item.getTenSanPham());
                    dto.setProductImage(null);
                }
            } catch (Exception e) {
                // If lazy loading fails, use stored product name
                dto.setProductId(null);
                dto.setProductName(item.getTenSanPham());
                dto.setProductImage(null);
            }
            
            dto.setSoLuong(item.getSoLuong());
            dto.setDonGia(item.getGiaBan());
            dto.setThanhTien(item.getThanhTien());
            dto.setKichCo(item.getKichThuoc());
            dto.setMauSac(item.getMauSac());
            dto.setVariantId(item.getBienTheId());
            
            return dto;
        }
    }
}

