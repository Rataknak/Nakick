package com.nakick.shoes_service.service;

import com.nakick.shoes_service.dto.ShoeRequest;
import com.nakick.shoes_service.dto.ShoeResponse;
import com.nakick.shoes_service.dto.SkuResponse;
import com.nakick.shoes_service.entity.Shoe;
import com.nakick.shoes_service.entity.Sku;
import com.nakick.shoes_service.exception.ResourceNotFoundException;
import com.nakick.shoes_service.repository.ShoeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShoeService {
    
    private final ShoeRepository shoeRepository;
    private final SkuService skuService;
    
    public ShoeResponse createShoe(ShoeRequest request) {
        Shoe shoe = new Shoe(
            request.getBrand(),
            request.getModel(),
            request.getDescription(),
            request.getCategory(),
            request.getBasePrice(),
            request.getImageUrl()
        );
        
        Shoe savedShoe = shoeRepository.save(shoe);
        return mapToResponse(savedShoe);
    }
    
    public List<ShoeResponse> getAllShoes() {
        return shoeRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public ShoeResponse getShoeById(String id) {
        Shoe shoe = shoeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shoe not found with id: " + id));
        return mapToResponse(shoe);
    }
    
    public ShoeResponse updateShoe(String id, ShoeRequest request) {
        Shoe shoe = shoeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shoe not found with id: " + id));
        
        shoe.setBrand(request.getBrand());
        shoe.setModel(request.getModel());
        shoe.setDescription(request.getDescription());
        shoe.setCategory(request.getCategory());
        shoe.setBasePrice(request.getBasePrice());
        shoe.setImageUrl(request.getImageUrl());
        
        shoe.setUpdatedAt(LocalDateTime.now());
        
        Shoe updatedShoe = shoeRepository.save(shoe);
        return mapToResponse(updatedShoe);
    }
    
    public void deleteShoe(String id) {
        if (!shoeRepository.existsById(id)) {
            throw new ResourceNotFoundException("Shoe not found with id: " + id);
        }
        shoeRepository.deleteById(id);
    }
    
    public List<ShoeResponse> getShoesByBrand(String brand) {
        return shoeRepository.findByBrand(brand).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<ShoeResponse> getShoesByCategory(String category) {
        return shoeRepository.findByCategory(category).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public ShoeResponse getShoeWithSkus(String id) {
        Shoe shoe = shoeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shoe not found with id: " + id));
        return mapToResponseWithSkus(shoe);
    }
    
    public void updateProductVariantInfo(String productId) {
        List<Sku> skus = skuService.getSkusByProductId(productId);
        
        if (!skus.isEmpty()) {
            BigDecimal minPrice = skus.stream()
                    .map(Sku::getPrice)
                    .min(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);
            
            BigDecimal maxPrice = skus.stream()
                    .map(Sku::getPrice)
                    .max(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);
            
            Integer totalStock = skus.stream()
                    .mapToInt(Sku::getStock)
                    .sum();
            
            Shoe shoe = shoeRepository.findById(productId)
                    .orElseThrow(() -> new ResourceNotFoundException("Shoe not found with id: " + productId));
            
            shoe.updateVariantInfo(minPrice, maxPrice, totalStock);
            shoeRepository.save(shoe);
        }
    }
    
    private ShoeResponse mapToResponse(Shoe shoe) {
        ShoeResponse response = new ShoeResponse();
        response.setId(shoe.getId());
        response.setBrand(shoe.getBrand());
        response.setModel(shoe.getModel());
        response.setDescription(shoe.getDescription());
        response.setCategory(shoe.getCategory());
        response.setBasePrice(shoe.getBasePrice());
        response.setImageUrl(shoe.getImageUrl());
        response.setMinPrice(shoe.getMinPrice());
        response.setMaxPrice(shoe.getMaxPrice());
        response.setTotalStock(shoe.getTotalStock());
        response.setIsActive(shoe.getIsActive());
        response.setCreatedAt(shoe.getCreatedAt());
        response.setUpdatedAt(shoe.getUpdatedAt());
        return response;
    }
    
    private ShoeResponse mapToResponseWithSkus(Shoe shoe) {
        ShoeResponse response = mapToResponse(shoe);
        List<Sku> skus = skuService.getSkusByProductId(shoe.getId());
        List<SkuResponse> skuResponses = skus.stream()
                .map(SkuResponse::fromEntity)
                .collect(Collectors.toList());
        response.setSkus(skuResponses);
        return response;
    }
}
