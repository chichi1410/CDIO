package com.mycompany.saas.controller;

import com.mycompany.saas.domain.response.UserResponse;
import com.mycompany.saas.service.UserService;
import com.mycompany.saas.util.annotation.ApiMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/me/avatar")
    @ApiMessage("Cập nhật ảnh đại diện thành công")
    public ResponseEntity<UserResponse> updateAvatar(
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam(value = "avatarUrl", required = false) String avatarUrl) {
        UserResponse response = userService.updateAvatar(file, avatarUrl);
        return ResponseEntity.ok(response);
    }
}
