package com.mycompany.saas;

import java.nio.charset.StandardCharsets;

import com.mycompany.saas.domain.request.PresignedSignatureRequest;
import com.mycompany.saas.domain.response.CloudinarySignatureResponse;
import com.mycompany.saas.service.CloudinaryService;
import com.mycompany.saas.util.error.BadRequestException;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;

@SpringBootTest
class FileControllerTest {

    @Autowired
    private CloudinaryService cloudinaryService;

    @Test
    void testGeneratePresignedSignature() {
        PresignedSignatureRequest request = new PresignedSignatureRequest();
        request.setFolder("saas/test");
        request.setUploadPreset("unsigned_preset");

        CloudinarySignatureResponse response = cloudinaryService.generatePresignedSignature(request);

        Assertions.assertNotNull(response);
        Assertions.assertNotNull(response.signature());
        Assertions.assertTrue(response.timestamp() > 0);
        Assertions.assertEquals("demo", response.cloudName());
        Assertions.assertEquals("1234567890", response.apiKey());
        Assertions.assertEquals("saas/test", response.folder());
    }

    @Test
    void testUploadImageWithEmptyFileThrowsException() {
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file",
                "test.png",
                "image/png",
                new byte[0]
        );

        Assertions.assertThrows(BadRequestException.class, () -> {
            cloudinaryService.uploadImage(emptyFile, "saas/test");
        });
    }

    @Test
    void testUploadImageWithInvalidTypeThrowsException() {
        MockMultipartFile invalidFile = new MockMultipartFile(
                "file",
                "test.txt",
                "text/plain",
                "Hello World".getBytes(StandardCharsets.UTF_8)
        );

        Assertions.assertThrows(BadRequestException.class, () -> {
            cloudinaryService.uploadImage(invalidFile, "saas/test");
        });
    }

    @Test
    void testUploadVideoWithInvalidTypeThrowsException() {
        MockMultipartFile invalidFile = new MockMultipartFile(
                "file",
                "test.png",
                "image/png",
                "Fake Image Content".getBytes(StandardCharsets.UTF_8)
        );

        Assertions.assertThrows(BadRequestException.class, () -> {
            cloudinaryService.uploadVideo(invalidFile, "saas/test");
        });
    }

    @Test
    void testUploadAudioWithInvalidTypeThrowsException() {
        MockMultipartFile invalidFile = new MockMultipartFile(
                "file",
                "test.pdf",
                "application/pdf",
                "Fake PDF Content".getBytes(StandardCharsets.UTF_8)
        );

        Assertions.assertThrows(BadRequestException.class, () -> {
            cloudinaryService.uploadAudio(invalidFile, "saas/test");
        });
    }
}
