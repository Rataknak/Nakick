package com.nakick.payment.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class PaymentRequest {

    @NotBlank(message = "Order ID is required")
    private String orderId;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;

    @NotBlank(message = "Currency is required")
    private String currency = "USD";

    private String description;

    // Optional: Only used if you want to pass item details to PayPal
    @Valid
    private List<CartItem> items;

    @Data
    public static class CartItem {
        private String name;
        private Integer quantity;
        private BigDecimal unitPrice;
        private String sku;
    }
}
