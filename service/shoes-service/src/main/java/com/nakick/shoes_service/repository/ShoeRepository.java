package com.nakick.shoes_service.repository;

import com.nakick.shoes_service.entity.Shoe;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShoeRepository extends MongoRepository<Shoe, String> {
    
    List<Shoe> findByBrand(String brand);
    
    List<Shoe> findByCategory(String category);
    
    List<Shoe> findByBrandAndCategory(String brand, String category);
}
