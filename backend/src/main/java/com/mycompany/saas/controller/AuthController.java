package com.mycompany.saas.controller;

import java.util.Map;

import com.mycompany.saas.domain.request.ForgotPasswordRequest;
import com.mycompany.saas.domain.request.LoginRequest;
import com.mycompany.saas.domain.request.RegisterRequest;
import com.mycompany.saas.domain.request.ResetPasswordRequest;
import com.mycompany.saas.domain.response.TokenResponse;
import com.mycompany.saas.domain.response.UserResponse;
import com.mycompany.saas.service.AuthService;
import com.mycompany.saas.util.annotation.ApiMessage;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @ApiMessage("Register user successfully")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/login")
    @ApiMessage("Login successfully")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @GetMapping("/me")
    @ApiMessage("Get current user profile successfully")
    public ResponseEntity<UserResponse> getCurrentUser() {
        return ResponseEntity.ok(authService.getCurrentUser());
    }

    @PostMapping("/forgot-password")
    @ApiMessage("OTP code sent successfully")
    public ResponseEntity<Map<String, String>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        String otp = authService.forgotPassword(request);
        return ResponseEntity.ok(Map.of(
                "message", "Mã OTP đã được gửi đến email " + request.getEmail(),
                "otpDemo", otp
        ));
    }

    @PostMapping("/reset-password")
    @ApiMessage("Password reset successfully")
    public ResponseEntity<Map<String, String>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(Map.of(
                "message", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập bằng mật khẩu mới."
        ));
    }

    @PostMapping("/logout")
    @ApiMessage("Logged out successfully")
    public ResponseEntity<Map<String, String>> logout() {
        return ResponseEntity.ok(Map.of("message", "Đã đăng xuất thành công"));
    }
}
