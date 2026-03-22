package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import com.nakick.payment.enums.PaymentStatus;
import com.nakick.payment.model.PaymentTransaction;
import com.nakick.payment.repository.PaymentRepository;
import com.stripe.model.PaymentIntent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

@Service
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

    private final StripeService stripeService;
    private final PaymentRepository paymentRepository;
    private final DemoPaymentService demoPaymentService;

    public PaymentService(StripeService stripeService, PaymentRepository paymentRepository, DemoPaymentService demoPaymentService) {
        this.stripeService = stripeService;
        this.paymentRepository = paymentRepository;
        this.demoPaymentService = demoPaymentService;
    }

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

    public PaymentResponse initiatePayment(PaymentRequest request) {
        log.info("Initiating payment for order: {} using method: {}", request.getOrderId(), request.getPaymentMethod());
        
        PaymentResponse response;
        String finalPaymentMethod = request.getPaymentMethod() != null ? request.getPaymentMethod() : "STRIPE";
        
        try {
            if ("PAYPAL".equalsIgnoreCase(finalPaymentMethod)) {
                log.info("Processing PayPal payment in demo mode");
                // Mock PayPal response
                String paymentId = "PAYID-" + System.currentTimeMillis();
                response = PaymentResponse.builder()
                        .paymentId(paymentId)
                        .orderId(request.getOrderId())
                        .status("CREATED")
                        .amount(request.getAmount())
                        .currency(request.getCurrency())
                        .paymentMethod("PAYPAL")
                        .approvalUrl("https://www.paypal.com/checkoutnow?token=" + paymentId)
                        .build();
            } else if (stripeService.isDemoMode()) {
                log.info("Using demo payment mode for Stripe");
                response = demoPaymentService.createDemoPayment(request);
                response.setPaymentMethod("DEMO");
                finalPaymentMethod = "DEMO";
            } else {
                // Use real Stripe
                PaymentIntent intent = stripeService.createPaymentIntent(request);
                response = PaymentResponse.builder()
                        .paymentId(intent.getId())
                        .orderId(request.getOrderId())
                        .status(intent.getStatus())
                        .clientSecret(intent.getClientSecret())
                        .amount(request.getAmount())
                        .currency(request.getCurrency())
                        .paymentMethod("STRIPE")
                        .build();
            }
        } catch (Exception e) {
            log.error("Payment initiation failed with error: {}. Falling back to demo mode", e.getMessage(), e);
            response = demoPaymentService.createDemoPayment(request);
            response.setPaymentMethod("DEMO");
            finalPaymentMethod = "DEMO";
        }
        
        // Save to DB
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentId(response.getPaymentId());
        transaction.setOrderId(response.getOrderId());
        transaction.setStatus(PaymentStatus.fromString(response.getStatus()));
        transaction.setAmount(response.getAmount());
        transaction.setCurrency(response.getCurrency());
        transaction.setPaymentMethod(finalPaymentMethod);
        transaction.setClientSecret(response.getClientSecret());
        transaction.setUserEmail(request.getUserEmail());
        transaction.setProductName(buildProductSummary(request));
        
        transaction.setCreatedAt(LocalDateTime.now());
        transaction.setUpdatedAt(LocalDateTime.now());
        
        paymentRepository.save(transaction);
        
        return response;
    }

    public PaymentResponse completePayment(String paymentId) {
        log.info("Completing payment: {}", paymentId);
        
        // Find transaction
        PaymentTransaction transaction = paymentRepository.findByPaymentId(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        if ("PAYPAL".equalsIgnoreCase(transaction.getPaymentMethod())) {
            // Mock PayPal completion
            transaction.setStatus(PaymentStatus.fromString("COMPLETED"));
        } else if ("DEMO".equalsIgnoreCase(transaction.getPaymentMethod()) || paymentId.startsWith("pi_demo_")) {
            // Demo Stripe completion
            transaction.setStatus(PaymentStatus.fromString("succeeded"));
        } else {
            // Real Stripe completion/Capture/Confirm payment intent
            PaymentIntent intent = stripeService.capturePaymentIntent(paymentId);
            transaction.setStatus(PaymentStatus.fromString(intent.getStatus()));
        }
        
        transaction.setUpdatedAt(LocalDateTime.now());
        paymentRepository.save(transaction);
        
        return PaymentResponse.builder()
                .paymentId(transaction.getPaymentId())
                .orderId(transaction.getOrderId())
                .status(transaction.getStatus().getStatus())
                .amount(transaction.getAmount())
                .currency(transaction.getCurrency())
                .paymentMethod(transaction.getPaymentMethod())
                .build();
    }
    
    public PaymentResponse getPayment(String paymentId) {
        PaymentTransaction transaction = paymentRepository.findByPaymentId(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
                
        return PaymentResponse.builder()
                .paymentId(transaction.getPaymentId())
                .orderId(transaction.getOrderId())
                .status(transaction.getStatus().getStatus())
                .clientSecret(transaction.getClientSecret())
                .amount(transaction.getAmount())
                .currency(transaction.getCurrency())
                .paymentMethod(transaction.getPaymentMethod())
                .build();
    }
    
    public void updatePaymentStatus(String paymentId, String status) {
        log.info("Updating payment status: {} to {}", paymentId, status);
        
        PaymentTransaction transaction = paymentRepository.findByPaymentId(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        transaction.setStatus(PaymentStatus.fromString(status));
        transaction.setUpdatedAt(LocalDateTime.now());
        
        paymentRepository.save(transaction);
    }
}
