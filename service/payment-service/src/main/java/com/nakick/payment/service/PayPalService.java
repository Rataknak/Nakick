package com.nakick.payment.service;

import com.nakick.payment.dto.PaymentRequest;
import com.paypal.core.PayPalHttpClient;
import com.paypal.http.HttpResponse;
import com.paypal.orders.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class PayPalService {

    private final PayPalHttpClient payPalHttpClient;

    public Order createOrder(PaymentRequest paymentRequest) {
        OrderRequest orderRequest = new OrderRequest();
        orderRequest.checkoutPaymentIntent("CAPTURE");

        // Ultra-simple application context
        ApplicationContext applicationContext = new ApplicationContext()
                .brandName("NAKick")
                .landingPage("LOGIN")
                .shippingPreference("NO_SHIPPING")
                .userAction("PAY_NOW")
                .returnUrl("https://example.com/return") 
                .cancelUrl("https://example.com/cancel");
        orderRequest.applicationContext(applicationContext);

        // Strict 2-decimal formatting
        String formattedTotal = String.format("%.2f", paymentRequest.getAmount());

        List<PurchaseUnitRequest> purchaseUnitRequests = new ArrayList<>();
        PurchaseUnitRequest purchaseUnitRequest = new PurchaseUnitRequest()
                .description(paymentRequest.getDescription())
                .amountWithBreakdown(new AmountWithBreakdown()
                        .currencyCode("USD")
                        .value(formattedTotal));
        
        purchaseUnitRequests.add(purchaseUnitRequest);
        orderRequest.purchaseUnits(purchaseUnitRequests);

        OrdersCreateRequest request = new OrdersCreateRequest().requestBody(orderRequest);

        try {
            HttpResponse<Order> response = payPalHttpClient.execute(request);
            return response.result();
        } catch (IOException e) {
            log.error("PayPal Create Order Failed", e);
            throw new RuntimeException("PayPal Error: " + e.getMessage());
        }
    }

    public Order captureOrder(String orderId) {
        OrdersCaptureRequest request = new OrdersCaptureRequest(orderId);
        request.requestBody(new OrderRequest());
        try {
            HttpResponse<Order> response = payPalHttpClient.execute(request);
            return response.result();
        } catch (IOException e) {
            log.error("PayPal Capture Failed", e);
            throw new RuntimeException("Capture Failed: " + e.getMessage());
        }
    }

    public Order getOrder(String orderId) {
        OrdersGetRequest request = new OrdersGetRequest(orderId);
        try {
            HttpResponse<Order> response = payPalHttpClient.execute(request);
            return response.result();
        } catch (IOException e) {
            throw new RuntimeException("Get Order Failed");
        }
    }
}
