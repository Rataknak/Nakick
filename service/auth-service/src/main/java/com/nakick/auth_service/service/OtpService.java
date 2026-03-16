package com.nakick.auth_service.service;

import com.nakick.auth_service.dto.OtpResponse;
import com.nakick.auth_service.repository.UserRepository;
import com.nakick.auth_service.util.JwtUtil;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class OtpService {

    private static final Logger log = LoggerFactory.getLogger(OtpService.class);

    private final EmailService emailService;
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    @Value("${otp.expiration:300000}")
    private Long otpExpiration; // 5 minutes default

    public OtpResponse generateAndSendOtp(String email) {
        // Check if email is already registered
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email is already registered. Please login or reset your password.");
        }

        // Generate 6-digit OTP
        String otp = String.format("%06d", new Random().nextInt(999999));
        
        log.info("Generated OTP for email: {}", email);

        // Send OTP via email
        emailService.sendOtpEmail(email, otp);

        // Create temporary token containing email and OTP (for verification step)
        String tempToken = jwtUtil.generateOtpToken(email, otp, otpExpiration);

        return OtpResponse.builder()
                .success(true)
                .message("OTP sent successfully to your email")
                .token(tempToken)
                .build();
    }

    public OtpResponse verifyOtp(String tempToken, String otp) {
        try {
            // Extract claims from temporary token
            Claims claims = jwtUtil.extractAllClaims(tempToken);
            
            String email = claims.getSubject();
            String storedOtp = claims.get("otp", String.class);

            // Verify OTP matches
            if (!storedOtp.equals(otp)) {
                throw new RuntimeException("Invalid OTP. Please try again.");
            }

            log.info("OTP verified successfully for email: {}", email);

            // Create verified email token (for registration step)
            String verifiedEmailToken = jwtUtil.generateVerifiedEmailToken(email);

            return OtpResponse.builder()
                    .success(true)
                    .message("Email verified successfully")
                    .token(verifiedEmailToken)
                    .build();
        } catch (Exception e) {
            log.error("OTP verification failed", e);
            throw new RuntimeException("OTP verification failed: " + e.getMessage());
        }
    }
}
