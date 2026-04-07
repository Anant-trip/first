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

	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception { // Added throws Exception
    http.csrf(c -> c.disable())
        .authorizeHttpRequests(req -> req
                // 1. Allow the endpoints
                .requestMatchers("/register", "/login", "/auth").permitAll()
                // 2. Allow static resources (CSS, JS, Images)
                .requestMatchers("/css/**", "/js/**", "/images/**", "/static/**").permitAll()
                // 3. IMPORTANT: Allow the internal WEB-INF views if using JSP
                .requestMatchers("/WEB-INF/views/**").permitAll() 
                .anyRequest().authenticated()
        )
        .formLogin(f -> f
                .loginPage("/login")
                .loginProcessingUrl("/auth")
                .defaultSuccessUrl("/dashboard", true) // 'true' forces it to go to dashboard
                .failureUrl("/login?msg=error")
                .permitAll()
        )
        .logout(l -> l
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .permitAll()
        );
        
    return http.build();
}
	
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
}

