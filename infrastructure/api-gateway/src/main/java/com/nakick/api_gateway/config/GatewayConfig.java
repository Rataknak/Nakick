package com.nakick.api_gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("shoes-service", r -> r.path("/api/shoes/**")
                        .uri("lb://shoes-service"))
                .route("cart-service", r -> r.path("/api/cart/**")
                        .uri("lb://cart-service"))
                .route("user-service", r -> r.path("/api/users/**")
                        .uri("lb://user-service"))
                .route("auth-service", r -> r.path("/api/auth/**")
                        .uri("lb://auth-service"))
                .build();
    }
}
