package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
public class DemoPaymentService {

    private static final Logger log = LoggerFactory.getLogger(DemoPaymentService.class);
    
    @Value("${stripe.api-key}")
    private String stripeApiKey;
    
    private boolean isDemoMode() {
        return stripeApiKey == null || stripeApiKey.contains("placeholder");
    }
    
    public PaymentResponse createDemoPayment(PaymentRequest request) {
        log.info("Creating demo payment for order: {}", request.getOrderId());
        
        // Generate mock payment details
        String paymentId = "pi_demo_" + System.currentTimeMillis();
        String clientSecret = paymentId + "_secret_" + System.currentTimeMillis();
        
        return PaymentResponse.builder()
                .paymentId(paymentId)
                .orderId(request.getOrderId())
                .status("requires_payment_method")
                .clientSecret(clientSecret)
                .amount(request.getAmount())
                .currency(request.getCurrency())
                .build();
    }
    
    public PaymentResponse completeDemoPayment(String paymentId) {
        log.info("Completing demo payment: {}", paymentId);
        
        return PaymentResponse.builder()
                .paymentId(paymentId)
                .orderId("DEMO-ORDER")
                .status("succeeded")
                .amount(new BigDecimal("29.99"))
                .currency("USD")
                .build();
    }
}
