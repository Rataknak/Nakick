package com.nakick.shoes_service.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/images")
public class ImageUploadController {

    @Value("${file.upload.dir}")
    private String uploadDir;

    @Value("${file.upload.max-size:5242880}")
    private long maxFileSize;

    @Value("${file.upload.allowed-types:jpg,jpeg,png,gif,webp}")
    private String allowedTypes;

    @PostMapping("/upload")
    public ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            // Validate file
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("File is empty");
            }

            // Check file size
            if (file.getSize() > maxFileSize) {
                return ResponseEntity.badRequest().body("File size exceeds " + (maxFileSize / 1024 / 1024) + "MB limit");
            }

            // Check file extension
            String originalFilename = file.getOriginalFilename();
            if (originalFilename == null) {
                return ResponseEntity.badRequest().body("Invalid filename");
            }

            String extension = FilenameUtils.getExtension(originalFilename).toLowerCase();
            List<String> allowedExtensions = Arrays.asList(allowedTypes.split(","));
            if (!allowedExtensions.contains(extension)) {
                return ResponseEntity.badRequest().body("Invalid file type. Allowed: " + allowedTypes);
            }

            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // Generate unique filename
            String uniqueFilename = UUID.randomUUID().toString() + "." + extension;
            Path filePath = uploadPath.resolve(uniqueFilename);

            // Save file
            Files.copy(file.getInputStream(), filePath);

            // Return file URL
            String fileUrl = "http://localhost:8083/api/images/" + uniqueFilename;
            return ResponseEntity.ok(fileUrl);

        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Failed to upload file: " + e.getMessage());
        }
    }

    @GetMapping("/{filename}")
    public ResponseEntity<byte[]> getImage(@PathVariable String filename) throws IOException {
        Path filePath = Paths.get(uploadDir, filename);
        
        if (!Files.exists(filePath)) {
            return ResponseEntity.notFound().build();
        }

        String contentType = Files.probeContentType(filePath);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        byte[] imageBytes = Files.readAllBytes(filePath);
        return ResponseEntity.ok()
                .header("Content-Type", contentType)
                .body(imageBytes);
    }

    @DeleteMapping("/{filename}")
    public ResponseEntity<String> deleteImage(@PathVariable String filename) {
        try {
            Path filePath = Paths.get(uploadDir, filename);
            
            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            Files.delete(filePath);
            return ResponseEntity.ok("Image deleted successfully");

        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Failed to delete file: " + e.getMessage());
        }
    }
}
