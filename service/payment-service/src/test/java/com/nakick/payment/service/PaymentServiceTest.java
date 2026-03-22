package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import com.nakick.payment.enums.PaymentStatus;
import com.nakick.payment.model.PaymentTransaction;
import com.nakick.payment.repository.PaymentRepository;
import com.nakick.payment.service.DemoPaymentService;
import com.stripe.model.PaymentIntent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock
    private StripeService stripeService;

    @Mock
    private PaymentRepository paymentRepository;
    
    @Mock
    private DemoPaymentService demoPaymentService;

    private PaymentService paymentService;

    private PaymentRequest paymentRequest;
    private PaymentIntent mockIntent;

    @BeforeEach
    void setUp() {
        paymentService = new PaymentService(stripeService, paymentRepository, demoPaymentService);
        paymentRequest = new PaymentRequest();
        paymentRequest.setOrderId("ORDER-123");
        paymentRequest.setAmount(new BigDecimal("100.00"));
        paymentRequest.setCurrency("USD");
        paymentRequest.setDescription("Test Payment");

        mockIntent = mock(PaymentIntent.class);
        when(mockIntent.getId()).thenReturn("pi_123");
        when(mockIntent.getStatus()).thenReturn("requires_payment_method");
        when(mockIntent.getClientSecret()).thenReturn("secret_123");
    }

    @Test
    void testInitiatePayment() {
        when(stripeService.createPaymentIntent(any(PaymentRequest.class))).thenReturn(mockIntent);
        when(paymentRepository.save(any(PaymentTransaction.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PaymentResponse response = paymentService.initiatePayment(paymentRequest);

        assertNotNull(response);
        assertEquals("pi_123", response.getPaymentId());
        assertEquals("ORDER-123", response.getOrderId());
        assertEquals("secret_123", response.getClientSecret());
        
        verify(stripeService, times(1)).createPaymentIntent(any(PaymentRequest.class));
        verify(paymentRepository, times(1)).save(any(PaymentTransaction.class));
    }

    @Test
    void testCompletePayment() {
        String paymentId = "pi_123";
        String payerId = "PAYER-123";
        
        PaymentTransaction existingTransaction = new PaymentTransaction();
        existingTransaction.setPaymentId(paymentId);
        existingTransaction.setOrderId("ORDER-123");
        existingTransaction.setAmount(new BigDecimal("100.00"));
        existingTransaction.setCurrency("USD");
        existingTransaction.setStatus(PaymentStatus.PENDING);

        PaymentIntent confirmedIntent = mock(PaymentIntent.class);
        when(confirmedIntent.getStatus()).thenReturn("succeeded");

        when(paymentRepository.findByPaymentId(paymentId)).thenReturn(Optional.of(existingTransaction));
        when(stripeService.capturePaymentIntent(paymentId)).thenReturn(confirmedIntent);
        when(paymentRepository.save(any(PaymentTransaction.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PaymentResponse response = paymentService.completePayment(paymentId);

        assertNotNull(response);
        assertEquals("succeeded", response.getStatus());
        
        verify(paymentRepository, times(1)).findByPaymentId(paymentId);
        verify(stripeService, times(1)).capturePaymentIntent(paymentId);
        verify(paymentRepository, times(1)).save(existingTransaction);
    }
}
