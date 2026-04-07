import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import jakarta.servlet.DispatcherType; // Use Jakarta for Spring Boot 3

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        
        http.csrf(c -> c.disable())
            .authorizeHttpRequests(req -> req
                    // Allows internal forwarding for view resolution (JSPs/Thymeleaf)
                    .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                    .requestMatchers("/register", "/login", "/auth").permitAll()
                    .requestMatchers("/WEB-INF/**", "/static/**", "/css/**", "/js/**").permitAll()
                    .anyRequest().authenticated()
            )
            .formLogin(f -> f
                    .loginPage("/login")         // GET Controller
                    .loginProcessingUrl("/auth") // POST Action
                    .defaultSuccessUrl("/dashboard", true) // 'true' prevents loops after login
                    .failureUrl("/login?msg=Invalid credentials")
                    .permitAll()
            )
            .logout(l -> l
                    .logoutUrl("/logout")
                    .logoutSuccessUrl("/login?msg=Logged out")
                    .permitAll()
            );
            
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
