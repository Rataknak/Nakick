package com.nakick.cart_service.controller;

import com.nakick.cart_service.dto.CartItemRequest;
import com.nakick.cart_service.dto.CartResponse;
import com.nakick.cart_service.security.UserPrincipal;
import com.nakick.cart_service.service.CartService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cart")
public class CartController {
    
    private final CartService cartService;
    
    public CartController(CartService cartService) {
        this.cartService = cartService;
    }
    
    @GetMapping("/health")
    public String health() {
        return "Cart Service is running";
    }
    
    @GetMapping
    public ResponseEntity<CartResponse> getCart(Authentication authentication) {
        UserPrincipal user = (UserPrincipal) authentication.getPrincipal();
        CartResponse cart = cartService.getOrCreateCart(user.getUserId(), user.getUserEmail());
        return ResponseEntity.ok(cart);
    }
    
    @PostMapping("/items")
    public ResponseEntity<CartResponse> addItem(Authentication authentication,
                                               @Valid @RequestBody CartItemRequest itemRequest) {
        UserPrincipal user = (UserPrincipal) authentication.getPrincipal();
        CartResponse cart = cartService.addItemToCart(user.getUserId(), user.getUserEmail(), itemRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(cart);
    }
    
    @PutMapping("/items/{itemId}")
    public ResponseEntity<CartResponse> updateItem(Authentication authentication,
                                                  @PathVariable String itemId,
                                                  @RequestParam Integer quantity) {
        UserPrincipal user = (UserPrincipal) authentication.getPrincipal();
        CartResponse cart = cartService.updateCartItem(user.getUserId(), user.getUserEmail(), itemId, quantity);
        return ResponseEntity.ok(cart);
    }
    
    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<CartResponse> removeItem(Authentication authentication,
                                                  @PathVariable String itemId) {
        UserPrincipal user = (UserPrincipal) authentication.getPrincipal();
        CartResponse cart = cartService.removeItemFromCart(user.getUserId(), user.getUserEmail(), itemId);
        return ResponseEntity.ok(cart);
    }
    
    @DeleteMapping
    public ResponseEntity<CartResponse> clearCart(Authentication authentication) {
        UserPrincipal user = (UserPrincipal) authentication.getPrincipal();
        CartResponse cart = cartService.clearCart(user.getUserId(), user.getUserEmail());
        return ResponseEntity.ok(cart);
    }
    
    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteCart(Authentication authentication) {
        UserPrincipal user = (UserPrincipal) authentication.getPrincipal();
        cartService.deleteCart(user.getUserId(), user.getUserEmail());
        return ResponseEntity.noContent().build();
    }
}
