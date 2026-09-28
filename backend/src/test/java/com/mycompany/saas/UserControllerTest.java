package com.mycompany.saas;

import com.mycompany.saas.domain.User;
import com.mycompany.saas.domain.response.UserResponse;
import com.mycompany.saas.repository.UserRepository;
import com.mycompany.saas.service.UserService;
import com.mycompany.saas.util.error.BadRequestException;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class UserControllerTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Test
    @WithMockUser(username = "avataruser@test.com")
    void testUpdateAvatarWithPresetUrl() {
        User user = new User();
        user.setEmail("avataruser@test.com");
        user.setName("Avatar User");
        user.setPassword("secretPassword123");
        userRepository.save(user);

        String presetUrl = "https://example.com/preset-avatar.png";
        UserResponse response = userService.updateAvatar(null, presetUrl);

        Assertions.assertNotNull(response);
        Assertions.assertEquals(presetUrl, response.avatarUrl());

        User updated = userRepository.findByEmail("avataruser@test.com").orElse(null);
        Assertions.assertNotNull(updated);
        Assertions.assertEquals(presetUrl, updated.getAvatarUrl());
    }

    @Test
    @WithMockUser(username = "avataruser2@test.com")
    void testUpdateAvatarWithNullInputsThrowsException() {
        User user = new User();
        user.setEmail("avataruser2@test.com");
        user.setName("Avatar User 2");
        user.setPassword("secretPassword123");
        userRepository.save(user);

        Assertions.assertThrows(BadRequestException.class, () -> {
            userService.updateAvatar(null, null);
        });
    }
}
