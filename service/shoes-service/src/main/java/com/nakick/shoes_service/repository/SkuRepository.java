package com.nakick.shoes_service.repository;

import com.nakick.shoes_service.entity.Sku;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SkuRepository extends MongoRepository<Sku, String> {
    
    List<Sku> findByProductId(String productId);
    
    Optional<Sku> findByProductIdAndColorAndSize(String productId, String color, String size);
    
    List<Sku> findByProductIdAndIsActive(String productId, Boolean isActive);
    
    List<Sku> findByProductIdAndColorAndIsActive(String productId, String color, Boolean isActive);
    
    List<Sku> findByProductIdAndSizeAndIsActive(String productId, String size, Boolean isActive);
    
    List<Sku> findByColorAndSizeAndIsActive(String color, String size, Boolean isActive);
    
    List<Sku> findByIsActive(Boolean isActive);
    
    @Query("{'productId': ?0, 'stock': {$gt: 0}, 'isActive': true}")
    List<Sku> findAvailableSkusByProductId(String productId);
    
    @Query("{'stock': {$gt: 0}, 'isActive': true}")
    List<Sku> findAllAvailableSkus();
    
    @Query("{'productId': ?0, 'color': ?1, 'size': ?2, 'stock': {$gt: 0}, 'isActive': true}")
    Optional<Sku> findAvailableSku(String productId, String color, String size);
    
    @Query(value = "{'productId': ?0, 'isActive': true}", fields = "{'color': 1, 'size': 1}")
    List<Sku> findDistinctColorsAndSizesByProductId(String productId);
    
    boolean existsByProductIdAndColorAndSize(String productId, String color, String size);
    
    @Query("{'productId': ?0}")
    long countSkusByProductId(String productId);
    
    @Query("{'productId': ?0, 'stock': {$gt: 0}, 'isActive': true}")
    long countAvailableSkusByProductId(String productId);
}
