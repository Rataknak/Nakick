package com.nakick.payment.model;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Document(collection = "payments")
public class PaymentTransaction {

    @Id
    private String id;
    
    private String paymentId; // PayPal Order ID
    private String orderId;   // NAKick Order ID
    private String payerId;
    private String status;
    private BigDecimal amount;
    private String currency;
    private String paymentMethod;
    private String approvalUrl;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
