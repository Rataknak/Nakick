package com.nakick.shoes_service.controller;

import com.nakick.shoes_service.dto.ShoeRequest;
import com.nakick.shoes_service.dto.ShoeResponse;
import com.nakick.shoes_service.service.ShoeService;
import com.nakick.shoes_service.service.FileStorageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/shoes")
@RequiredArgsConstructor
public class ShoeController {
    
    private final ShoeService shoeService;
    private final FileStorageService fileStorageService;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;
    
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Shoes Service is up and running!");
    }

    @PostMapping(consumes = "application/json")
    public ResponseEntity<ShoeResponse> createShoeJson(@Valid @RequestBody ShoeRequest request) {
        ShoeResponse response = shoeService.createShoe(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<?> createShoeMultipart(
            @RequestParam("shoe") String shoeJson,
            @RequestParam(value = "image", required = false) MultipartFile image
    ) {
        try {
            ShoeRequest request = objectMapper.readValue(shoeJson, ShoeRequest.class);
            
            // Handle image upload if provided
            if (image != null && !image.isEmpty()) {
                String fileName = fileStorageService.storeFile(image);
                // In a real microservices environment, this should be a configurable base URL
                String imageUrl = "http://localhost:8083/api/images/" + fileName;
                request.setImageUrl(imageUrl);
            }
            
            ShoeResponse response = shoeService.createShoe(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + e.getMessage());
        }
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
