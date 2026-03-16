package com.nakick.cart_service.service;

import com.nakick.cart_service.dto.CartItemRequest;
import com.nakick.cart_service.dto.CartItemResponse;
import com.nakick.cart_service.dto.CartResponse;
import com.nakick.cart_service.dto.SkuResponse;
import com.nakick.cart_service.dto.ShoeResponse;
import com.nakick.cart_service.entity.Cart;
import com.nakick.cart_service.entity.CartItem;
import com.nakick.cart_service.repository.CartRepository;
import com.nakick.cart_service.client.ShoesServiceClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
public class CartService {
    
    private final CartRepository cartRepository;
    private final ShoesServiceClient shoesServiceClient;
    
    public CartService(CartRepository cartRepository, ShoesServiceClient shoesServiceClient) {
        this.cartRepository = cartRepository;
        this.shoesServiceClient = shoesServiceClient;
    }
    
    public CartResponse getOrCreateCart(String userId, String userEmail) {
        Optional<Cart> existingCart = cartRepository.findByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE);
        
        if (existingCart.isPresent()) {
            return convertToResponse(existingCart.get());
        }
        
        Cart newCart = new Cart(userId, userEmail);
        Cart savedCart = cartRepository.save(newCart);
        return convertToResponse(savedCart);
    }
    
    public CartResponse addItemToCart(String userId, String userEmail, CartItemRequest itemRequest) {
        Cart cart = getOrCreateActiveCart(userId, userEmail);
        
        // Fetch SKU details from shoes service
        SkuResponse sku = shoesServiceClient.getSkuById(itemRequest.getSkuId());
        if (sku == null || !sku.getIsActive()) {
            throw new RuntimeException("SKU not found or not available: " + itemRequest.getSkuId());
        }
        
        // Fetch Shoe details to get brand and model
        ShoeResponse shoe = shoesServiceClient.getShoeById(sku.getProductId());
        if (shoe == null || !shoe.getIsActive()) {
            throw new RuntimeException("Shoe not found or not available: " + sku.getProductId());
        }
        
        Optional<CartItem> existingItem = cart.getItems().stream()
                .filter(item -> item.getSkuId().equals(itemRequest.getSkuId()))
                .findFirst();
        
        if (existingItem.isPresent()) {
            CartItem item = existingItem.get();
            item.setQuantity(item.getQuantity() + itemRequest.getQuantity());
        } else {
            CartItem newItem = new CartItem(
                    sku.getId(),
                    sku.getProductId(),
                    shoe.getBrand(),
                    shoe.getModel(),
                    sku.getColor(),
                    sku.getSize(),
                    sku.getPrice(),
                    itemRequest.getQuantity(),
                    sku.getImageUrl() != null ? sku.getImageUrl() : shoe.getImageUrl()
            );
            newItem.setId(UUID.randomUUID().toString());
            
            if (cart.getItems() == null) {
                cart.setItems(new ArrayList<>());
            }
            cart.getItems().add(newItem);
        }
        
        cart.calculateTotals();
        Cart savedCart = cartRepository.save(cart);
        return convertToResponse(savedCart);
    }
    
    public CartResponse updateCartItem(String userId, String userEmail, String itemId, Integer quantity) {
        Cart cart = getActiveCart(userId, userEmail);
        
        CartItem item = cart.getItems().stream()
                .filter(i -> i.getId().equals(itemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        
        if (quantity <= 0) {
            cart.getItems().remove(item);
        } else {
            item.setQuantity(quantity);
        }
        
        cart.calculateTotals();
        Cart savedCart = cartRepository.save(cart);
        return convertToResponse(savedCart);
    }
    
    public CartResponse removeItemFromCart(String userId, String userEmail, String itemId) {
        Cart cart = getActiveCart(userId, userEmail);
        
        boolean removed = cart.getItems().removeIf(item -> item.getId().equals(itemId));
        
        if (!removed) {
            throw new RuntimeException("Cart item not found");
        }
        
        cart.calculateTotals();
        Cart savedCart = cartRepository.save(cart);
        return convertToResponse(savedCart);
    }
    
    public CartResponse clearCart(String userId, String userEmail) {
        Cart cart = getActiveCart(userId, userEmail);
        cart.getItems().clear();
        cart.calculateTotals();
        Cart savedCart = cartRepository.save(cart);
        return convertToResponse(savedCart);
    }
    
    public void deleteCart(String userId, String userEmail) {
        cartRepository.deleteByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE);
    }
    
    private Cart getOrCreateActiveCart(String userId, String userEmail) {
        Optional<Cart> existingCart = cartRepository.findByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE);
        return existingCart.orElseGet(() -> new Cart(userId, userEmail));
    }
    
    private Cart getActiveCart(String userId, String userEmail) {
        return cartRepository.findByUserIdAndStatus(userId, Cart.CartStatus.ACTIVE)
                .orElseThrow(() -> new RuntimeException("Active cart not found"));
    }
    
    private CartResponse convertToResponse(Cart cart) {
        List<CartItemResponse> itemResponses = cart.getItems().stream()
                .map(this::convertItemToResponse)
                .collect(Collectors.toList());
        
        CartResponse response = new CartResponse();
        response.setId(cart.getId());
        response.setUserId(cart.getUserId());
        response.setUserEmail(cart.getUserEmail());
        response.setItems(itemResponses);
        response.setTotalAmount(cart.getTotalAmount());
        response.setTotalItems(cart.getTotalItems());
        response.setCreatedAt(cart.getCreatedAt());
        response.setUpdatedAt(cart.getUpdatedAt());
        response.setStatus(cart.getStatus().toString());
        
        return response;
    }
    
    private CartItemResponse convertItemToResponse(CartItem item) {
        CartItemResponse response = new CartItemResponse();
        response.setId(item.getId());
        response.setSkuId(item.getSkuId());
        response.setBrand(item.getBrand());
        response.setModel(item.getModel());
        response.setSize(item.getSize());
        response.setColor(item.getColor());
        response.setPrice(item.getPrice());
        response.setQuantity(item.getQuantity());
        response.setImageUrl(item.getImageUrl());
        response.setAddedAt(item.getAddedAt());
        
        return response;
    }
}
