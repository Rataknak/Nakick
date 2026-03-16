package com.nakick.cart_service.config;

import feign.RequestInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ShoesServiceClientConfig {

    @Bean
    public RequestInterceptor shoesServiceFeignRequestInterceptor() {
        return new FeignRequestInterceptor();
    }
}
