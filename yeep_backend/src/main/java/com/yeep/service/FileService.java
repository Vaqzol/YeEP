package com.yeep.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * FileService - บริการจัดการไฟล์
 * 
 * สาธิตการใช้งาน File Input/Output ในหลักการ OOP
 * - อ่านไฟล์ (File Input)
 * - เขียนไฟล์ (File Output)
 * - ตรวจสอบขนาดไฟล์
 * - จัดการไฟล์รูปภาพ
 */
@Service
public class FileService {

    // ==================== CONSTANTS ====================

    /** ขนาดไฟล์สูงสุดที่อนุญาต (5MB) */
    public static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB in bytes

    /** นามสกุลไฟล์รูปภาพที่อนุญาต */
    public static final List<String> ALLOWED_IMAGE_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif", "webp");

    /** โฟลเดอร์เก็บไฟล์อัพโหลด */
    private static final String UPLOAD_DIR = "uploads";

    /** โฟลเดอร์เก็บรูปโปรไฟล์ */
    private static final String PROFILE_DIR = "profiles";

    // ==================== FILE INPUT METHODS ====================

    /**
     * อ่านไฟล์ข้อความ (File Input)
     * 
     * @param filePath พาธของไฟล์
     * @return เนื้อหาไฟล์เป็น List ของบรรทัด
     * @throws IOException หากไม่สามารถอ่านไฟล์ได้
     */
    public List<String> readTextFile(String filePath) throws IOException {
        List<String> lines = new ArrayList<>();

        // ใช้ BufferedReader สำหรับอ่านไฟล์ทีละบรรทัด
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        }

        return lines;
    }

    /**
     * อ่านไฟล์ CSV และแปลงเป็น List ของ Map
     * 
     * @param filePath พาธของไฟล์ CSV
     * @return ข้อมูลในรูปแบบ List ของ Map
     * @throws IOException หากไม่สามารถอ่านไฟล์ได้
     */
    public List<Map<String, String>> readCsvFile(String filePath) throws IOException {
        List<Map<String, String>> data = new ArrayList<>();
        List<String> lines = readTextFile(filePath);

        if (lines.isEmpty()) {
            return data;
        }

        // บรรทัดแรกเป็น header
        String[] headers = lines.get(0).split(",");

        // อ่านข้อมูลจากบรรทัดที่ 2 เป็นต้นไป
        for (int i = 1; i < lines.size(); i++) {
            String[] values = lines.get(i).split(",");
            Map<String, String> row = new HashMap<>();

            for (int j = 0; j < headers.length && j < values.length; j++) {
                row.put(headers[j].trim(), values[j].trim());
            }

            data.add(row);
        }

        return data;
    }

    /**
     * อ่านไฟล์ไบนารี (เช่น รูปภาพ)
     * 
     * @param filePath พาธของไฟล์
     * @return ข้อมูลไฟล์เป็น byte array
     * @throws IOException หากไม่สามารถอ่านไฟล์ได้
     */
    public byte[] readBinaryFile(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        return Files.readAllBytes(path);
    }

    // ==================== FILE OUTPUT METHODS ====================

    /**
     * เขียนไฟล์ข้อความ
     * 
     * @param filePath พาธของไฟล์
     * @param content  เนื้อหาที่ต้องการเขียน
     * @throws IOException หากไม่สามารถเขียนไฟล์ได้
     */
    public void writeTextFile(String filePath, String content) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            writer.write(content);
        }
    }

    /**
     * เขียนไฟล์ข้อความหลายบรรทัด
     * 
     * @param filePath พาธของไฟล์
     * @param lines    รายการบรรทัดที่ต้องการเขียน
     * @throws IOException หากไม่สามารถเขียนไฟล์ได้
     */
    public void writeTextFile(String filePath, List<String> lines) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        }
    }

    /**
     * บันทึกไฟล์ไบนารี
     * 
     * @param filePath พาธของไฟล์
     * @param data     ข้อมูลที่ต้องการบันทึก
     * @throws IOException หากไม่สามารถบันทึกไฟล์ได้
     */
    public void writeBinaryFile(String filePath, byte[] data) throws IOException {
        Path path = Paths.get(filePath);
        Files.write(path, data);
    }

    // ==================== FILE VALIDATION METHODS ====================

    /**
     * ตรวจสอบขนาดไฟล์
     * 
     * @param fileSize ขนาดไฟล์ (bytes)
     * @return true หากขนาดไม่เกิน MAX_FILE_SIZE
     */
    public boolean validateFileSize(long fileSize) {
        return fileSize <= MAX_FILE_SIZE;
    }

    /**
     * ตรวจสอบนามสกุลไฟล์รูปภาพ
     * 
     * @param fileName ชื่อไฟล์
     * @return true หากเป็นนามสกุลที่อนุญาต
     */
    public boolean validateImageExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return false;
        }

        String extension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        return ALLOWED_IMAGE_EXTENSIONS.contains(extension);
    }

    /**
     * ตรวจสอบไฟล์รูปภาพ (ทั้งขนาดและนามสกุล)
     * 
     * @param fileName ชื่อไฟล์
     * @param fileSize ขนาดไฟล์
     * @return Map ผลการตรวจสอบ
     */
    public Map<String, Object> validateImageFile(String fileName, long fileSize) {
        Map<String, Object> result = new HashMap<>();

        boolean sizeValid = validateFileSize(fileSize);
        boolean extensionValid = validateImageExtension(fileName);

        result.put("valid", sizeValid && extensionValid);
        result.put("sizeValid", sizeValid);
        result.put("extensionValid", extensionValid);

        if (!sizeValid) {
            result.put("sizeError", "ขนาดไฟล์เกิน " + (MAX_FILE_SIZE / 1024 / 1024) + " MB");
        }

        if (!extensionValid) {
            result.put("extensionError", "นามสกุลไฟล์ไม่ถูกต้อง อนุญาตเฉพาะ: " +
                    String.join(", ", ALLOWED_IMAGE_EXTENSIONS));
        }

        return result;
    }

    // ==================== FILE UPLOAD METHODS ====================

    /**
     * อัพโหลดรูปโปรไฟล์
     * 
     * @param username ชื่อผู้ใช้
     * @param file     ไฟล์ที่อัพโหลด (MultipartFile)
     * @return Map ผลการอัพโหลด
     */
    public Map<String, Object> uploadProfileImage(String username, MultipartFile file) {
        Map<String, Object> result = new HashMap<>();

        try {
            // ตรวจสอบไฟล์
            String originalFilename = file.getOriginalFilename();
            Map<String, Object> validation = validateImageFile(originalFilename, file.getSize());

            if (!(boolean) validation.get("valid")) {
                result.put("success", false);
                result.put("validation", validation);
                return result;
            }

            // สร้างโฟลเดอร์ถ้ายังไม่มี
            Path uploadPath = Paths.get(UPLOAD_DIR, PROFILE_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // สร้างชื่อไฟล์ใหม่
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String newFilename = username + "_" + timestamp + extension;

            // บันทึกไฟล์
            Path filePath = uploadPath.resolve(newFilename);
            Files.write(filePath, file.getBytes());

            result.put("success", true);
            result.put("filename", newFilename);
            result.put("path", filePath.toString());
            result.put("size", file.getSize());

        } catch (IOException e) {
            result.put("success", false);
            result.put("error", "ไม่สามารถบันทึกไฟล์ได้: " + e.getMessage());
        }

        return result;
    }

    /**
     * ดึงรูปโปรไฟล์ของผู้ใช้
     * 
     * @param username ชื่อผู้ใช้
     * @return ข้อมูลไฟล์เป็น byte array หรือ null หากไม่พบ
     */
    public byte[] getProfileImage(String username) {
        try {
            Path profileDir = Paths.get(UPLOAD_DIR, PROFILE_DIR);

            if (!Files.exists(profileDir)) {
                return null;
            }

            // ค้นหาไฟล์ที่ขึ้นต้นด้วย username
            Optional<Path> profileFile = Files.list(profileDir)
                    .filter(path -> path.getFileName().toString().startsWith(username + "_"))
                    .sorted(Comparator.reverseOrder()) // เอาไฟล์ล่าสุด
                    .findFirst();

            if (profileFile.isPresent()) {
                return Files.readAllBytes(profileFile.get());
            }

        } catch (IOException e) {
            // Log error
            System.err.println("Error reading profile image: " + e.getMessage());
        }

        return null;
    }

    // ==================== FILE UTILITY METHODS ====================

    /**
     * ลบไฟล์
     * 
     * @param filePath พาธของไฟล์
     * @return true หากลบสำเร็จ
     */
    public boolean deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            return Files.deleteIfExists(path);
        } catch (IOException e) {
            return false;
        }
    }

    /**
     * ตรวจสอบว่าไฟล์มีอยู่หรือไม่
     * 
     * @param filePath พาธของไฟล์
     * @return true หากไฟล์มีอยู่
     */
    public boolean fileExists(String filePath) {
        return Files.exists(Paths.get(filePath));
    }

    /**
     * ดึงขนาดไฟล์
     * 
     * @param filePath พาธของไฟล์
     * @return ขนาดไฟล์ (bytes) หรือ -1 หากไม่พบไฟล์
     */
    public long getFileSize(String filePath) {
        try {
            return Files.size(Paths.get(filePath));
        } catch (IOException e) {
            return -1;
        }
    }

    /**
     * แปลงขนาดไฟล์เป็นข้อความที่อ่านง่าย
     * 
     * @param bytes ขนาดไฟล์ (bytes)
     * @return ขนาดไฟล์ในรูปแบบที่อ่านง่าย
     */
    public String formatFileSize(long bytes) {
        if (bytes < 1024) {
            return bytes + " B";
        } else if (bytes < 1024 * 1024) {
            return String.format("%.2f KB", bytes / 1024.0);
        } else if (bytes < 1024 * 1024 * 1024) {
            return String.format("%.2f MB", bytes / (1024.0 * 1024));
        } else {
            return String.format("%.2f GB", bytes / (1024.0 * 1024 * 1024));
        }
    }
}
