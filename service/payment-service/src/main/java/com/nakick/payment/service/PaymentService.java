package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import com.nakick.payment.model.PaymentTransaction;
import com.nakick.payment.repository.PaymentRepository;
import com.paypal.orders.Order;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PayPalService payPalService;
    private final PaymentRepository paymentRepository;

    public PaymentResponse initiatePayment(PaymentRequest request) {
        log.info("Initiating payment for order: {}", request.getOrderId());
        
        // Call PayPal
        Order order = payPalService.createOrder(request);
        
        // Save to DB
        PaymentTransaction transaction = new PaymentTransaction();
        transaction.setPaymentId(order.id());
        transaction.setOrderId(request.getOrderId());
        transaction.setStatus("CREATED");
        transaction.setAmount(request.getAmount());
        transaction.setCurrency(request.getCurrency());
        transaction.setPaymentMethod("PAYPAL");
        
        // Extract approval URL
        order.links().stream()
                .filter(link -> "approve".equals(link.rel()))
                .findFirst()
                .ifPresent(link -> transaction.setApprovalUrl(link.href()));
        
        transaction.setCreatedAt(LocalDateTime.now());
        transaction.setUpdatedAt(LocalDateTime.now());
        
        paymentRepository.save(transaction);
        
        return PaymentResponse.builder()
                .paymentId(transaction.getPaymentId())
                .orderId(transaction.getOrderId())
                .status(transaction.getStatus())
                .approvalUrl(transaction.getApprovalUrl())
                .amount(transaction.getAmount())
                .currency(transaction.getCurrency())
                .build();
    }

    public PaymentResponse completePayment(String paymentId, String payerId) {
        log.info("Completing payment: {}", paymentId);
        
        // Find transaction
        PaymentTransaction transaction = paymentRepository.findByPaymentId(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
        
        // Capture payment via PayPal
        Order capturedOrder = payPalService.captureOrder(paymentId);
        
        // Update transaction
        transaction.setStatus(capturedOrder.status());
        transaction.setPayerId(payerId);
        transaction.setUpdatedAt(LocalDateTime.now());
        
        paymentRepository.save(transaction);
        
        return PaymentResponse.builder()
                .paymentId(transaction.getPaymentId())
                .orderId(transaction.getOrderId())
                .status(transaction.getStatus())
                .approvalUrl(null) // Payment completed, no approval needed
                .amount(transaction.getAmount())
                .currency(transaction.getCurrency())
                .build();
    }
    
    public PaymentResponse getPayment(String paymentId) {
        PaymentTransaction transaction = paymentRepository.findByPaymentId(paymentId)
                .orElseThrow(() -> new RuntimeException("Payment not found"));
                
        return PaymentResponse.builder()
                .paymentId(transaction.getPaymentId())
                .orderId(transaction.getOrderId())
                .status(transaction.getStatus())
                .approvalUrl(transaction.getApprovalUrl())
                .amount(transaction.getAmount())
                .currency(transaction.getCurrency())
                .build();
    }
}
