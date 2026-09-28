package com.mycompany.saas.service.impl;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.mycompany.saas.domain.request.PresignedSignatureRequest;
import com.mycompany.saas.domain.response.CloudinarySignatureResponse;
import com.mycompany.saas.domain.response.FileUploadResponse;
import com.mycompany.saas.service.CloudinaryService;
import com.mycompany.saas.util.error.BadRequestException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@edu.umd.cs.findbugs.annotations.SuppressFBWarnings(
        value = "EI_EXPOSE_REP2",
        justification = "Spring managed Cloudinary client bean"
)
public class CloudinaryServiceImpl implements CloudinaryService {

    private final Cloudinary cloudinary;

    @Value("${cloudinary.api-key:1234567890}")
    private String apiKey;

    @Value("${cloudinary.api-secret:secret}")
    private String apiSecret;

    @Value("${cloudinary.cloud-name:demo}")
    private String cloudName;

    @Override
    public FileUploadResponse uploadImage(MultipartFile file, String folder) {
        validateFile(file);
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BadRequestException("File tải lên phải là hình ảnh (jpg, png, webp, gif,...)");
        }

        String targetFolder = (folder != null && !folder.isBlank()) ? folder : "saas/images";

        try {
            Map<?, ?> uploadResult = cloudinary.uploader().upload(
                    file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", targetFolder,
                            "resource_type", "image"
                    )
            );
            return mapToUploadResponse(uploadResult);
        } catch (IOException e) {
            throw new BadRequestException("Không thể tải hình ảnh lên Cloudinary: " + e.getMessage());
        }
    }

    @Override
    public FileUploadResponse uploadVideo(MultipartFile file, String folder) {
        validateFile(file);
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("video/")) {
            throw new BadRequestException("File tải lên phải là video (mp4, mov, avi, webm,...)");
        }

        String targetFolder = (folder != null && !folder.isBlank()) ? folder : "saas/videos";

        try {
            Map<?, ?> uploadResult = cloudinary.uploader().upload(
                    file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", targetFolder,
                            "resource_type", "video"
                    )
            );
            return mapToUploadResponse(uploadResult);
        } catch (IOException e) {
            throw new BadRequestException("Không thể tải video lên Cloudinary: " + e.getMessage());
        }
    }

    @Override
    public CloudinarySignatureResponse generatePresignedSignature(PresignedSignatureRequest request) {
        long timestamp = System.currentTimeMillis() / 1000L;

        Map<String, Object> paramsToSign = new HashMap<>();
        paramsToSign.put("timestamp", timestamp);

        String targetFolder = "saas/uploads";
        if (request != null && request.getFolder() != null && !request.getFolder().isBlank()) {
            targetFolder = request.getFolder();
            paramsToSign.put("folder", targetFolder);
        }

        if (request != null && request.getUploadPreset() != null && !request.getUploadPreset().isBlank()) {
            paramsToSign.put("upload_preset", request.getUploadPreset());
        }

        String signature = cloudinary.apiSignRequest(paramsToSign, apiSecret);

        return new CloudinarySignatureResponse(
                signature,
                timestamp,
                apiKey,
                cloudName,
                targetFolder
        );
    }

    @Override
    public void deleteFile(String publicId, String resourceType) {
        if (publicId == null || publicId.isBlank()) {
            throw new BadRequestException("publicId không được để trống");
        }

        String type = (resourceType != null && !resourceType.isBlank()) ? resourceType : "image";
        try {
            Map<?, ?> result = cloudinary.uploader().destroy(
                    publicId,
                    ObjectUtils.asMap("resource_type", type)
            );
            String resultStatus = (String) result.get("result");
            if (!"ok".equals(resultStatus) && !"not found".equals(resultStatus)) {
                throw new BadRequestException("Không thể xóa file trên Cloudinary. Trạng thái: " + resultStatus);
            }
        } catch (IOException e) {
            throw new BadRequestException("Lỗi khi xóa file trên Cloudinary: " + e.getMessage());
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("File tải lên không được để trống");
        }
    }

    private FileUploadResponse mapToUploadResponse(Map<?, ?> uploadResult) {
        String publicId = (String) uploadResult.get("public_id");
        String url = (String) uploadResult.get("secure_url");
        if (url == null) {
            url = (String) uploadResult.get("url");
        }
        String format = (String) uploadResult.get("format");
        String resourceType = (String) uploadResult.get("resource_type");

        Number bytesNumber = (Number) uploadResult.get("bytes");
        long bytes = bytesNumber != null ? bytesNumber.longValue() : 0L;

        Number durationNumber = (Number) uploadResult.get("duration");
        Double duration = durationNumber != null ? durationNumber.doubleValue() : null;

        String createdAt = (String) uploadResult.get("created_at");

        return new FileUploadResponse(
                publicId,
                url,
                format,
                resourceType,
                bytes,
                duration,
                createdAt
        );
    }
}
