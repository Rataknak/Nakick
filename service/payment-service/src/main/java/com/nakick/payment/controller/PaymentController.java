package com.nakick.payment.controller;

import com.nakick.payment.dto.PaymentRequest;
import com.nakick.payment.dto.PaymentResponse;
import com.nakick.payment.service.PaymentService;
import com.stripe.model.Event;
import com.stripe.model.PaymentIntent;
import com.stripe.net.Webhook;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

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
    public ResponseEntity<PaymentResponse> completePayment(@RequestParam String paymentId) {
        try {
            PaymentResponse response = paymentService.completePayment(paymentId);
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
    public ResponseEntity<Map<String, String>> success(@RequestParam String payment_intent) {
        // payment_intent is the Stripe PaymentIntent ID
        try {
            paymentService.completePayment(payment_intent);
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

    @PostMapping("/webhook")
    public ResponseEntity<String> handleStripeWebhook(@RequestBody String payload, @RequestHeader("Stripe-Signature") String sigHeader) {
        try {
            Event event = Webhook.constructEvent(payload, sigHeader, stripeWebhookSecret);
            
            switch (event.getType()) {
                case "payment_intent.succeeded":
                    PaymentIntent paymentIntent = (PaymentIntent) event.getDataObjectDeserializer().getObject().orElse(null);
                    if (paymentIntent != null) {
                        log.info("Payment succeeded: {}", paymentIntent.getId());
                        // Update payment status in database
                        paymentService.updatePaymentStatus(paymentIntent.getId(), "succeeded");
                    }
                    break;
                case "payment_intent.payment_failed":
                    PaymentIntent failedPaymentIntent = (PaymentIntent) event.getDataObjectDeserializer().getObject().orElse(null);
                    if (failedPaymentIntent != null) {
                        log.info("Payment failed: {}", failedPaymentIntent.getId());
                        paymentService.updatePaymentStatus(failedPaymentIntent.getId(), "failed");
                    }
                    break;
                default:
                    log.warn("Unhandled event type: {}", event.getType());
            }
            
            return ResponseEntity.ok("Webhook processed");
        } catch (Exception e) {
            log.error("Webhook processing failed", e);
            return ResponseEntity.badRequest().body("Webhook signature verification failed");
        }
    }

    @Value("${stripe.webhook-secret}")
    private String stripeWebhookSecret;
}
