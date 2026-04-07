package com.tyss.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http.csrf(c -> c.disable())
        .authorizeHttpRequests(req -> req
            // Allow DispatcherType.FORWARD so internal view resolution isn't blocked
            .dispatcherTypeMatchers(javax.servlet.DispatcherType.FORWARD).permitAll() 
            .requestMatchers("/register", "/login", "/auth").permitAll()
            .requestMatchers("/WEB-INF/**", "/static/**", "/css/**", "/js/**").permitAll()
            .anyRequest().authenticated()
        )
        .formLogin(f -> f
            .loginPage("/login")
            .loginProcessingUrl("/auth")
            .defaultSuccessUrl("/dashboard", true) // Force redirect to avoid landing on cached URLs
            .failureUrl("/login?msg=Invalid credentials")
            .permitAll()
        )
        .logout(l -> l.logoutUrl("/logout").permitAll());

    return http.build();
}
	
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
}

