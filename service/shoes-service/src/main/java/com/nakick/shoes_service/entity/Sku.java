package com.nakick.shoes_service.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Document(collection = "skus")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Sku {
    
    @Id
    private String id;
    
    @Field("product_id")
    private String productId;
    
    @Field("color")
    private String color;
    
    @Field("size")
    private String size;
    
    @Field("price")
    private BigDecimal price;
    
    @Field("stock")
    private Integer stock;
    
    @Field("image_url")
    private String imageUrl;
    
    @Field("sku_code")
    private String skuCode;
    
    @Field("created_at")
    private LocalDateTime createdAt;
    
    @Field("updated_at")
    private LocalDateTime updatedAt;
    
    @Field("is_active")
    private Boolean isActive;
    
    public Sku(String productId, String color, String size, BigDecimal price, Integer stock, String imageUrl, String skuCode) {
        this.productId = productId;
        this.color = color;
        this.size = size;
        this.price = price;
        this.stock = stock;
        this.imageUrl = imageUrl;
        this.skuCode = skuCode;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.isActive = true;
    }
    
    public void updateStock(Integer quantity) {
        this.stock = this.stock + quantity;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void decreaseStock(Integer quantity) {
        if (this.stock >= quantity) {
            this.stock = this.stock - quantity;
            this.updatedAt = LocalDateTime.now();
        } else {
            throw new RuntimeException("Insufficient stock. Available: " + this.stock + ", Requested: " + quantity);
        }
    }
    
    public Boolean isInStock() {
        return this.stock > 0 && this.isActive;
    }
    
    public void activate() {
        this.isActive = true;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.isActive = false;
        this.updatedAt = LocalDateTime.now();
    }
}
