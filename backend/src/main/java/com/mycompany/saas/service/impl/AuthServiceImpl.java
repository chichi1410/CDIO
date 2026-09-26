package com.mycompany.saas.service.impl;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

import com.mycompany.saas.domain.Role;
import com.mycompany.saas.domain.User;
import com.mycompany.saas.domain.request.ForgotPasswordRequest;
import com.mycompany.saas.domain.request.LoginRequest;
import com.mycompany.saas.domain.request.RegisterRequest;
import com.mycompany.saas.domain.request.ResetPasswordRequest;
import com.mycompany.saas.domain.response.TokenResponse;
import com.mycompany.saas.domain.response.UserResponse;
import com.mycompany.saas.repository.UserRepository;
import com.mycompany.saas.service.AuthService;
import com.mycompany.saas.util.SecurityUtil;
import com.mycompany.saas.util.error.BadRequestException;
import com.mycompany.saas.util.error.ConflictException;
import com.mycompany.saas.util.error.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtEncoder jwtEncoder;

    // In-memory OTP storage for demo/development purposes
    private final Map<String, String> otpStorage = new ConcurrentHashMap<>();

    @Value("${AUTH_JWT_ISSUER:saas-app}")
    private String jwtIssuer;

    @Override
    @Transactional
    public UserResponse register(RegisterRequest request) {
        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmail(email)) {
            throw new ConflictException("Email is already registered");
        }

        User user = new User();
        user.setName(request.getName().trim());
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : Role.ROLE_USER);
        user.setActive(true);

        User savedUser = userRepository.save(user);
        return UserResponse.fromUser(savedUser);
    }

    @Override
    @Transactional(readOnly = true)
    public TokenResponse login(LoginRequest request) {
        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);

        authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken.unauthenticated(email, request.getPassword())
        );

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("User not found with email: " + email));

        if (!user.isActive()) {
            throw new BadRequestException("User account is inactive");
        }

        Instant now = Instant.now();
        long validitySeconds = 86400L; // 24 hours
        Instant expiresAt = now.plus(validitySeconds, ChronoUnit.SECONDS);

        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(jwtIssuer)
                .issuedAt(now)
                .expiresAt(expiresAt)
                .subject(user.getEmail())
                .claim("userId", user.getId())
                .claim("name", user.getName())
                .claim("role", user.getRole().name())
                .build();

        String token = jwtEncoder.encode(JwtEncoderParameters.from(claims)).getTokenValue();

        return new TokenResponse(token, "Bearer", validitySeconds, UserResponse.fromUser(user));
    }

    @Override
    @Transactional(readOnly = true)
    public UserResponse getCurrentUser() {
        String email = SecurityUtil.getCurrentUserLogin()
                .orElseThrow(() -> new BadRequestException("No authenticated user found in context"));

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("User not found with email: " + email));

        return UserResponse.fromUser(user);
    }

    @Override
    public String forgotPassword(ForgotPasswordRequest request) {
        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("Email user not found: " + email));

        // Generate 6-digit OTP
        String otp = String.format("%06d", new Random().nextInt(900000) + 100000);
        otpStorage.put(email, otp);
        return otp;
    }

    @Override
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        String cachedOtp = otpStorage.get(email);

        if (cachedOtp == null || !cachedOtp.equals(request.getOtp().trim())) {
            throw new BadRequestException("Invalid or expired OTP code");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("User not found: " + email));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Remove used OTP
        otpStorage.remove(email);
    }
}
