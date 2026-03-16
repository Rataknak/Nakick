package com.nakick.cart_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkuResponse {
    
    private String id;
    private String productId;
    private String brand;
    private String model;
    private String size;
    private String color;
    private BigDecimal price;
    private Integer stock;
    private String imageUrl;
    private String skuCode;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isActive;
    private Boolean inStock;
}
