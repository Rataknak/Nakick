package com.nakick.payment.controller;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import com.nakick.payment.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
@Slf4j
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/initiate")
    public ResponseEntity<PaymentResponse> initiatePayment(@Valid @RequestBody PaymentRequest request) {
        try {
            PaymentResponse response = paymentService.initiatePayment(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error initiating payment", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/complete")
    public ResponseEntity<PaymentResponse> completePayment(@RequestParam String paymentId, @RequestParam String payerId) {
        try {
            PaymentResponse response = paymentService.completePayment(paymentId, payerId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error completing payment", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{paymentId}")
    public ResponseEntity<PaymentResponse> getPayment(@PathVariable String paymentId) {
        try {
            PaymentResponse response = paymentService.getPayment(paymentId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/success")
    public ResponseEntity<Map<String, String>> success(@RequestParam String token, @RequestParam String PayerID) {
        // token is the paymentId (Order ID)
        try {
            paymentService.completePayment(token, PayerID);
            return ResponseEntity.ok(Map.of("status", "success", "message", "Payment completed successfully"));
        } catch (Exception e) {
            log.error("Payment success callback failed", e);
            return ResponseEntity.badRequest().body(Map.of("status", "error", "message", "Payment failed"));
        }
    }

    @GetMapping("/cancel")
    public ResponseEntity<Map<String, String>> cancel() {
        return ResponseEntity.ok(Map.of("status", "cancelled", "message", "Payment cancelled by user"));
    }
}
