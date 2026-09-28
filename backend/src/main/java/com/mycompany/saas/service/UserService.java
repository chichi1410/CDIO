package com.mycompany.saas.service;

import com.mycompany.saas.domain.response.UserResponse;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {

    UserResponse updateAvatar(MultipartFile file, String avatarUrl);
}
