package com.nakick.shoes_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkuRequest {
    
    @NotBlank(message = "Product ID is required")
    private String productId;
    
    @NotBlank(message = "Color is required")
    private String color;
    
    @NotBlank(message = "Size is required")
    private String size;
    
    @NotNull(message = "Price is required")
    @PositiveOrZero(message = "Price must be positive or zero")
    private BigDecimal price;
    
    @NotNull(message = "Stock is required")
    @PositiveOrZero(message = "Stock must be positive or zero")
    private Integer stock;
    
    private String imageUrl;
    
    private String skuCode;
}
