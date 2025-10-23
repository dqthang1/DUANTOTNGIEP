package com.example.demo.service;

import com.example.demo.entity.AnhSanPham;
import com.example.demo.entity.Product;
import com.example.demo.repository.AnhSanPhamRepository;
import com.example.demo.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class AnhSanPhamService {
    
    @Autowired
    private AnhSanPhamRepository anhSanPhamRepository;
    
    @Autowired
    private ProductRepository productRepository;
    
    @Value("${app.upload.path:/uploads}")
    private String uploadPath;
    
    public List<AnhSanPham> getProductImages(Long productId) {
        return anhSanPhamRepository.findBySanPhamIdOrderByThuTuAsc(productId);
    }
    
    public AnhSanPham saveImage(AnhSanPham anhSanPham) {
        return anhSanPhamRepository.save(anhSanPham);
    }
    
    public void deleteImage(Long imageId) {
        anhSanPhamRepository.deleteById(imageId);
    }
    
    public void deleteImages(List<Long> imageIds) {
        anhSanPhamRepository.deleteAllById(imageIds);
    }
    
    public void deleteBySanPhamId(Long productId) {
        anhSanPhamRepository.deleteBySanPhamId(productId);
    }
    
    public List<AnhSanPham> saveProductImages(Long productId, List<MultipartFile> images) {
        List<AnhSanPham> savedImages = new ArrayList<>();
        
        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isEmpty()) {
            throw new RuntimeException("Product not found with id: " + productId);
        }
        
        Product product = productOpt.get();
        
        // Tạo thư mục upload nếu chưa tồn tại
        Path uploadDir = Paths.get(uploadPath);
        if (!Files.exists(uploadDir)) {
            try {
                Files.createDirectories(uploadDir);
            } catch (IOException e) {
                throw new RuntimeException("Could not create upload directory", e);
            }
        }
        
        for (int i = 0; i < images.size(); i++) {
            MultipartFile image = images.get(i);
            if (!image.isEmpty()) {
                String originalFilename = image.getOriginalFilename();
                try {
                    // Tạo tên file unique
                    String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
                    String fileName = UUID.randomUUID().toString() + fileExtension;
                    
                    // Lưu file
                    Path filePath = uploadDir.resolve(fileName);
                    Files.copy(image.getInputStream(), filePath);
                    
                    // Tạo entity và lưu vào database
                    AnhSanPham anhSanPham = new AnhSanPham();
                    anhSanPham.setUrlAnh("/uploads/" + fileName);
                    anhSanPham.setThuTu(i + 1);
                    anhSanPham.setNgayThem(LocalDateTime.now());
                    anhSanPham.setSanPham(product);
                    
                    AnhSanPham savedImage = anhSanPhamRepository.save(anhSanPham);
                    savedImages.add(savedImage);
                    
                } catch (IOException e) {
                    throw new RuntimeException("Could not save image: " + originalFilename, e);
                }
            }
        }
        
        return savedImages;
    }
    
    public Long countProductImages(Long productId) {
        return anhSanPhamRepository.countBySanPhamId(productId);
    }
}
