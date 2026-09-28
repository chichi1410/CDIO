package com.mycompany.saas;

import com.mycompany.saas.domain.request.LoginRequest;
import com.mycompany.saas.domain.request.RegisterRequest;
import com.mycompany.saas.domain.response.TokenResponse;
import com.mycompany.saas.domain.response.UserResponse;
import com.mycompany.saas.service.AuthService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class AuthControllerTest {

    @Autowired
    private AuthService authService;

    @Test
    void testRegisterAndLoginFlow() {
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setName("Test User");
        registerRequest.setEmail("testuser@example.com");
        registerRequest.setPassword("securePassword123");

        UserResponse userResponse = authService.register(registerRequest);
        Assertions.assertNotNull(userResponse);
        Assertions.assertEquals("testuser@example.com", userResponse.email());
        Assertions.assertEquals("Test User", userResponse.name());

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setEmail("testuser@example.com");
        loginRequest.setPassword("securePassword123");

        TokenResponse tokenResponse = authService.login(loginRequest);
        Assertions.assertNotNull(tokenResponse);
        Assertions.assertNotNull(tokenResponse.accessToken());
        Assertions.assertEquals("Bearer", tokenResponse.tokenType());
        Assertions.assertEquals("testuser@example.com", tokenResponse.user().email());
    }
}
