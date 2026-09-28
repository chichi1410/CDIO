package com.mycompany.saas.service;

import com.mycompany.saas.domain.request.ForgotPasswordRequest;
import com.mycompany.saas.domain.request.LoginRequest;
import com.mycompany.saas.domain.request.RegisterRequest;
import com.mycompany.saas.domain.request.ResetPasswordRequest;
import com.mycompany.saas.domain.response.TokenResponse;
import com.mycompany.saas.domain.response.UserResponse;

public interface AuthService {
    UserResponse register(RegisterRequest request);

    TokenResponse login(LoginRequest request);

    UserResponse getCurrentUser();

    String forgotPassword(ForgotPasswordRequest request);

    void resetPassword(ResetPasswordRequest request);
}
