package com.example.demo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "otp_verification")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OtpVerification {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "email", nullable = false, length = 255)
    private String email;
    
    @Column(name = "otp_hash", nullable = false, length = 255)
    private String otpHash;
    
    @Column(name = "otp_salt", nullable = false, length = 255)
    private String otpSalt;
    
    @Column(name = "type", nullable = false, length = 50)
    private String type; // REGISTRATION, PASSWORD_RESET, etc.
    
    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;
    
    @Column(name = "is_used", nullable = false)
    private Boolean isUsed = false;
    
    @Column(name = "attempts", nullable = false)
    private Integer attempts = 0;
    
    @Column(name = "max_attempts", nullable = false)
    private Integer maxAttempts = 3;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "used_at")
    private LocalDateTime usedAt;
    
    // Constructor for creating new OTP
    public OtpVerification(String email, String otpHash, String otpSalt, String type) {
        this.email = email;
        this.otpHash = otpHash;
        this.otpSalt = otpSalt;
        this.type = type;
        this.expiresAt = LocalDateTime.now().plusMinutes(10); // OTP expires in 10 minutes
        this.isUsed = false;
        this.attempts = 0;
        this.maxAttempts = 3;
        this.createdAt = LocalDateTime.now();
    }
    
    // Check if OTP is expired
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
    
    // Check if OTP can be used
    public boolean canBeUsed() {
        return !isUsed && !isExpired() && attempts < maxAttempts;
    }
    
    // Mark OTP as used
    public void markAsUsed() {
        this.isUsed = true;
        this.usedAt = LocalDateTime.now();
    }
    
    // Increment attempt count
    public void incrementAttempts() {
        this.attempts++;
    }
    
    // Check if max attempts reached
    public boolean isMaxAttemptsReached() {
        return attempts >= maxAttempts;
    }
    
    // Get remaining time in minutes
    public long getRemainingTimeInMinutes() {
        if (isExpired()) {
            return 0;
        }
        return java.time.Duration.between(LocalDateTime.now(), expiresAt).toMinutes();
    }
    
    // Get remaining attempts
    public int getRemainingAttempts() {
        return Math.max(0, maxAttempts - attempts);
    }
}
