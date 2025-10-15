package com.example.demo.repository;

import com.example.demo.entity.OtpVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OtpVerificationRepository extends JpaRepository<OtpVerification, Long> {
    
    // Find active OTP by email and type (SQL Server compatible)
    @Query("SELECT o FROM OtpVerification o WHERE o.email = :email AND o.type = :type AND o.isUsed = false AND o.expiresAt > :now AND o.attempts < o.maxAttempts ORDER BY o.createdAt DESC")
    Optional<OtpVerification> findActiveOtpByEmailAndType(@Param("email") String email, @Param("type") String type, @Param("now") LocalDateTime now);
    
    // Find latest OTP by email and type (regardless of status)
    @Query("SELECT o FROM OtpVerification o WHERE o.email = :email AND o.type = :type ORDER BY o.createdAt DESC")
    Optional<OtpVerification> findLatestOtpByEmailAndType(@Param("email") String email, @Param("type") String type);
    
    // Find all OTPs by email and type
    List<OtpVerification> findByEmailAndTypeOrderByCreatedAtDesc(String email, String type);
    
    // Delete expired OTPs (SQL Server compatible)
    @Modifying
    @Query("DELETE FROM OtpVerification o WHERE o.expiresAt < :now")
    void deleteExpiredOtps(@Param("now") LocalDateTime now);
    
    // Delete used OTPs older than specified days
    @Modifying
    @Query("DELETE FROM OtpVerification o WHERE o.isUsed = true AND o.usedAt < :cutoffDate")
    void deleteOldUsedOtps(@Param("cutoffDate") LocalDateTime cutoffDate);
    
    // Count recent OTP attempts for rate limiting
    @Query("SELECT COUNT(o) FROM OtpVerification o WHERE o.email = :email AND o.createdAt > :since")
    Long countRecentOtpsByEmail(@Param("email") String email, @Param("since") LocalDateTime since);
    
    // Find active OTPs for cleanup (unused but not expired)
    @Query("SELECT o FROM OtpVerification o WHERE o.isUsed = false AND o.createdAt < :cutoffDate")
    List<OtpVerification> findUnusedOtpsOlderThan(@Param("cutoffDate") LocalDateTime cutoffDate);
    
    // Count total OTPs by email and type
    @Query("SELECT COUNT(o) FROM OtpVerification o WHERE o.email = :email AND o.type = :type")
    Long countByEmailAndType(@Param("email") String email, @Param("type") String type);
}
