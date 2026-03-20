package com.nakick.payment.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class PaymentResponse {

    private String paymentId; // PayPal Order ID
    private String orderId;   // NAKick Order ID
    private String status;
    private String approvalUrl;
    private BigDecimal amount;
    private String currency;
}
