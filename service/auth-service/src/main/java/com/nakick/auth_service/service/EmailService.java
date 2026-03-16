package com.nakick.auth_service.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;

    public void sendOtpEmail(String toEmail, String otp) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("NAKick - Email Verification OTP");
            message.setText(buildOtpEmailBody(otp));
            
            mailSender.send(message);
            log.info("OTP email sent successfully to: {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send OTP email to: {}", toEmail, e);
            throw new RuntimeException("Failed to send verification email. Please try again later.");
        }
    }

    private String buildOtpEmailBody(String otp) {
        return String.format("""
                Hello,
                
                Your verification code for NAKick is: %s
                
                This code is valid for 5 minutes.
                
                If you did not request this code, please ignore this email.
                
                Best regards,
                NAKick Team
                """, otp);
    }

    public void sendWelcomeEmail(String toEmail, String username) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("Welcome to NAKick!");
            message.setText(buildWelcomeEmailBody(username));
            
            mailSender.send(message);
            log.info("Welcome email sent successfully to: {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", toEmail, e);
            // Don't throw exception for welcome email failure
        }
    }

    private String buildWelcomeEmailBody(String username) {
        return String.format("""
                Hello %s,
                
                Welcome to NAKick! Your account has been successfully created.
                
                You can now log in and start exploring our services.
                
                Best regards,
                NAKick Team
                """, username);
    }
}
