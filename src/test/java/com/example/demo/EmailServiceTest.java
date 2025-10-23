package com.example.demo;

import com.example.demo.service.EmailService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class EmailServiceTest {

    @Autowired
    private EmailService emailService;

    @Test
    public void testSendSimpleEmail() {
        try {
            emailService.sendSimpleEmail(
                "test@example.com", 
                "Test Email", 
                "This is a test email from Activewear Store"
            );
            System.out.println("Test email sent successfully!");
        } catch (Exception e) {
            System.err.println("Failed to send test email: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
