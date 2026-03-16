package com.nakick.shoes_service.controller;

import com.nakick.shoes_service.dto.ShoeRequest;
import com.nakick.shoes_service.dto.ShoeResponse;
import com.nakick.shoes_service.service.ShoeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shoes")
@RequiredArgsConstructor
public class ShoeController {
    
    private final ShoeService shoeService;
    
    @PostMapping
    public ResponseEntity<ShoeResponse> createShoe(
            @Valid @RequestBody ShoeRequest request
    ) {
        ShoeResponse response = shoeService.createShoe(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<List<ShoeResponse>> getAllShoes(
            @RequestParam(required = false) String brand,
            @RequestParam(required = false) String category
    ) {
        List<ShoeResponse> shoes;
        
        if (brand != null) {
            shoes = shoeService.getShoesByBrand(brand);
        } else if (category != null) {
            shoes = shoeService.getShoesByCategory(category);
        } else {
            shoes = shoeService.getAllShoes();
        }
        
        return ResponseEntity.ok(shoes);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ShoeResponse> getShoeById(@PathVariable String id,
                                                   @RequestParam(required = false, defaultValue = "false") boolean includeSkus) {
        if (includeSkus) {
            ShoeResponse response = shoeService.getShoeWithSkus(id);
            return ResponseEntity.ok(response);
        } else {
            ShoeResponse response = shoeService.getShoeById(id);
            return ResponseEntity.ok(response);
        }
    }
    
    @PutMapping(value = "/{id}")
    public ResponseEntity<ShoeResponse> updateShoe(
            @PathVariable String id,
            @Valid @RequestBody ShoeRequest request
    ) {
        ShoeResponse response = shoeService.updateShoe(id, request);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteShoe(@PathVariable String id) {
        shoeService.deleteShoe(id);
        return ResponseEntity.noContent().build();
    }
}
