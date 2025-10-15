package com.example.demo.controller;

import com.example.demo.entity.*;
import com.example.demo.service.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/admin")
@Slf4j
public class AdminController {
    
    @Autowired
    private ProductService productService;
    
    @Autowired
    private DanhMucMonTheThaoService danhMucMonTheThaoService;
    
    @Autowired
    private BannerService bannerService;
    
    @Autowired
    private AnhSanPhamService anhSanPhamService;
    
    @Autowired
    private DanhMucService danhMucService;
    
    @Autowired
    private ThuongHieuService thuongHieuService;
    
    // ============= DASHBOARD =============
    @GetMapping
    public String dashboard(Model model) {
        // Thống kê tổng quan
        long totalProducts = productService.countAllProducts();
        long activeProducts = productService.countActiveProducts();
        long totalCategories = danhMucService.countActiveCategories();
        long totalBrands = thuongHieuService.countActiveBrands();
        
        model.addAttribute("totalProducts", totalProducts);
        model.addAttribute("activeProducts", activeProducts);
        model.addAttribute("totalCategories", totalCategories);
        model.addAttribute("totalBrands", totalBrands);
        
        return "admin/dashboard";
    }
    
    // ============= QUẢN LÝ SẢN PHẨM =============
    @GetMapping("/products")
    public String products(@RequestParam(defaultValue = "0") int page,
                          @RequestParam(defaultValue = "10") int size,
                          @RequestParam(defaultValue = "id") String sortBy,
                          @RequestParam(defaultValue = "desc") String sortDir,
                          @RequestParam(required = false) String keyword,
                          @RequestParam(required = false) Long categoryId,
                          @RequestParam(required = false) Long brandId,
                          @RequestParam(required = false) Long sportId,
                          Model model) {
        
        Sort sort = sortDir.equalsIgnoreCase("desc") ? 
            Sort.by(sortBy).descending() : Sort.by(sortBy).ascending();
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<Product> products;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            products = productService.searchProducts(keyword, pageable);
        } else if (categoryId != null || brandId != null || sportId != null) {
            products = productService.filterProducts(categoryId, brandId, sportId, pageable);
        } else {
            products = productService.getAllProducts(pageable);
        }
        
        List<DanhMuc> categories = danhMucService.getAllActiveCategories();
        List<ThuongHieu> brands = thuongHieuService.getAllActiveBrands();
        List<DanhMucMonTheThao> sports = danhMucMonTheThaoService.getAllActiveSports();
        
        model.addAttribute("products", products);
        model.addAttribute("categories", categories);
        model.addAttribute("brands", brands);
        model.addAttribute("sports", sports);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("keyword", keyword);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("brandId", brandId);
        model.addAttribute("sportId", sportId);
        
        return "admin/products/index";
    }
    
    @GetMapping("/products/create")
    public String createProductForm(Model model) {
        Product product = new Product();
        product.setGia(new BigDecimal("0"));
        product.setGiaGoc(new BigDecimal("0"));
        product.setSoLuongTon(0);
        product.setSlug(""); // Khởi tạo slug rỗng, sẽ được tạo khi submit
        
        List<DanhMuc> categories = danhMucService.getAllActiveCategories();
        List<ThuongHieu> brands = thuongHieuService.getAllActiveBrands();
        List<DanhMucMonTheThao> sports = danhMucMonTheThaoService.getAllActiveSports();
        
        model.addAttribute("product", product);
        model.addAttribute("categories", categories);
        model.addAttribute("brands", brands);
        model.addAttribute("sports", sports);
        
        return "admin/products/create";
    }
    
    @PostMapping("/products/create")
    public String createProduct(@ModelAttribute Product product,
                               @RequestParam(required = false) List<MultipartFile> images,
                               @RequestParam(required = false) List<String> sizes,
                               @RequestParam(required = false) List<String> colors) {
        
        // Tạo slug từ tên sản phẩm
        String slug = generateSlug(product.getTen());
        product.setSlug(slug);
        
        product.setNgayTao(LocalDateTime.now());
        product.setHoatDong(true);
        // noiBat sẽ được set từ form, không cần ghi đè
        
        Product savedProduct = productService.saveProduct(product);
        
        // Xử lý upload hình ảnh
        if (images != null && !images.isEmpty()) {
            anhSanPhamService.saveProductImages(savedProduct.getId(), images);
        }
        
        // Xử lý biến thể sản phẩm (size, màu)
        if (sizes != null && colors != null) {
            productService.saveProductVariants(savedProduct.getId(), sizes, colors);
        }
        
        return "redirect:/admin/products?success=created";
    }
    
    private String generateSlug(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "san-pham-" + System.currentTimeMillis();
        }
        
        // Chuyển thành chữ thường và thay thế ký tự đặc biệt
        String baseSlug = name.toLowerCase()
                .replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
                .replaceAll("[èéẹẻẽêềếệểễ]", "e")
                .replaceAll("[ìíịỉĩ]", "i")
                .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
                .replaceAll("[ùúụủũưừứựửữ]", "u")
                .replaceAll("[ỳýỵỷỹ]", "y")
                .replaceAll("[đ]", "d")
                .replaceAll("[^a-z0-9\\s-]", "") // Loại bỏ ký tự đặc biệt
                .replaceAll("\\s+", "-") // Thay thế khoảng trắng bằng dấu gạch ngang
                .replaceAll("-+", "-") // Loại bỏ dấu gạch ngang liên tiếp
                .replaceAll("^-|-$", ""); // Loại bỏ dấu gạch ngang ở đầu và cuối
        
        // Thêm timestamp nếu slug rỗng
        if (baseSlug.isEmpty()) {
            baseSlug = "san-pham-" + System.currentTimeMillis();
        }
        
        // Kiểm tra và tạo slug unique
        String slug = baseSlug;
        int counter = 1;
        
        while (productService.findBySlug(slug).isPresent()) {
            slug = baseSlug + "-" + counter;
            counter++;
        }
        
        return slug;
    }
    
    @GetMapping("/products/{id}/edit")
    public String editProductForm(@PathVariable Long id, Model model) {
        Optional<Product> productOpt = productService.findById(id);
        if (productOpt.isEmpty()) {
            return "redirect:/admin/products?error=notfound";
        }
        
        Product product = productOpt.get();
        List<DanhMuc> categories = danhMucService.getAllActiveCategories();
        List<ThuongHieu> brands = thuongHieuService.getAllActiveBrands();
        List<DanhMucMonTheThao> sports = danhMucMonTheThaoService.getAllActiveSports();
        List<AnhSanPham> images = anhSanPhamService.getProductImages(id);
        List<BienTheSanPham> variants = productService.getProductVariants(id);
        
        model.addAttribute("product", product);
        model.addAttribute("categories", categories);
        model.addAttribute("brands", brands);
        model.addAttribute("sports", sports);
        model.addAttribute("images", images);
        model.addAttribute("variants", variants);
        
        return "admin/products/edit-fixed";
    }
    
    @PostMapping("/products/{id}/edit")
    public String updateProduct(@PathVariable Long id,
                               @ModelAttribute Product product,
                               @RequestParam(required = false) List<MultipartFile> newImages,
                               @RequestParam(required = false) List<Long> deleteImageIds) {
        
        Optional<Product> existingProductOpt = productService.findById(id);
        if (existingProductOpt.isEmpty()) {
            return "redirect:/admin/products?error=notfound";
        }
        
        Product existingProduct = existingProductOpt.get();
        
        // Cập nhật thông tin cơ bản
        existingProduct.setTen(product.getTen());
        existingProduct.setMoTa(product.getMoTa());
        existingProduct.setGia(product.getGia());
        existingProduct.setGiaGoc(product.getGiaGoc());
        existingProduct.setSoLuongTon(product.getSoLuongTon());
        existingProduct.setChatLieu(product.getChatLieu());
        existingProduct.setXuatXu(product.getXuatXu());
        existingProduct.setNoiBat(product.getNoiBat());
        existingProduct.setDanhMuc(product.getDanhMuc());
        existingProduct.setThuongHieu(product.getThuongHieu());
        existingProduct.setMonTheThao(product.getMonTheThao());
        existingProduct.setNgayCapNhat(LocalDateTime.now());
        
        productService.saveProduct(existingProduct);
        
        // Xử lý xóa hình ảnh
        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            anhSanPhamService.deleteImages(deleteImageIds);
        }
        
        // Xử lý thêm hình ảnh mới
        if (newImages != null && !newImages.isEmpty()) {
            anhSanPhamService.saveProductImages(id, newImages);
        }
        
        return "redirect:/admin/products?success=updated";
    }
    
    @PostMapping("/products/{id}/delete")
    public String deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return "redirect:/admin/products?success=deleted";
    }
    
    @PostMapping("/products/{id}/toggle-status")
    public String toggleProductStatus(@PathVariable Long id) {
        productService.toggleProductStatus(id);
        return "redirect:/admin/products?success=status_updated";
    }
    
    // ============= QUẢN LÝ BIẾN THỂ SẢN PHẨM =============
    
    /**
     * Tạo biến thể mới cho sản phẩm
     */
    @PostMapping("/products/{id}/variants")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createProductVariants(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<String> sizes = (List<String>) request.get("sizes");
            @SuppressWarnings("unchecked")
            List<String> colors = (List<String>) request.get("colors");
            
            if (sizes == null || colors == null || sizes.isEmpty() || colors.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Vui lòng nhập ít nhất một kích thước và một màu sắc"
                ));
            }
            
            // Kiểm tra và tạo biến thể
            Map<String, Object> result = productService.saveProductVariantsWithValidation(id, sizes, colors);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("Error creating product variants", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi tạo biến thể: " + e.getMessage()
            ));
        }
    }
    
    /**
     * Xóa biến thể sản phẩm
     */
    @DeleteMapping("/products/variants/{variantId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteProductVariant(@PathVariable Long variantId) {
        try {
            productService.deleteProductVariant(variantId);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Xóa biến thể thành công"
            ));
        } catch (Exception e) {
            log.error("Error deleting product variant", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi xóa biến thể: " + e.getMessage()
            ));
        }
    }
    
    /**
     * Cập nhật biến thể sản phẩm
     */
    @PutMapping("/products/variants/{variantId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateProductVariant(
            @PathVariable Long variantId,
            @RequestBody Map<String, Object> request) {
        try {
            String size = (String) request.get("size");
            String color = (String) request.get("color");
            Integer stock = request.get("stock") != null ? 
                Integer.parseInt(request.get("stock").toString()) : null;
            
            if (size == null || color == null || size.trim().isEmpty() || color.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", "Kích thước và màu sắc không được để trống"
                ));
            }
            
            // Kiểm tra trùng lặp trước khi cập nhật
            Map<String, Object> validationResult = productService.validateVariantUpdate(variantId, size.trim(), color.trim());
            if (!(Boolean) validationResult.get("valid")) {
                return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", (String) validationResult.get("message")
                ));
            }
            
            productService.updateProductVariant(variantId, size.trim(), color.trim(), stock);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Cập nhật biến thể thành công"
            ));
        } catch (Exception e) {
            log.error("Error updating product variant", e);
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", "Có lỗi xảy ra khi cập nhật biến thể: " + e.getMessage()
            ));
        }
    }
    
    // ============= QUẢN LÝ DANH MỤC MÔN THỂ THAO =============
    @GetMapping("/sports")
    public String sports(Model model) {
        List<DanhMucMonTheThao> sports = danhMucMonTheThaoService.getAllSports();
        model.addAttribute("sports", sports);
        return "admin/sports/index";
    }
    
    @GetMapping("/sports/create")
    public String createSportForm(Model model) {
        model.addAttribute("sport", new DanhMucMonTheThao());
        return "admin/sports/create";
    }
    
    @PostMapping("/sports/create")
    public String createSport(@ModelAttribute DanhMucMonTheThao sport) {
        sport.setNgayTao(LocalDateTime.now());
        sport.setHoatDong(true);
        danhMucMonTheThaoService.saveSport(sport);
        return "redirect:/admin/sports?success=created";
    }
    
    @GetMapping("/sports/{id}/edit")
    public String editSportForm(@PathVariable Long id, Model model) {
        Optional<DanhMucMonTheThao> sportOpt = danhMucMonTheThaoService.getSportById(id);
        if (sportOpt.isEmpty()) {
            return "redirect:/admin/sports?error=notfound";
        }
        model.addAttribute("sport", sportOpt.get());
        return "admin/sports/edit";
    }
    
    @PostMapping("/sports/{id}/edit")
    public String updateSport(@PathVariable Long id, @ModelAttribute DanhMucMonTheThao sport) {
        Optional<DanhMucMonTheThao> existingSportOpt = danhMucMonTheThaoService.getSportById(id);
        if (existingSportOpt.isEmpty()) {
            return "redirect:/admin/sports?error=notfound";
        }
        
        DanhMucMonTheThao existingSport = existingSportOpt.get();
        existingSport.setTen(sport.getTen());
        existingSport.setMoTa(sport.getMoTa());
        existingSport.setHinhAnh(sport.getHinhAnh());
        existingSport.setThuTu(sport.getThuTu());
        existingSport.setHoatDong(sport.getHoatDong());
        existingSport.setNgayCapNhat(LocalDateTime.now());
        
        danhMucMonTheThaoService.saveSport(existingSport);
        return "redirect:/admin/sports?success=updated";
    }
    
    @PostMapping("/sports/{id}/delete")
    public String deleteSport(@PathVariable Long id) {
        danhMucMonTheThaoService.deleteSport(id);
        return "redirect:/admin/sports?success=deleted";
    }
    
    // ============= QUẢN LÝ BANNER =============
    @GetMapping("/banners")
    public String banners(Model model) {
        List<Banner> banners = bannerService.getAllBanners();
        model.addAttribute("banners", banners);
        return "admin/banners/index";
    }
    
    @GetMapping("/banners/create")
    public String createBannerForm(Model model) {
        model.addAttribute("banner", new Banner());
        return "admin/banners/create";
    }
    
    @PostMapping("/banners/create")
    public String createBanner(@ModelAttribute Banner banner) {
        banner.setNgayTao(LocalDateTime.now());
        banner.setHoatDong(true);
        bannerService.saveBanner(banner);
        return "redirect:/admin/banners?success=created";
    }
    
    @GetMapping("/banners/{id}/edit")
    public String editBannerForm(@PathVariable Long id, Model model) {
        Optional<Banner> bannerOpt = bannerService.getBannerById(id);
        if (bannerOpt.isEmpty()) {
            return "redirect:/admin/banners?error=notfound";
        }
        model.addAttribute("banner", bannerOpt.get());
        return "admin/banners/edit";
    }
    
    @PostMapping("/banners/{id}/edit")
    public String updateBanner(@PathVariable Long id, @ModelAttribute Banner banner) {
        Optional<Banner> existingBannerOpt = bannerService.getBannerById(id);
        if (existingBannerOpt.isEmpty()) {
            return "redirect:/admin/banners?error=notfound";
        }
        
        Banner existingBanner = existingBannerOpt.get();
        existingBanner.setTen(banner.getTen());
        existingBanner.setHinhAnh(banner.getHinhAnh());
        existingBanner.setMoTa(banner.getMoTa());
        existingBanner.setLink(banner.getLink());
        existingBanner.setViTri(banner.getViTri());
        existingBanner.setThuTu(banner.getThuTu());
        existingBanner.setHoatDong(banner.getHoatDong());
        existingBanner.setNgayCapNhat(LocalDateTime.now());
        
        bannerService.saveBanner(existingBanner);
        return "redirect:/admin/banners?success=updated";
    }
    
    @PostMapping("/banners/{id}/delete")
    public String deleteBanner(@PathVariable Long id) {
        bannerService.deleteBanner(id);
        return "redirect:/admin/banners?success=deleted";
    }
    
    // ============= API ENDPOINTS =============
    @GetMapping("/api/products/search")
    @ResponseBody
    public ResponseEntity<Page<Product>> searchProducts(@RequestParam String keyword,
                                                       @RequestParam(defaultValue = "0") int page,
                                                       @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Product> products = productService.searchProducts(keyword, pageable);
        return ResponseEntity.ok(products);
    }
    
    @GetMapping("/api/products/{id}/images")
    @ResponseBody
    public ResponseEntity<List<AnhSanPham>> getProductImages(@PathVariable Long id) {
        List<AnhSanPham> images = anhSanPhamService.getProductImages(id);
        return ResponseEntity.ok(images);
    }
    
    @PostMapping("/api/products/{id}/images")
    @ResponseBody
    public ResponseEntity<String> uploadProductImages(@PathVariable Long id,
                                                     @RequestParam List<MultipartFile> images) {
        try {
            anhSanPhamService.saveProductImages(id, images);
            return ResponseEntity.ok("Images uploaded successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error uploading images: " + e.getMessage());
        }
    }
    
    @DeleteMapping("/api/products/images/{imageId}")
    @ResponseBody
    public ResponseEntity<String> deleteProductImage(@PathVariable Long imageId) {
        try {
            anhSanPhamService.deleteImage(imageId);
            return ResponseEntity.ok("Image deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error deleting image: " + e.getMessage());
        }
    }
}
