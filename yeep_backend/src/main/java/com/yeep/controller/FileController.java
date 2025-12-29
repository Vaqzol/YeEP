package com.yeep.controller;

import com.yeep.dto.ApiResponse;
import com.yeep.service.FileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * FileController - REST API สำหรับจัดการไฟล์
 * 
 * สาธิตการ File Input/Output ผ่าน REST API
 */
@RestController
@RequestMapping("/api/files")
@CrossOrigin(origins = "*")
public class FileController {

    @Autowired
    private FileService fileService;

    /**
     * อัพโหลดรูปโปรไฟล์
     * 
     * POST /api/files/profile/{username}
     */
    @PostMapping("/profile/{username}")
    public ResponseEntity<Map<String, Object>> uploadProfileImage(
            @PathVariable String username,
            @RequestParam("file") MultipartFile file) {

        Map<String, Object> result = fileService.uploadProfileImage(username, file);

        if ((boolean) result.get("success")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }

    /**
     * ดึงรูปโปรไฟล์
     * 
     * GET /api/files/profile/{username}
     */
    @GetMapping("/profile/{username}")
    public ResponseEntity<byte[]> getProfileImage(@PathVariable String username) {
        byte[] imageData = fileService.getProfileImage(username);

        if (imageData != null) {
            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(imageData);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * ตรวจสอบไฟล์ก่อนอัพโหลด
     * 
     * POST /api/files/validate
     */
    @PostMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateFile(
            @RequestParam("filename") String filename,
            @RequestParam("size") long size) {

        Map<String, Object> result = fileService.validateImageFile(filename, size);
        return ResponseEntity.ok(result);
    }

    /**
     * ดึงข้อมูลการตั้งค่าไฟล์
     * 
     * GET /api/files/config
     */
    @GetMapping("/config")
    public ResponseEntity<ApiResponse> getFileConfig() {
        return ResponseEntity.ok(new ApiResponse(true, "File configuration", Map.of(
                "maxFileSize", FileService.MAX_FILE_SIZE,
                "maxFileSizeFormatted", "5 MB",
                "allowedExtensions", FileService.ALLOWED_IMAGE_EXTENSIONS)));
    }
}
