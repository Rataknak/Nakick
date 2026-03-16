package com.nakick.shoes_service.service;

import com.nakick.shoes_service.entity.Sku;
import com.nakick.shoes_service.repository.SkuRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class SkuService {

    private final SkuRepository skuRepository;

    public List<Sku> getAllSkus() {
        return skuRepository.findByIsActive(true);
    }

    public List<Sku> getSkusByProductId(String productId) {
        return skuRepository.findByProductIdAndIsActive(productId, true);
    }

    public Optional<Sku> getSkuById(String id) {
        return skuRepository.findById(id);
    }

    public Optional<Sku> getAvailableSku(String productId, String color, String size) {
        return skuRepository.findAvailableSku(productId, color, size);
    }

    public List<Sku> getAvailableSkusByProductId(String productId) {
        return skuRepository.findAvailableSkusByProductId(productId);
    }

    public List<Sku> getAllAvailableSkus() {
        return skuRepository.findAllAvailableSkus();
    }

    public Sku createSku(String productId, String color, String size, BigDecimal price, 
                        Integer stock, String imageUrl, String skuCode) {
        
        if (skuRepository.existsByProductIdAndColorAndSize(productId, color, size)) {
            throw new RuntimeException("SKU already exists for this product with the same color and size");
        }

        Sku sku = new Sku(productId, color, size, price, stock, imageUrl, skuCode);
        Sku savedSku = skuRepository.save(sku);
        log.info("Created new SKU: {} for product: {}", savedSku.getId(), productId);
        return savedSku;
    }

    public Sku updateSku(String id, String color, String size, BigDecimal price, 
                        Integer stock, String imageUrl, String skuCode) {
        Sku sku = skuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("SKU not found with id: " + id));

        sku.setColor(color);
        sku.setSize(size);
        sku.setPrice(price);
        sku.setStock(stock);
        sku.setImageUrl(imageUrl);
        sku.setSkuCode(skuCode);
        sku.setUpdatedAt(java.time.LocalDateTime.now());

        Sku updatedSku = skuRepository.save(sku);
        log.info("Updated SKU: {}", updatedSku.getId());
        return updatedSku;
    }

    public Sku updateStock(String skuId, Integer quantity) {
        Sku sku = skuRepository.findById(skuId)
                .orElseThrow(() -> new RuntimeException("SKU not found with id: " + skuId));
        
        sku.updateStock(quantity);
        Sku updatedSku = skuRepository.save(sku);
        log.info("Updated stock for SKU: {} by {} units", skuId, quantity);
        return updatedSku;
    }

    public Sku decreaseStock(String skuId, Integer quantity) {
        Sku sku = skuRepository.findById(skuId)
                .orElseThrow(() -> new RuntimeException("SKU not found with id: " + skuId));
        
        sku.decreaseStock(quantity);
        Sku updatedSku = skuRepository.save(sku);
        log.info("Decreased stock for SKU: {} by {} units", skuId, quantity);
        return updatedSku;
    }

    public void deleteSku(String id) {
        Sku sku = skuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("SKU not found with id: " + id));
        
        sku.deactivate();
        skuRepository.save(sku);
        log.info("Deactivated SKU: {}", id);
    }

    public Sku activateSku(String id) {
        Sku sku = skuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("SKU not found with id: " + id));
        
        sku.activate();
        Sku activatedSku = skuRepository.save(sku);
        log.info("Activated SKU: {}", id);
        return activatedSku;
    }

    public boolean isSkuAvailable(String skuId, Integer requiredQuantity) {
        Optional<Sku> skuOpt = skuRepository.findById(skuId);
        return skuOpt.map(sku -> sku.isInStock() && sku.getStock() >= requiredQuantity)
                    .orElse(false);
    }

    public List<Sku> getSkusByColor(String color) {
        return skuRepository.findByColorAndSizeAndIsActive(color, null, true);
    }

    public List<Sku> getSkusBySize(String size) {
        return skuRepository.findByColorAndSizeAndIsActive(null, size, true);
    }

    public List<Sku> getSkusByColorAndSize(String color, String size) {
        return skuRepository.findByColorAndSizeAndIsActive(color, size, true);
    }

    public long countSkusByProductId(String productId) {
        return skuRepository.countSkusByProductId(productId);
    }

    public long countAvailableSkusByProductId(String productId) {
        return skuRepository.countAvailableSkusByProductId(productId);
    }

    public void validateSkuExists(String skuId) {
        if (!skuRepository.existsById(skuId)) {
            throw new RuntimeException("SKU not found with id: " + skuId);
        }
    }

    public void validateSkuAvailable(String skuId, Integer requiredQuantity) {
        if (!isSkuAvailable(skuId, requiredQuantity)) {
            throw new RuntimeException("SKU " + skuId + " is not available or insufficient stock");
        }
    }
}
