package com.nakick.cart_service.client;

import com.nakick.cart_service.config.ShoesServiceClientConfig;
import com.nakick.cart_service.dto.SkuResponse;
import com.nakick.cart_service.dto.ShoeResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name = "SHOES-SERVICE", path = "/api", configuration = ShoesServiceClientConfig.class)
public interface ShoesServiceClient {
    
    @GetMapping("/skus/{skuId}")
    SkuResponse getSkuById(@PathVariable("skuId") String skuId);
    
    @GetMapping("/skus/product/{productId}")
    List<SkuResponse> getSkusByProductId(@PathVariable("productId") String productId);
    
    @GetMapping("/skus/{skuId}/available")
    SkuResponse getAvailableSkuById(@PathVariable("skuId") String skuId);
    
    @GetMapping("/shoes/{productId}")
    ShoeResponse getShoeById(@PathVariable("productId") String productId);
}
