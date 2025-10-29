package com.example.demo.service;

import com.example.demo.dto.InventoryHistoryResponse;
import com.example.demo.dto.InventoryResponse;
import com.example.demo.dto.InventoryUpdateRequest;
import com.example.demo.entity.LichSuTonKho;
import com.example.demo.entity.Product;
import com.example.demo.repository.LichSuTonKhoRepository;
import com.example.demo.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryService {
    
    private final ProductRepository productRepository;
    private final LichSuTonKhoRepository lichSuTonKhoRepository;
    
    private static final int LOW_STOCK_THRESHOLD = 10;
    private static final int OUT_OF_STOCK_THRESHOLD = 0;
    
    /**
     * Lấy danh sách tồn kho tất cả sản phẩm
     */
    @Transactional(readOnly = true)
    public Page<InventoryResponse> getAllInventory(String search, String status, Pageable pageable) {
        // Get all products first (no pagination yet)
        List<Product> allProducts;
        
        if (search != null && !search.trim().isEmpty()) {
            // For search, we need to get all matching products first
            allProducts = productRepository.findByTenContainingIgnoreCaseOrMaSanPhamContainingIgnoreCase(search, search);
        } else {
            allProducts = productRepository.findByHoatDongTrue();
        }
        
        // Convert to InventoryResponse
        List<InventoryResponse> inventoryList = allProducts.stream()
            .map(product -> convertToInventoryResponse(product))
            .collect(Collectors.toList());
        
        // Filter by status if provided
        if (status != null && !status.trim().isEmpty()) {
            inventoryList = inventoryList.stream()
                .filter(inv -> inv.getStatus().equals(status))
                .collect(Collectors.toList());
        }
        
        // Now apply pagination manually
        int totalElements = inventoryList.size();
        int totalPages = (int) Math.ceil((double) totalElements / pageable.getPageSize());
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), totalElements);
        
        List<InventoryResponse> pageContent = inventoryList.subList(start, end);
        
        return new PageImpl<>(pageContent, pageable, totalElements);
    }
    
    /**
     * Lấy sản phẩm sắp hết hàng (tồn kho < threshold)
     */
    @Transactional(readOnly = true)
    public List<InventoryResponse> getLowStockProducts(int threshold) {
        List<Product> products = productRepository.findByHoatDongTrue();
        
        return products.stream()
            .filter(p -> p.getSoLuongTon() != null && p.getSoLuongTon() <= threshold)
            .map(product -> convertToInventoryResponse(product))
            .collect(Collectors.toList());
    }
    
    /**
     * Cập nhật tồn kho cho sản phẩm
     */
    @Transactional
    public InventoryResponse updateInventory(Long productId, InventoryUpdateRequest request) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm với ID: " + productId));
        
        int oldQuantity = product.getSoLuongTon() != null ? product.getSoLuongTon() : 0;
        int newQuantity = calculateNewQuantity(oldQuantity, request.getQuantity(), request.getLoaiThayDoi());
        
        // Validate
        if (newQuantity < 0) {
            throw new RuntimeException("Số lượng tồn kho không thể âm!");
        }
        
        // Update product stock
        product.setSoLuongTon(newQuantity);
        productRepository.save(product);
        
        // Save history
        saveInventoryHistory(product, oldQuantity, newQuantity, request, 1L); // Mock user ID
        
        log.info("Updated inventory for product {}: {} -> {}", product.getId(), oldQuantity, newQuantity);
        
        return convertToInventoryResponse(product);
    }
    
    /**
     * Bulk update tồn kho
     */
    @Transactional
    public List<InventoryResponse> bulkUpdateInventory(List<InventoryUpdateRequest> requests) {
        List<InventoryResponse> results = new ArrayList<>();
        
        for (InventoryUpdateRequest request : requests) {
            try {
                InventoryResponse result = updateInventory(request.getProductId(), request);
                results.add(result);
            } catch (Exception e) {
                log.error("Error updating inventory for product {}: {}", request.getProductId(), e.getMessage());
                // Continue with next product
            }
        }
        
        return results;
    }
    
    /**
     * Lấy lịch sử thay đổi tồn kho
     */
    @Transactional(readOnly = true)
    public Page<InventoryHistoryResponse> getInventoryHistory(Long productId, String loaiThayDoi, 
                                                   LocalDateTime startDate, LocalDateTime endDate,
                                                   Pageable pageable) {
        Page<LichSuTonKho> historyPage;
        
        if (productId != null) {
            historyPage = lichSuTonKhoRepository.findBySanPhamIdOrderByNgayThayDoiDesc(productId, pageable);
        } else if (loaiThayDoi != null) {
            historyPage = lichSuTonKhoRepository.findByLoaiThayDoiOrderByNgayThayDoiDesc(loaiThayDoi, pageable);
        } else if (startDate != null && endDate != null) {
            historyPage = lichSuTonKhoRepository.findByDateRange(startDate, endDate, pageable);
        } else {
            historyPage = lichSuTonKhoRepository.findAll(pageable);
        }
        
        return historyPage.map(this::convertToHistoryResponse);
    }
    
    /**
     * Convert LichSuTonKho entity to InventoryHistoryResponse DTO
     */
    private InventoryHistoryResponse convertToHistoryResponse(LichSuTonKho history) {
        InventoryHistoryResponse response = new InventoryHistoryResponse();
        response.setId(history.getId());
        response.setProductId(history.getSanPham().getId());
        response.setProductName(history.getSanPham().getTen());
        response.setProductCode(history.getSanPham().getMaSanPham());
        response.setSoLuongCu(history.getSoLuongCu());
        response.setSoLuongMoi(history.getSoLuongMoi());
        response.setSoLuongThayDoi(history.getSoLuongThayDoi());
        response.setLoaiThayDoi(history.getLoaiThayDoi());
        response.setLyDo(history.getLyDo());
        response.setNguoiThayDoi(history.getNguoiThayDoi());
        response.setNgayThayDoi(history.getNgayThayDoi());
        return response;
    }
    
    /**
     * Đếm số sản phẩm theo trạng thái
     */
    @Transactional(readOnly = true)
    public long countByStatus(String status) {
        List<Product> products = productRepository.findByHoatDongTrue();
        
        return products.stream()
            .filter(p -> {
                String productStatus = getStockStatus(p.getSoLuongTon());
                return productStatus.equals(status);
            })
            .count();
    }
    
    /**
     * Helper: Tính số lượng mới
     */
    private int calculateNewQuantity(int oldQuantity, int quantity, String type) {
        switch (type) {
            case "NHAP_KHO":
            case "TRA_HANG":
            case "HUY_DON":
                return oldQuantity + quantity;
            case "XUAT_KHO":
            case "BAN_HANG":
                return oldQuantity - quantity;
            case "DIEU_CHINH":
            case "KIEM_KE":
                return quantity; // Set directly
            default:
                return oldQuantity;
        }
    }
    
    /**
     * Helper: Lưu lịch sử tồn kho
     */
    private void saveInventoryHistory(Product product, int oldQuantity, int newQuantity, 
                                      InventoryUpdateRequest request, Long userId) {
        LichSuTonKho history = new LichSuTonKho();
        history.setSanPham(product);
        history.setSoLuongCu(oldQuantity);
        history.setSoLuongMoi(newQuantity);
        history.setSoLuongThayDoi(Math.abs(newQuantity - oldQuantity));
        history.setLoaiThayDoi(request.getLoaiThayDoi());
        history.setLyDo(request.getLyDo());
        history.setNguoiThayDoi(userId);
        history.setNgayThayDoi(LocalDateTime.now());
        
        lichSuTonKhoRepository.save(history);
    }
    
    /**
     * Helper: Convert Product to InventoryResponse
     */
    private InventoryResponse convertToInventoryResponse(Product product) {
        InventoryResponse response = new InventoryResponse();
        response.setProductId(product.getId());
        response.setProductName(product.getTen());
        response.setProductCode(product.getMaSanPham());
        response.setImagePath(product.getAnhChinh());
        response.setCurrentStock(product.getSoLuongTon() != null ? product.getSoLuongTon() : 0);
        
        // Calculate total variants stock
        int totalVariantsStock = 0;
        int variantsCount = 0;
        if (product.getBienTheSanPhams() != null) {
            variantsCount = product.getBienTheSanPhams().size();
            totalVariantsStock = product.getBienTheSanPhams().stream()
                .mapToInt(v -> v.getSoLuong() != null ? v.getSoLuong() : 0)
                .sum();
        }
        response.setTotalVariantsStock(totalVariantsStock);
        response.setVariantsCount(variantsCount);
        
        // Set status
        response.setStatus(getStockStatus(product.getSoLuongTon()));
        
        // Set category and brand
        if (product.getDanhMuc() != null) {
            response.setCategory(product.getDanhMuc().getTen());
        }
        if (product.getThuongHieu() != null) {
            response.setBrand(product.getThuongHieu().getTen());
        }
        
        response.setActive(product.getHoatDong());
        
        return response;
    }
    
    /**
     * Helper: Xác định trạng thái tồn kho
     */
    private String getStockStatus(Integer stock) {
        if (stock == null || stock <= OUT_OF_STOCK_THRESHOLD) {
            return "OUT_OF_STOCK";
        } else if (stock <= LOW_STOCK_THRESHOLD) {
            return "LOW_STOCK";
        } else {
            return "IN_STOCK";
        }
    }
}

