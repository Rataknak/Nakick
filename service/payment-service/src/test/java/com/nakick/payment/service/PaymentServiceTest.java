package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import com.nakick.payment.model.PaymentTransaction;
import com.nakick.payment.repository.PaymentRepository;
import com.paypal.orders.LinkDescription;
import com.paypal.orders.Order;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock
    private PayPalService payPalService;

    @Mock
    private PaymentRepository paymentRepository;

    @InjectMocks
    private PaymentService paymentService;

    private PaymentRequest paymentRequest;
    private Order mockOrder;

    @BeforeEach
    void setUp() {
        paymentRequest = new PaymentRequest();
        paymentRequest.setOrderId("ORDER-123");
        paymentRequest.setAmount(new BigDecimal("100.00"));
        paymentRequest.setCurrency("USD");
        paymentRequest.setDescription("Test Payment");

        mockOrder = new Order();
        mockOrder.id("PAY-123");
        mockOrder.status("CREATED");
        
        LinkDescription link = new LinkDescription();
        link.rel("approve");
        link.href("https://paypal.com/approve");
        mockOrder.links(Collections.singletonList(link));
    }

    @Test
    void testInitiatePayment() {
        when(payPalService.createOrder(any(PaymentRequest.class))).thenReturn(mockOrder);
        when(paymentRepository.save(any(PaymentTransaction.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PaymentResponse response = paymentService.initiatePayment(paymentRequest);

        assertNotNull(response);
        assertEquals("PAY-123", response.getPaymentId());
        assertEquals("ORDER-123", response.getOrderId());
        assertEquals("https://paypal.com/approve", response.getApprovalUrl());
        
        verify(payPalService, times(1)).createOrder(any(PaymentRequest.class));
        verify(paymentRepository, times(1)).save(any(PaymentTransaction.class));
    }

    @Test
    void testCompletePayment() {
        String paymentId = "PAY-123";
        String payerId = "PAYER-123";
        
        PaymentTransaction existingTransaction = new PaymentTransaction();
        existingTransaction.setPaymentId(paymentId);
        existingTransaction.setOrderId("ORDER-123");
        existingTransaction.setAmount(new BigDecimal("100.00"));
        existingTransaction.setCurrency("USD");
        existingTransaction.setStatus("CREATED");

        Order capturedOrder = new Order();
        capturedOrder.status("COMPLETED");

        when(paymentRepository.findByPaymentId(paymentId)).thenReturn(Optional.of(existingTransaction));
        when(payPalService.captureOrder(paymentId)).thenReturn(capturedOrder);
        when(paymentRepository.save(any(PaymentTransaction.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PaymentResponse response = paymentService.completePayment(paymentId, payerId);

        assertNotNull(response);
        assertEquals("COMPLETED", response.getStatus());
        
        verify(paymentRepository, times(1)).findByPaymentId(paymentId);
        verify(payPalService, times(1)).captureOrder(paymentId);
        verify(paymentRepository, times(1)).save(existingTransaction);
    }
}
