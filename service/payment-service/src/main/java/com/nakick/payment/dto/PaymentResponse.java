package com.nakick.payment.dto;

import java.math.BigDecimal;

public class PaymentResponse {

    private String paymentId; // Stripe PaymentIntent ID
    private String orderId;   // NAKick Order ID
    private String status;
    private String approvalUrl;
    private String clientSecret; // For Stripe
    private BigDecimal amount;
    private String currency;
    private String paymentMethod;

    // Getters and setters
    public String getPaymentId() { return paymentId; }
    public void setPaymentId(String paymentId) { this.paymentId = paymentId; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getApprovalUrl() { return approvalUrl; }
    public void setApprovalUrl(String approvalUrl) { this.approvalUrl = approvalUrl; }

    public String getClientSecret() { return clientSecret; }
    public void setClientSecret(String clientSecret) { this.clientSecret = clientSecret; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    // Builder pattern
    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private PaymentResponse response = new PaymentResponse();

        public Builder paymentId(String paymentId) {
            response.setPaymentId(paymentId);
            return this;
        }

        public Builder orderId(String orderId) {
            response.setOrderId(orderId);
            return this;
        }

        public Builder status(String status) {
            response.setStatus(status);
            return this;
        }

        public Builder approvalUrl(String approvalUrl) {
            response.setApprovalUrl(approvalUrl);
            return this;
        }

        public Builder clientSecret(String clientSecret) {
            response.setClientSecret(clientSecret);
            return this;
        }

        public Builder amount(BigDecimal amount) {
            response.setAmount(amount);
            return this;
        }

        public Builder currency(String currency) {
            response.setCurrency(currency);
            return this;
        }

        public Builder paymentMethod(String paymentMethod) {
            response.setPaymentMethod(paymentMethod);
            return this;
        }

        public PaymentResponse build() {
            return response;
        }
    }
}
