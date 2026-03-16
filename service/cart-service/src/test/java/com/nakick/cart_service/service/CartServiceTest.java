package com.nakick.cart_service.service;

import com.nakick.cart_service.dto.CartItemRequest;
import com.nakick.cart_service.dto.CartResponse;
import com.nakick.cart_service.dto.SkuResponse;
import com.nakick.cart_service.entity.Cart;
import com.nakick.cart_service.repository.CartRepository;
import com.nakick.cart_service.client.ShoesServiceClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class CartServiceTest {

    @Mock
    private CartRepository cartRepository;
    
    @Mock
    private ShoesServiceClient shoesServiceClient;

    @InjectMocks
    private CartService cartService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetOrCreateCart_NewCart() {
        String userId = "user123";
        String userEmail = "user@example.com";
        
        when(cartRepository.findByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE)).thenReturn(Optional.empty());
        when(cartRepository.save(any(Cart.class))).thenAnswer(i -> i.getArguments()[0]);

        CartResponse response = cartService.getOrCreateCart(userId, userEmail);

        assertNotNull(response);
        assertEquals(userId, response.getUserId());
        assertEquals(userEmail, response.getUserEmail());
        assertTrue(response.getItems().isEmpty());
        verify(cartRepository, times(1)).save(any(Cart.class));
    }

    @Test
    void testAddItemToCart_NewItem() {
        String userId = "user123";
        String userEmail = "user@example.com";
        Cart cart = new Cart(userId, userEmail);
        
        when(cartRepository.findByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE)).thenReturn(Optional.of(cart));
        when(cartRepository.save(any(Cart.class))).thenAnswer(i -> i.getArguments()[0]);

        CartItemRequest request = new CartItemRequest("sku1", 2);
        
        SkuResponse mockSku = new SkuResponse(
            "sku1", "product1", "Nike", "Air Max", "M", "Black", 
            new BigDecimal("100.00"), 10, "http://image.url", "SKU001", 
            null, null, true, true
        );
        
        when(shoesServiceClient.getSkuById("sku1")).thenReturn(mockSku);

        CartResponse response = cartService.addItemToCart(userId, userEmail, request);

        assertEquals(1, response.getItems().size());
        assertEquals(2, response.getTotalItems());
        assertEquals(new BigDecimal("200.00"), response.getTotalAmount());
        verify(cartRepository, times(1)).save(any(Cart.class));
    }

    @Test
    void testAddItemToCart_ExistingItem() {
        String userId = "user123";
        String userEmail = "user@example.com";
        Cart cart = new Cart(userId, userEmail);
        
        CartItemRequest request = new CartItemRequest("sku1", 2);
        
        SkuResponse mockSku = new SkuResponse(
            "sku1", "product1", "Nike", "Air Max", "M", "Black", 
            new BigDecimal("100.00"), 10, "http://image.url", "SKU001", 
            null, null, true, true
        );
        
        when(shoesServiceClient.getSkuById("sku1")).thenReturn(mockSku);
        
        // Add it once
        when(cartRepository.findByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE)).thenReturn(Optional.of(cart));
        when(cartRepository.save(any(Cart.class))).thenAnswer(i -> i.getArguments()[0]);
        cartService.addItemToCart(userId, userEmail, request);
        
        // Add it again with quantity 3
        request = new CartItemRequest("sku1", 3);
        CartResponse response = cartService.addItemToCart(userId, userEmail, request);

        assertEquals(1, response.getItems().size());
        assertEquals(5, response.getTotalItems());
        assertEquals(new BigDecimal("500.00"), response.getTotalAmount());
    }
}
