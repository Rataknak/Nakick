package com.nakick.shoes_service.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Document(collection = "shoes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Shoe {
    
    @Id
    private String id;
    
    private String brand;
    private String model;
    private String description;
    private String category; // e.g., Running, Basketball, Casual, Formal
    private BigDecimal basePrice;
    private String imageUrl;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private Integer totalStock;
    private Boolean isActive;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public Shoe(String brand, String model, String description, String category, BigDecimal basePrice, String imageUrl) {
        this.brand = brand;
        this.model = model;
        this.description = description;
        this.category = category;
        this.basePrice = basePrice;
        this.imageUrl = imageUrl;
        this.isActive = true;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.totalStock = 0;
    }
    
    public void updateVariantInfo(BigDecimal minPrice, BigDecimal maxPrice, Integer totalStock) {
        this.minPrice = minPrice;
        this.maxPrice = maxPrice;
        this.totalStock = totalStock;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void activate() {
        this.isActive = true;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void deactivate() {
        this.isActive = false;
        this.updatedAt = LocalDateTime.now();
    }
    
    public Boolean hasVariants() {
        return this.totalStock > 0;
    }
}
