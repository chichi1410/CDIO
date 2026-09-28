package com.mycompany.saas.service.impl;

import com.mycompany.saas.domain.User;
import com.mycompany.saas.domain.response.FileUploadResponse;
import com.mycompany.saas.domain.response.UserResponse;
import com.mycompany.saas.repository.UserRepository;
import com.mycompany.saas.service.CloudinaryService;
import com.mycompany.saas.service.UserService;
import com.mycompany.saas.util.SecurityUtil;
import com.mycompany.saas.util.error.BadRequestException;
import com.mycompany.saas.util.error.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@edu.umd.cs.findbugs.annotations.SuppressFBWarnings(
        value = "EI_EXPOSE_REP2",
        justification = "Spring managed bean dependencies"
)
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    @Transactional
    public UserResponse updateAvatar(MultipartFile file, String avatarUrl) {
        String email = SecurityUtil.getCurrentUserLogin()
                .orElseThrow(() -> new BadRequestException("Vui lòng đăng nhập để thực hiện thao tác này"));

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("Không tìm thấy người dùng với email: " + email));

        String oldAvatarUrl = user.getAvatarUrl();
        String newAvatarUrl = null;

        if (file != null && !file.isEmpty()) {
            FileUploadResponse uploadResponse = cloudinaryService.uploadImage(file, "saas/avatars");
            newAvatarUrl = uploadResponse.url();
        } else if (avatarUrl != null && !avatarUrl.isBlank()) {
            newAvatarUrl = avatarUrl.trim();
        } else {
            throw new BadRequestException("Vui lòng tải lên file ảnh hoặc cung cấp đường dẫn avatar hợp lệ");
        }

        user.setAvatarUrl(newAvatarUrl);
        user = userRepository.save(user);

        // Phương án 1: Tự động dọn dẹp ảnh cũ trên Cloudinary để tiết kiệm dung lượng
        if (oldAvatarUrl != null && oldAvatarUrl.contains("cloudinary.com") && oldAvatarUrl.contains("saas/avatars")) {
            deleteOldCloudinaryAvatar(oldAvatarUrl);
        }

        return UserResponse.fromUser(user);
    }

    private void deleteOldCloudinaryAvatar(String oldAvatarUrl) {
        try {
            int folderIndex = oldAvatarUrl.indexOf("saas/avatars/");
            if (folderIndex != -1) {
                String sub = oldAvatarUrl.substring(folderIndex);
                int dotIndex = sub.lastIndexOf('.');
                String publicId = (dotIndex != -1) ? sub.substring(0, dotIndex) : sub;
                cloudinaryService.deleteFile(publicId, "image");
            }
        } catch (RuntimeException e) {
            // Không làm gián đoạn cập nhật avatar nếu việc xóa file cũ gặp lỗi
        }
    }
}
