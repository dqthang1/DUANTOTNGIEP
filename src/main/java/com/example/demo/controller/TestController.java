package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class TestController {
    
    @GetMapping("/test-cart")
    public String testCart() {
        return "test-cart";
    }
    
    @GetMapping("/test-inventory-update")
    public String testInventoryUpdate() {
        return "test-inventory-update";
    }
}

