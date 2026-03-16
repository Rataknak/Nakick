package com.nakick.cart_service.security;

import com.nakick.cart_service.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        final String requestTokenHeader = request.getHeader("Authorization");

        String userId = null;
        String userEmail = null;
        String jwtToken = null;

        // JWT Token is in the form "Bearer token"
        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);
            try {
                userEmail = jwtUtil.extractEmail(jwtToken);
                userId = jwtUtil.extractUserId(jwtToken);
            } catch (Exception e) {
                logger.warn("Unable to get JWT Token");
            }
        }

        // Validate token and set authentication
        if (userId != null && userEmail != null && jwtUtil.validateToken(jwtToken)) {
            // Create authentication object
            UserPrincipal userPrincipal = new UserPrincipal(userId, userEmail);
            UsernamePasswordAuthenticationToken authToken = 
                new UsernamePasswordAuthenticationToken(userPrincipal, null, List.of(new SimpleGrantedAuthority("ROLE_USER")));
            SecurityContextHolder.getContext().setAuthentication(authToken);
            
            // Add user info to request attributes for controller
            request.setAttribute("userId", userId);
            request.setAttribute("userEmail", userEmail);
        }

        filterChain.doFilter(request, response);
    }
}
