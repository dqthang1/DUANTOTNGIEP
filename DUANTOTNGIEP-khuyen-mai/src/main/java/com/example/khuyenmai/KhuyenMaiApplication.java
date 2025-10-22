package com.example.khuyenmai;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KhuyenMaiApplication {
    public static void main(String[] args) {
        SpringApplication.run(KhuyenMaiApplication.class, args);
        System.out.println("✅ Ứng dụng khuyến mãi đã khởi động tại http://localhost:8080/khuyenmai");
        System.out.println("✅ Ứng dụng khuyến mãi đã khởi động tại http://localhost:8080/sanpham");
    }
}
