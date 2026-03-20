package com.nakick.payment.repository;

import com.nakick.payment.model.PaymentTransaction;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentRepository extends MongoRepository<PaymentTransaction, String> {

    Optional<PaymentTransaction> findByPaymentId(String paymentId);

    Optional<PaymentTransaction> findByOrderId(String orderId);
}
