package com.nakick.cart_service.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "carts")
public class Cart {
    
    @Id
    private String id;
    
    @Field("user_id")
    private String userId;
    
    @Field("user_email")
    private String userEmail;
    
    @Field("items")
    private List<CartItem> items;
    
    @Field("total_amount")
    private BigDecimal totalAmount;
    
    @Field("total_items")
    private Integer totalItems;
    
    @Field("created_at")
    private LocalDateTime createdAt;
    
    @Field("updated_at")
    private LocalDateTime updatedAt;
    
    @Field("status")
    private CartStatus status;
    
    public enum CartStatus {
        ACTIVE,
        CHECKOUT,
        ABANDONED,
        EXPIRED
    }
    
    public Cart(String userId, String userEmail) {
        this.userId = userId;
        this.userEmail = userEmail;
        this.items = new ArrayList<>();
        this.totalAmount = BigDecimal.ZERO;
        this.totalItems = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.status = CartStatus.ACTIVE;
    }
    
    public void calculateTotals() {
        this.totalItems = items.stream()
                .mapToInt(item -> item.getQuantity())
                .sum();
        
        this.totalAmount = items.stream()
                .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        this.updatedAt = LocalDateTime.now();
    }
    
    // Explicit getters and setters to avoid Lombok issues
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    
    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }
    
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    
    public Integer getTotalItems() { return totalItems; }
    public void setTotalItems(Integer totalItems) { this.totalItems = totalItems; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public CartStatus getStatus() { return status; }
    public void setStatus(CartStatus status) { this.status = status; }
}
