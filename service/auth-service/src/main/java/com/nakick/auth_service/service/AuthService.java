package com.nakick.auth_service.service;

import com.nakick.auth_service.dto.AuthResponse;
import com.nakick.auth_service.dto.ChangePasswordRequest;
import com.nakick.auth_service.dto.LoginRequest;
import com.nakick.auth_service.dto.ProfileUpdateRequest;
import com.nakick.auth_service.dto.RegisterRequest;
import com.nakick.auth_service.entity.Role;
import com.nakick.auth_service.entity.User;
import com.nakick.auth_service.repository.UserRepository;
import com.nakick.auth_service.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        // Extract and verify email from verified token
        String email = extractAndVerifyEmail(request.getVerifiedEmailToken());
        
        // If email provided in request, ensure it matches token
        if (request.getEmail() != null && !request.getEmail().equalsIgnoreCase(email)) {
            throw new RuntimeException("Email mismatch between token and registration request");
        }
        
        // Handle optional username - generate from email if not provided
        String username = request.getUsername();
        if (username == null || username.trim().isEmpty()) {
            // Generate username from email (part before @)
            username = email.substring(0, email.indexOf("@")).toLowerCase();
            // Ensure username meets size requirements
            if (username.length() < 3) {
                username = username + "123";
            }
            if (username.length() > 50) {
                username = username.substring(0, 47) + "123";
            }
        }
        
        // Check if username already exists
        if (userRepository.existsByUsername(username)) {
            throw new RuntimeException("Username is already taken");
        }

        // Check if email already exists
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email is already in use");
        }

        // Create new user with verified email
        User user = User.builder()
                .username(username)
                .email(email)
                .password(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .role(Role.USER)
                .enabled(true)
                .emailVerified(true) // Mark as verified
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        userRepository.save(user);

        // Generate JWT token
        String token = jwtUtil.generateToken(user);

        return AuthResponse.builder()
                .token(token)
                .username(user.getUsername())
                .email(user.getEmail())
                .message("User registered successfully")
                .build();
    }

    private String extractAndVerifyEmail(String verifiedEmailToken) {
        try {
            var claims = jwtUtil.extractAllClaims(verifiedEmailToken);
            String email = claims.getSubject();
            Boolean emailVerified = claims.get("emailVerified", Boolean.class);

            if (emailVerified == null || !emailVerified) {
                throw new RuntimeException("Email not verified. Please verify your email first.");
            }

            return email;
        } catch (Exception e) {
            throw new RuntimeException("Invalid or expired verification token: " + e.getMessage());
        }
    }

    public AuthResponse login(LoginRequest request) {
        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        // Get user details
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Check if email is verified
        if (!user.getEmailVerified()) {
            throw new RuntimeException("Email not verified. Please verify your email to login.");
        }

        // Generate JWT token
        String token = jwtUtil.generateToken(userDetails);

        return AuthResponse.builder()
                .token(token)
                .username(user.getUsername())
                .email(user.getEmail())
                .message("Login successful")
                .build();
    }

    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    public String extractEmailFromToken(String token) {
        return jwtUtil.extractUsername(token); // Since we use email as username in JWT
    }

    public AuthResponse updateProfile(String email, ProfileUpdateRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Update username if provided and different
        if (request.getUsername() != null && !request.getUsername().equals(user.getUsername())) {
            if (userRepository.existsByUsername(request.getUsername())) {
                throw new RuntimeException("Username is already taken");
            }
            user.setUsername(request.getUsername());
        }

        // Update email if provided and different
        if (request.getEmail() != null && !request.getEmail().equals(user.getEmail())) {
            if (userRepository.existsByEmail(request.getEmail())) {
                throw new RuntimeException("Email is already in use");
            }
            user.setEmail(request.getEmail());
            // Note: In production, you'd want to re-verify the new email
        }

        // Update other fields
        if (request.getFirstName() != null) {
            user.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            user.setLastName(request.getLastName());
        }

        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        // Generate new token with updated info
        String token = jwtUtil.generateToken(user);

        return AuthResponse.builder()
                .token(token)
                .username(user.getUsername())
                .email(user.getEmail())
                .message("Profile updated successfully")
                .build();
    }

    public void changePassword(String email, ChangePasswordRequest request) {
        // Validate new passwords match
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new RuntimeException("New passwords do not match");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }

        // Update password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
    }

    public boolean validateToken(String token) {
        try {
            String identifier = jwtUtil.extractUsername(token);
            UserDetails userDetails = userRepository.findByEmail(identifier)
                    .orElseGet(() -> userRepository.findByUsername(identifier)
                            .orElseThrow(() -> new RuntimeException("User not found")));
            return jwtUtil.validateToken(token, userDetails);
        } catch (Exception e) {
            return false;
        }
    }
}
