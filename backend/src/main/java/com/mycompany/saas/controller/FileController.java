package com.mycompany.saas.controller;

import java.util.Map;

import com.mycompany.saas.domain.request.PresignedSignatureRequest;
import com.mycompany.saas.domain.response.CloudinarySignatureResponse;
import com.mycompany.saas.domain.response.FileUploadResponse;
import com.mycompany.saas.service.CloudinaryService;
import com.mycompany.saas.util.annotation.ApiMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/files")
@RequiredArgsConstructor
@edu.umd.cs.findbugs.annotations.SuppressFBWarnings(
        value = "EI_EXPOSE_REP2",
        justification = "Spring managed service dependency"
)
public class FileController {

    private final CloudinaryService cloudinaryService;

    @PostMapping("/upload-image")
    @ApiMessage("Tải hình ảnh lên thành công")
    public ResponseEntity<FileUploadResponse> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", required = false) String folder) {
        FileUploadResponse response = cloudinaryService.uploadImage(file, folder);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/upload-video")
    @ApiMessage("Tải video lên thành công")
    public ResponseEntity<FileUploadResponse> uploadVideo(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", required = false) String folder) {
        FileUploadResponse response = cloudinaryService.uploadVideo(file, folder);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/presigned-signature")
    @ApiMessage("Tạo chữ ký upload trực tiếp thành công")
    public ResponseEntity<CloudinarySignatureResponse> generatePresignedSignature(
            @RequestBody(required = false) PresignedSignatureRequest request) {
        CloudinarySignatureResponse response = cloudinaryService.generatePresignedSignature(request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping
    @ApiMessage("Xóa file thành công")
    public ResponseEntity<Map<String, String>> deleteFile(
            @RequestParam("publicId") String publicId,
            @RequestParam(value = "resourceType", required = false, defaultValue = "image") String resourceType) {
        cloudinaryService.deleteFile(publicId, resourceType);
        return ResponseEntity.ok(Map.of("message", "Đã xóa file trên Cloudinary thành công"));
    }
}
