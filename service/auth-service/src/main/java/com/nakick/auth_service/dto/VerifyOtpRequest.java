package com.nakick.auth_service.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VerifyOtpRequest {
    
    @NotBlank(message = "Temporary token is required")
    private String tempToken;
    
    @NotBlank(message = "OTP is required")
    private String otp;
}
