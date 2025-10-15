package com.example.datn_qlkh.config;

import com.example.datn_qlkh.service.CustomUserDetailsService;
import com.example.datn_qlkh.service.GoogleOAuth2UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;

    public SecurityConfig(CustomUserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    // 1️⃣ Cấu hình PasswordEncoder
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // 2️⃣ Cấu hình AuthenticationProvider dùng UserDetailsService
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    // 3️⃣ Cấu hình SecurityFilterChain
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, GoogleOAuth2UserService googleOAuth2UserService) throws Exception {
        http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/auth/**", "/css/**", "/js/**", "/images/**", "/uploads/**").permitAll()
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .anyRequest().authenticated()
                )

                .formLogin(login -> login
                        .loginPage("/auth/login")          // URL form login
                        .loginProcessingUrl("/auth/login") // action form login
                        .usernameParameter("email")        // tên input cho username
                        .passwordParameter("password")     // tên input cho password
                        .defaultSuccessUrl("/?loginSuccess=true", true)      // sau khi đăng nhập thành công
                        .failureUrl("/auth/login?error=true") // nếu đăng nhập thất bại
                        .permitAll()
                )

                .oauth2Login(oauth -> oauth
                        .loginPage("/auth/login")
                        .defaultSuccessUrl("/?loginSuccess=true", true)
                        .failureUrl("/auth/login?error=true")
                        .userInfoEndpoint(user -> user.oidcUserService(googleOAuth2UserService))
                )

                // Cấu hình logout
                .logout(logout -> logout
                        .logoutUrl("/auth/logout")
                        .logoutSuccessUrl("/?logoutSuccess=true")
                        .invalidateHttpSession(true)
                        .clearAuthentication(true)
                        .permitAll()
                )

                // Tắt CSRF cho dễ test (nếu cần)
                .csrf(csrf -> csrf.disable())
        ;

        return http.build();
    }
}
