package com.example.demo.service;

import com.example.demo.entity.OtpVerification;
import com.example.demo.entity.User;
import com.example.demo.repository.OtpVerificationRepository;
import com.example.demo.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {
    
    private final OtpVerificationRepository otpRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;
    
    // Generate 6-digit OTP
    private String generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
    
    // Send OTP for registration
    public boolean sendRegistrationOtp(String email) {
        try {
            // Check if user already exists and is verified
            Optional<User> existingUser = userRepository.findByEmail(email);
            if (existingUser.isPresent() && existingUser.get().getEmailVerified()) {
                log.warn("Email {} is already registered and verified", email);
                return false;
            }
            
            // Rate limiting: Check if too many OTPs sent recently (max 3 in 1 hour)
            LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);
            Long recentCount = otpRepository.countRecentOtpsByEmail(email, oneHourAgo);
            if (recentCount >= 3) {
                log.warn("Too many OTP requests for email {} in the last hour", email);
                return false;
            }
            
            // Generate new OTP
            String otpCode = generateOtp();
            
            // Invalidate any existing active OTP for this email and type
            Optional<OtpVerification> existingOtp = otpRepository.findActiveOtpByEmailAndType(email, "REGISTRATION", LocalDateTime.now());
            if (existingOtp.isPresent()) {
                existingOtp.get().setIsUsed(true);
                otpRepository.save(existingOtp.get());
            }
            
            // Create new OTP
            OtpVerification otp = new OtpVerification(email, otpCode, "REGISTRATION");
            otpRepository.save(otp);
            
            // Send email
            sendOtpEmail(email, otpCode, "Xác nhận đăng ký tài khoản");
            
            log.info("Registration OTP sent to {}", email);
            return true;
            
        } catch (Exception e) {
            log.error("Error sending registration OTP to {}", email, e);
            return false;
        }
    }
    
    // Verify OTP for registration
    public boolean verifyRegistrationOtp(String email, String otpCode) {
        try {
            Optional<OtpVerification> otpOpt = otpRepository.findActiveOtpByEmailAndType(email, "REGISTRATION", LocalDateTime.now());
            
            if (otpOpt.isEmpty()) {
                log.warn("No active OTP found for email {}", email);
                return false;
            }
            
            OtpVerification otp = otpOpt.get();
            
            // Increment attempts
            otp.incrementAttempts();
            otpRepository.save(otp);
            
            // Check if max attempts reached
            if (otp.isMaxAttemptsReached()) {
                log.warn("Max attempts reached for OTP verification for email {}", email);
                return false;
            }
            
            // Check if OTP matches
            if (!otpCode.equals(otp.getOtpCode())) {
                log.warn("Invalid OTP code for email {}", email);
                return false;
            }
            
            // Mark OTP as used
            otp.markAsUsed();
            otpRepository.save(otp);
            
            // Verify user email and activate account
            Optional<User> userOpt = userRepository.findByEmail(email);
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                user.setEmailVerified(true);
                user.setHoatDong(true); // Kích hoạt tài khoản
                userRepository.save(user);
                log.info("Email verified and account activated successfully for user {}", email);
            }
            
            return true;
            
        } catch (Exception e) {
            log.error("Error verifying registration OTP for {}", email, e);
            return false;
        }
    }
    
    // Send OTP email
    private void sendOtpEmail(String email, String otpCode, String subject) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setTo(email);
            helper.setSubject(subject + " - Activewear Store");
            
            // Create Thymeleaf context
            Context context = new Context();
            context.setVariable("otpCode", otpCode);
            context.setVariable("email", email);
            
            // Process HTML template
            String htmlContent = templateEngine.process("email/otp-verification", context);
            helper.setText(htmlContent, true);
            
            mailSender.send(message);
            log.info("OTP email sent successfully to {}", email);
            
        } catch (MessagingException e) {
            log.error("Error sending OTP email to {}", email, e);
            throw new RuntimeException("Failed to send OTP email", e);
        }
    }
    
    
    // Clean up expired OTPs
    public void cleanupExpiredOtps() {
        try {
            otpRepository.deleteExpiredOtps(LocalDateTime.now());
            log.info("Expired OTPs cleaned up successfully");
        } catch (Exception e) {
            log.error("Error cleaning up expired OTPs", e);
        }
    }
    
    // Clean up old used OTPs
    public void cleanupOldUsedOtps() {
        try {
            LocalDateTime cutoffDate = LocalDateTime.now().minusDays(7);
            otpRepository.deleteOldUsedOtps(cutoffDate);
            log.info("Old used OTPs cleaned up successfully");
        } catch (Exception e) {
            log.error("Error cleaning up old used OTPs", e);
        }
    }
    
    // Resend OTP (with rate limiting)
    public boolean resendOtp(String email) {
        try {
            // Check rate limiting
            LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);
            Long recentCount = otpRepository.countRecentOtpsByEmail(email, oneHourAgo);
            if (recentCount >= 3) {
                log.warn("Too many OTP requests for email {} in the last hour", email);
                return false;
            }
            
            return sendRegistrationOtp(email);
            
        } catch (Exception e) {
            log.error("Error resending OTP to {}", email, e);
            return false;
        }
    }
}
