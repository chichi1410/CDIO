package com.mycompany.saas.service;

import com.mycompany.saas.domain.request.PresignedSignatureRequest;
import com.mycompany.saas.domain.response.CloudinarySignatureResponse;
import com.mycompany.saas.domain.response.FileUploadResponse;
import org.springframework.web.multipart.MultipartFile;

public interface CloudinaryService {

    FileUploadResponse uploadImage(MultipartFile file, String folder);

    FileUploadResponse uploadVideo(MultipartFile file, String folder);

    CloudinarySignatureResponse generatePresignedSignature(PresignedSignatureRequest request);

    void deleteFile(String publicId, String resourceType);
}
