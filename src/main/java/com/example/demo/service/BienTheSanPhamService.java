package com.example.demo.service;

import com.example.demo.entity.BienTheSanPham;
import com.example.demo.entity.Product;
import com.example.demo.repository.BienTheSanPhamRepository;
import com.example.demo.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class BienTheSanPhamService {
    
    @Autowired
    private BienTheSanPhamRepository bienTheSanPhamRepository;
    
    @Autowired
    private ProductRepository productRepository;
    
    public List<BienTheSanPham> getBySanPhamId(Long sanPhamId) {
        return bienTheSanPhamRepository.findBySanPhamId(sanPhamId);
    }
    
    public Optional<BienTheSanPham> findById(Long id) {
        return bienTheSanPhamRepository.findById(id);
    }
    
    public BienTheSanPham save(BienTheSanPham bienThe) {
        return bienTheSanPhamRepository.save(bienThe);
    }
    
    public void deleteById(Long id) {
        bienTheSanPhamRepository.deleteById(id);
    }
    
    public void deleteBySanPhamId(Long sanPhamId) {
        bienTheSanPhamRepository.deleteBySanPhamId(sanPhamId);
    }
    
    public BienTheSanPham createVariant(Long sanPhamId, String kichCo, String mauSac, Integer soLuong, BigDecimal giaBan) {
        Optional<Product> productOpt = productRepository.findById(sanPhamId);
        if (productOpt.isEmpty()) {
            throw new RuntimeException("Product not found with id: " + sanPhamId);
        }
        
        Product product = productOpt.get();
        
        // Tạo mã SKU
        String maSku = generateSKU(product.getMaSanPham(), kichCo, mauSac);
        
        BienTheSanPham variant = new BienTheSanPham();
        variant.setMaSku(maSku);
        variant.setKichCo(kichCo);
        variant.setMauSac(mauSac);
        variant.setSoLuong(soLuong != null ? soLuong : 0);
        variant.setSoLuongTon(soLuong != null ? soLuong : 0);
        variant.setGiaBan(giaBan);
        variant.setTrangThai(true);
        variant.setHienThi(true);
        variant.setNgayTao(LocalDateTime.now());
        variant.setSanPham(product);
        
        return bienTheSanPhamRepository.save(variant);
    }
    
    public BienTheSanPham updateVariant(Long variantId, String kichCo, String mauSac, Integer soLuong, BigDecimal giaBan) {
        Optional<BienTheSanPham> variantOpt = bienTheSanPhamRepository.findById(variantId);
        if (variantOpt.isEmpty()) {
            throw new RuntimeException("Variant not found with id: " + variantId);
        }
        
        BienTheSanPham variant = variantOpt.get();
        
        // Cập nhật thông tin
        variant.setKichCo(kichCo);
        variant.setMauSac(mauSac);
        if (soLuong != null) {
            variant.setSoLuong(soLuong);
            variant.setSoLuongTon(soLuong);
        }
        if (giaBan != null) {
            variant.setGiaBan(giaBan);
        }
        variant.setNgayCapNhat(LocalDateTime.now());
        
        return bienTheSanPhamRepository.save(variant);
    }
    
    private String generateSKU(String productCode, String size, String color) {
        String sizeCode = size != null ? size.toUpperCase().replaceAll("[^A-Z0-9]", "") : "XX";
        String colorCode = color != null ? color.substring(0, Math.min(3, color.length())).toUpperCase() : "XXX";
        return productCode + "-" + sizeCode + "-" + colorCode;
    }
    
    public boolean variantExists(Long sanPhamId, String kichCo, String mauSac) {
        List<BienTheSanPham> variants = bienTheSanPhamRepository.findBySanPhamId(sanPhamId);
        return variants.stream().anyMatch(v -> 
            v.getKichCo().equals(kichCo) && v.getMauSac().equals(mauSac));
    }
    
    public List<BienTheSanPham> createVariantsFromSizesAndColors(Long sanPhamId, List<String> sizes, List<String> colors, Integer defaultStock, BigDecimal defaultPrice) {
        List<BienTheSanPham> createdVariants = new java.util.ArrayList<>();
        
        for (String size : sizes) {
            for (String color : colors) {
                if (!size.trim().isEmpty() && !color.trim().isEmpty()) {
                    if (!variantExists(sanPhamId, size.trim(), color.trim())) {
                        BienTheSanPham variant = createVariant(
                            sanPhamId, 
                            size.trim(), 
                            color.trim(), 
                            defaultStock, 
                            defaultPrice
                        );
                        createdVariants.add(variant);
                    }
                }
            }
        }
        
        return createdVariants;
    }
}

