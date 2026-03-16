package com.nakick.cart_service.repository;

import com.nakick.cart_service.entity.Cart;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CartRepository extends MongoRepository<Cart, String> {
    Optional<Cart> findByUserIdAndStatus(String userId, Cart.CartStatus status);
    Optional<Cart> findByUserEmailAndStatus(String userEmail, Cart.CartStatus status);
    void deleteByUserIdAndStatus(String userId, Cart.CartStatus status);
}
