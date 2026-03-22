package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentConfirmParams;
import com.stripe.param.PaymentIntentCreateParams;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class StripeService {

    private static final Logger log = LoggerFactory.getLogger(StripeService.class);
    
    @Value("${stripe.api-key}")
    private String stripeApiKey;

    @Value("${app.server-url}")
    private String appServerUrl;
    
    private String buildProductSummary(PaymentRequest request) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            return request.getDescription() != null ? request.getDescription() : "NAKick Order";
        }
        String items = request.getItems().stream()
                .map(item -> item.getName())
                .limit(3)
                .collect(Collectors.joining(", "));
        return items + (request.getItems().size() > 3 ? "..." : "");
    }

    public boolean isDemoMode() {
        return stripeApiKey == null || stripeApiKey.contains("placeholder");
    }

    public PaymentIntent createPaymentIntent(PaymentRequest request) {
        if (isDemoMode()) {
            return createMockPaymentIntent(request);
        }
        
        long amountInCents = request.getAmount().multiply(new java.math.BigDecimal(100)).longValue();
        
        PaymentIntentCreateParams.Builder paramsBuilder = PaymentIntentCreateParams.builder()
                .setAmount(amountInCents)
                .setCurrency(request.getCurrency().toLowerCase())
                .setDescription(buildProductSummary(request))
                .putMetadata("orderId", request.getOrderId())
                .setAutomaticPaymentMethods(
                        PaymentIntentCreateParams.AutomaticPaymentMethods.builder()
                                .setEnabled(true)
                                .build()
                );

        if (request.getUserEmail() != null && !request.getUserEmail().isEmpty()) {
            paramsBuilder.setReceiptEmail(request.getUserEmail());
            paramsBuilder.putMetadata("userEmail", request.getUserEmail());
        }

        if (request.getPaymentMethodId() != null && !request.getPaymentMethodId().isEmpty()) {
            paramsBuilder.setPaymentMethod(request.getPaymentMethodId());
        }

        PaymentIntentCreateParams params = paramsBuilder.build();

        try {
            return PaymentIntent.create(params);
        } catch (StripeException e) {
            log.error("Stripe Create PaymentIntent Failed", e);
            throw new RuntimeException("Stripe Error: " + e.getMessage());
        }
    }

    private PaymentIntent createMockPaymentIntent(PaymentRequest request) {
        log.info("Creating mock payment intent for demo mode");
        
        // Create a mock PaymentIntent
        PaymentIntent mockIntent = new PaymentIntent();
        
        // Set basic properties using reflection or create a mock object
        try {
            // Use a simple mock implementation
            Map<String, String> metadata = new HashMap<>();
            metadata.put("orderId", request.getOrderId());
            
            // Create a mock payment intent with required fields
            mockIntent.setId("pi_demo_" + System.currentTimeMillis());
            mockIntent.setStatus("requires_payment_method");
            mockIntent.setClientSecret(mockIntent.getId() + "_secret_" + System.currentTimeMillis());
            mockIntent.setAmount(request.getAmount().multiply(new java.math.BigDecimal(100)).longValue());
            mockIntent.setCurrency(request.getCurrency().toLowerCase());
            mockIntent.setDescription(request.getDescription());
            mockIntent.setMetadata(metadata);
            
            return mockIntent;
        } catch (Exception e) {
            log.error("Failed to create mock payment intent", e);
            throw new RuntimeException("Mock payment creation failed");
        }
    }

    public PaymentIntent capturePaymentIntent(String paymentIntentId) {
        if (isDemoMode() || paymentIntentId.startsWith("pi_demo_") || paymentIntentId.startsWith("pi_mock_")) {
            return captureMockPaymentIntent(paymentIntentId);
        }
        
        try {
            PaymentIntent intent = PaymentIntent.retrieve(paymentIntentId);
            
            PaymentIntentConfirmParams params = PaymentIntentConfirmParams.builder()
                    .setReturnUrl(appServerUrl + "/api/payments/success?payment_intent=" + paymentIntentId)
                    .build();
                    
            return intent.confirm(params);
        } catch (StripeException e) {
            log.error("Stripe Capture/Confirm Failed", e);
            throw new RuntimeException("Capture Failed: " + e.getMessage());
        }
    }

    private PaymentIntent captureMockPaymentIntent(String paymentIntentId) {
        log.info("Capturing mock payment intent: {}", paymentIntentId);
        
        PaymentIntent mockIntent = new PaymentIntent();
        mockIntent.setId(paymentIntentId);
        mockIntent.setStatus("succeeded");
        mockIntent.setAmount(2999L); // $29.99 in cents
        mockIntent.setCurrency("usd");
        mockIntent.setDescription("Mock payment completed");
        
        return mockIntent;
    }

    public PaymentIntent getPaymentIntent(String paymentIntentId) {
        try {
            return PaymentIntent.retrieve(paymentIntentId);
        } catch (StripeException e) {
            log.error("Stripe Retrieve Failed", e);
            throw new RuntimeException("Get Payment Failed: " + e.getMessage());
        }
    }
}
