package com.example.demo.service;

import com.example.demo.entity.Product;
import com.example.demo.entity.User;
import com.example.demo.entity.YeuThich;
import com.example.demo.repository.YeuThichRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class YeuThichService {
    
    @Autowired
    private YeuThichRepository yeuThichRepository;
    
    public List<YeuThich> getWishlistByUserId(Long userId) {
        return yeuThichRepository.findByNguoiDungIdOrderByNgayThemDesc(userId);
    }
    
    public boolean addToWishlist(Long userId, Long productId) {
        // Kiểm tra xem đã yêu thích chưa
        if (yeuThichRepository.existsByNguoiDungIdAndSanPhamId(userId, productId)) {
            return false; // Đã yêu thích rồi
        }
        
        // Tạo mới yêu thích
        YeuThich yeuThich = new YeuThich();
        User user = new User();
        user.setId(userId);
        Product product = new Product();
        product.setId(productId);
        
        yeuThich.setNguoiDung(user);
        yeuThich.setSanPham(product);
        
        yeuThichRepository.save(yeuThich);
        return true;
    }
    
    public boolean removeFromWishlist(Long userId, Long productId) {
        if (!yeuThichRepository.existsByNguoiDungIdAndSanPhamId(userId, productId)) {
            return false; // Chưa yêu thích
        }
        
        yeuThichRepository.deleteByNguoiDungIdAndSanPhamId(userId, productId);
        return true;
    }
    
    public boolean isInWishlist(Long userId, Long productId) {
        return yeuThichRepository.existsByNguoiDungIdAndSanPhamId(userId, productId);
    }
    
    public Long getWishlistCount(Long userId) {
        return (long) yeuThichRepository.findByNguoiDungIdOrderByNgayThemDesc(userId).size();
    }
    
    public Long getProductLikesCount(Long productId) {
        return yeuThichRepository.countBySanPhamId(productId);
    }
    
    public List<Long> getLikedProductIds(Long userId) {
        return yeuThichRepository.findSanPhamIdsByNguoiDungId(userId);
    }
}
