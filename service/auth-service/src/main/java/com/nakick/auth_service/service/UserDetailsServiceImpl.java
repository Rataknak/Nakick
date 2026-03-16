package com.nakick.auth_service.service;

import com.nakick.auth_service.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String identifier) throws UsernameNotFoundException {
        // Check if identifier is an email
        if (identifier.contains("@")) {
            return userRepository.findByEmail(identifier)
                    .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + identifier));
        } else {
            // For username, try finding by username first, if not found try by email
            return userRepository.findByUsername(identifier)
                    .orElseGet(() -> userRepository.findByEmail(identifier)
                            .orElseThrow(() -> new UsernameNotFoundException("User not found with username: " + identifier)));
        }
    }
}
