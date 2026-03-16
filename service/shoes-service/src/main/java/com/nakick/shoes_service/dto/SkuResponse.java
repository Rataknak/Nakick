package com.nakick.shoes_service.dto;

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
    private String color;
    private String size;
    private BigDecimal price;
    private Integer stock;
    private String imageUrl;
    private String skuCode;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isActive;
    private Boolean inStock;
    
    public static SkuResponse fromEntity(com.nakick.shoes_service.entity.Sku sku) {
        SkuResponse response = new SkuResponse();
        response.setId(sku.getId());
        response.setProductId(sku.getProductId());
        response.setColor(sku.getColor());
        response.setSize(sku.getSize());
        response.setPrice(sku.getPrice());
        response.setStock(sku.getStock());
        response.setImageUrl(sku.getImageUrl());
        response.setSkuCode(sku.getSkuCode());
        response.setCreatedAt(sku.getCreatedAt());
        response.setUpdatedAt(sku.getUpdatedAt());
        response.setIsActive(sku.getIsActive());
        response.setInStock(sku.isInStock());
        return response;
    }
}
