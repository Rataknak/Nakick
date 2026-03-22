package com.nakick.payment.enums;

public enum PaymentStatus {
    CREATED("created"),
    PENDING("pending"),
    PROCESSING("processing"), 
    COMPLETED("completed"),
    SUCCEEDED("succeeded"),
    FAILED("failed"),
    CANCELLED("cancelled"),
    REFUNDED("refunded"),
    REQUIRES_PAYMENT_METHOD("requires_payment_method"),
    REQUIRES_ACTION("requires_action"),
    REQUIRES_CAPTURE("requires_capture");

    private final String status;

    PaymentStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }

    public static PaymentStatus fromString(String status) {
        if (status == null) return PENDING;
        
        for (PaymentStatus paymentStatus : PaymentStatus.values()) {
            if (paymentStatus.status.equalsIgnoreCase(status) || paymentStatus.name().equalsIgnoreCase(status)) {
                return paymentStatus;
            }
        }
        
        // Map some common Stripe statuses to internal ones if not explicitly matched
        if (status.equalsIgnoreCase("succeeded")) return COMPLETED;
        if (status.equalsIgnoreCase("payment_intent.succeeded")) return COMPLETED;
        if (status.equalsIgnoreCase("payment_intent.payment_failed")) return FAILED;
        
        return PENDING; // Default to pending instead of throwing exception
    }
}
