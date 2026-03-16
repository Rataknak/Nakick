package com.nakick.cart_service.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Field;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CartItem {
    
    @Id
    private String id;
    
    @Field("sku_id")
    private String skuId;
    
    @Field("product_id")
    private String productId;
    
    @Field("brand")
    private String brand;
    
    @Field("model")
    private String model;
    
    @Field("color")
    private String color;
    
    @Field("size")
    private String size;
    
    @Field("price")
    private BigDecimal price;
    
    @Field("quantity")
    private Integer quantity;
    
    @Field("image_url")
    private String imageUrl;
    
    @Field("added_at")
    private LocalDateTime addedAt;
    
    public CartItem(String skuId, String productId, String brand, String model, String color, String size, BigDecimal price, Integer quantity, String imageUrl) {
        this.skuId = skuId;
        this.productId = productId;
        this.brand = brand;
        this.model = model;
        this.color = color;
        this.size = size;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
        this.addedAt = LocalDateTime.now();
    }
    
    // Explicit getters and setters to avoid Lombok issues
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getSkuId() { return skuId; }
    public void setSkuId(String skuId) { this.skuId = skuId; }
    
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    
    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    
    public LocalDateTime getAddedAt() { return addedAt; }
    public void setAddedAt(LocalDateTime addedAt) { this.addedAt = addedAt; }
}
