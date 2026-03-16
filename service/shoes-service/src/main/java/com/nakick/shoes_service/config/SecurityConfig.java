package com.nakick.shoes_service.config;

import com.nakick.shoes_service.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/shoes/health").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/shoes/**").permitAll() // Public browsing
                .requestMatchers(HttpMethod.GET, "/api/skus/**").permitAll() // Public SKU browsing
                .requestMatchers("/api/images/**").permitAll() // Public image access
                .requestMatchers("/api/shoes/**").hasRole("ADMIN") // Admin only for POST, PUT, DELETE
                .requestMatchers("/api/skus/**").hasRole("ADMIN") // Admin only for POST, PUT, DELETE
                .requestMatchers("/actuator/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
