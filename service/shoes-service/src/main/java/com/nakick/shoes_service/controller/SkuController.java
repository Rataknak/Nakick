package com.nakick.shoes_service.controller;

import com.nakick.shoes_service.dto.SkuRequest;
import com.nakick.shoes_service.dto.SkuResponse;
import com.nakick.shoes_service.entity.Sku;
import com.nakick.shoes_service.service.SkuService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/skus")
@RequiredArgsConstructor
public class SkuController {

    private final SkuService skuService;
    private final com.nakick.shoes_service.service.FileStorageService fileStorageService;

    @GetMapping
    public ResponseEntity<List<SkuResponse>> getAllSkus() {
        List<Sku> skus = skuService.getAllSkus();
        List<SkuResponse> responses = skus.stream()
                .map(SkuResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{id}")
    public ResponseEntity<SkuResponse> getSkuById(@PathVariable String id) {
        return skuService.getSkuById(id)
                .map(sku -> ResponseEntity.ok(SkuResponse.fromEntity(sku)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<SkuResponse>> getSkusByProductId(@PathVariable String productId) {
        List<Sku> skus = skuService.getSkusByProductId(productId);
        List<SkuResponse> responses = skus.stream()
                .map(SkuResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/product/{productId}/available")
    public ResponseEntity<List<SkuResponse>> getAvailableSkusByProductId(@PathVariable String productId) {
        List<Sku> skus = skuService.getAvailableSkusByProductId(productId);
        List<SkuResponse> responses = skus.stream()
                .map(SkuResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/available")
    public ResponseEntity<List<SkuResponse>> getAllAvailableSkus() {
        List<Sku> skus = skuService.getAllAvailableSkus();
        List<SkuResponse> responses = skus.stream()
                .map(SkuResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/check-availability")
    public ResponseEntity<Boolean> checkSkuAvailability(@RequestParam String skuId, 
                                                      @RequestParam Integer quantity) {
        boolean available = skuService.isSkuAvailable(skuId, quantity);
        return ResponseEntity.ok(available);
    }

    @GetMapping("/search")
    public ResponseEntity<List<SkuResponse>> searchSkus(@RequestParam(required = false) String color,
                                                       @RequestParam(required = false) String size) {
        List<Sku> skus;
        if (color != null && size != null) {
            skus = skuService.getSkusByColorAndSize(color, size);
        } else if (color != null) {
            skus = skuService.getSkusByColor(color);
        } else if (size != null) {
            skus = skuService.getSkusBySize(size);
        } else {
            skus = skuService.getAllSkus();
        }
        
        List<SkuResponse> responses = skus.stream()
                .map(SkuResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<SkuResponse> createSku(
            @RequestPart("sku") SkuRequest request,
            @RequestPart(value = "image", required = false) org.springframework.web.multipart.MultipartFile image
    ) {
        try {
            // Handle image upload if provided
            if (image != null && !image.isEmpty()) {
                String fileName = fileStorageService.storeFile(image);
                String imageUrl = "http://localhost:8083/api/images/" + fileName;
                request.setImageUrl(imageUrl);
            }
            
            Sku sku = skuService.createSku(
                request.getProductId(),
                request.getColor(),
                request.getSize(),
                request.getPrice(),
                request.getStock(),
                request.getImageUrl(),
                request.getSkuCode()
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(SkuResponse.fromEntity(sku));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping(value = "/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<SkuResponse> updateSku(
            @PathVariable String id,
            @RequestPart("sku") SkuRequest request,
            @RequestPart(value = "image", required = false) org.springframework.web.multipart.MultipartFile image
    ) {
        try {
            // Handle image upload if provided
            if (image != null && !image.isEmpty()) {
                String fileName = fileStorageService.storeFile(image);
                String imageUrl = "http://localhost:8083/api/images/" + fileName;
                request.setImageUrl(imageUrl);
            }

            Sku sku = skuService.updateSku(
                id,
                request.getColor(),
                request.getSize(),
                request.getPrice(),
                request.getStock(),
                request.getImageUrl(),
                request.getSkuCode()
            );
            return ResponseEntity.ok(SkuResponse.fromEntity(sku));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping("/{id}/stock")
    public ResponseEntity<SkuResponse> updateStock(@PathVariable String id, 
                                                  @RequestParam Integer quantity) {
        try {
            Sku sku = skuService.updateStock(id, quantity);
            return ResponseEntity.ok(SkuResponse.fromEntity(sku));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PutMapping("/{id}/decrease-stock")
    public ResponseEntity<SkuResponse> decreaseStock(@PathVariable String id, 
                                                     @RequestParam Integer quantity) {
        try {
            Sku sku = skuService.decreaseStock(id, quantity);
            return ResponseEntity.ok(SkuResponse.fromEntity(sku));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping("/{id}/activate")
    public ResponseEntity<SkuResponse> activateSku(@PathVariable String id) {
        try {
            Sku sku = skuService.activateSku(id);
            return ResponseEntity.ok(SkuResponse.fromEntity(sku));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSku(@PathVariable String id) {
        try {
            skuService.deleteSku(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/product/{productId}/stats")
    public ResponseEntity<Object> getProductSkuStats(@PathVariable String productId) {
        long totalSkus = skuService.countSkusByProductId(productId);
        long availableSkus = skuService.countAvailableSkusByProductId(productId);
        
        java.util.Map<String, Long> stats = new java.util.HashMap<>();
        stats.put("totalSkus", totalSkus);
        stats.put("availableSkus", availableSkus);
        stats.put("outOfStockSkus", totalSkus - availableSkus);
        
        return ResponseEntity.ok(stats);
    }
}
