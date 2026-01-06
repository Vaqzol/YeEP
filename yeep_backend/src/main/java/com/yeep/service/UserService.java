package com.yeep.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.yeep.dto.LoginRequest;
import com.yeep.dto.RegisterRequest;
import com.yeep.dto.UserResponse;
import com.yeep.entity.User;
import com.yeep.repository.UserRepository;

@Service
public class UserService {

    private static final String ROLE_USER = "user";
    private static final String ROLE_DRIVER = "driver";
    private static final String HASH_ALGORITHM = "SHA-256";

    @Autowired
    private UserRepository userRepository;

    // ==================== PUBLIC METHODS ====================

    /**
     * ลงทะเบียนผู้ใช้ใหม่
     */
    public UserResponse register(RegisterRequest request) throws Exception {
        validateUsernameNotExists(request.getUsername());
        validateEmailNotExists(request.getEmail());

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setPassword(hashPassword(request.getPassword()));
        user.setRole(ROLE_USER);

        return toUserResponse(userRepository.save(user));
    }

    /**
     * เข้าสู่ระบบ
     */
    public UserResponse login(LoginRequest request) throws Exception {
        User user = findUserByUsernameOrThrow(request.getUsername());
        validatePassword(user, request.getPassword());
        return toUserResponse(user);
    }

    /**
     * ดึงข้อมูล user จาก username
     */
    public UserResponse getUserByUsername(String username) throws Exception {
        return toUserResponse(findUserByUsernameOrThrow(username));
    }

    /**
     * ดึงข้อมูล user จาก email
     */
    public UserResponse getUserByEmail(String email) throws Exception {
        return toUserResponse(findUserByEmailOrThrow(email));
    }

    /**
     * เปลี่ยนรหัสผ่านด้วย username
     */
    public void updatePassword(String username, String newPassword) throws Exception {
        User user = findUserByUsernameOrThrow(username);
        user.setPassword(hashPassword(newPassword));
        userRepository.save(user);
    }

    /**
     * เปลี่ยนรหัสผ่านด้วย email
     */
    public void updatePasswordByEmail(String email, String newPassword) throws Exception {
        User user = findUserByEmailOrThrow(email);
        user.setPassword(hashPassword(newPassword));
        userRepository.save(user);
    }

    /**
     * ตรวจสอบว่า email มีอยู่หรือไม่
     */
    public boolean emailExists(String email) {
        return userRepository.existsByEmail(email);
    }

    /**
     * ตรวจสอบว่า username มีอยู่หรือไม่
     */
    public boolean usernameExists(String username) {
        return userRepository.existsByUsername(username);
    }

    /**
     * สร้างบัญชีคนขับ (Driver)
     */
    public UserResponse createDriver(String username, String password) throws Exception {
        // ถ้ามี driver นี้อยู่แล้ว ไม่ต้องสร้างใหม่
        Optional<User> existing = userRepository.findByUsername(username);
        if (existing.isPresent()) {
            return toUserResponse(existing.get());
        }

        User driver = new User();
        driver.setUsername(username);
        driver.setPassword(password); // Driver ใช้ plain text password
        driver.setRole(ROLE_DRIVER);

        return toUserResponse(userRepository.save(driver));
    }

    /**
     * สร้างข้อมูลคนขับเริ่มต้น (5 คน)
     */
    public void initializeDrivers() {
        String[][] drivers = {
                { "driver1", "1234" },
                { "driver2", "1234" },
                { "driver3", "1234" },
                { "driver4", "1234" },
                { "driver5", "1234" },
        };

        for (String[] d : drivers) {
            try {
                createDriver(d[0], d[1]);
            } catch (Exception e) {
                // ข้ามถ้ามีอยู่แล้ว
            }
        }
    }

    // ==================== PRIVATE HELPER METHODS ====================

    private User findUserByUsernameOrThrow(String username) throws Exception {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new Exception("ไม่พบชื่อผู้ใช้งานนี้"));
    }

    private User findUserByEmailOrThrow(String email) throws Exception {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new Exception("ไม่พบ Email นี้ในระบบ"));
    }

    private void validateUsernameNotExists(String username) throws Exception {
        if (userRepository.existsByUsername(username)) {
            throw new Exception("ชื่อผู้ใช้งานนี้มีอยู่แล้ว");
        }
    }

    private void validateEmailNotExists(String email) throws Exception {
        if (email != null && !email.isEmpty() && userRepository.existsByEmail(email)) {
            throw new Exception("Email นี้มีบัญชีอยู่แล้ว");
        }
    }

    private void validatePassword(User user, String rawPassword) throws Exception {
        boolean passwordMatch = ROLE_DRIVER.equals(user.getRole())
                ? rawPassword.equals(user.getPassword()) // Driver: plain text
                : hashPassword(rawPassword).equals(user.getPassword()); // User: hashed

        if (!passwordMatch) {
            throw new Exception("รหัสผ่านไม่ถูกต้อง");
        }
    }

    private UserResponse toUserResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getPhone(),
                user.getRole());
    }

    /**
     * Hash password using SHA-256
     */
    public String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    // ==================== DATA SEARCHING (Sequential Search #2)
    // ====================
    /**
     * ค้นหาผู้ใช้ตาม Role ด้วย Sequential Search Algorithm
     * 
     * Sequential Search Algorithm (Linear Search):
     * 1. วนลูปตรวจสอบทีละ element ตั้งแต่ต้นจนจบ
     * 2. เปรียบเทียบกับเงื่อนไขที่ต้องการ
     * 3. ถ้าตรง เพิ่มเข้าผลลัพธ์
     * 
     * Time Complexity: O(n)
     * Space Complexity: O(1) สำหรับการค้นหา
     * 
     * @param role role ที่ต้องการค้นหา (user, driver)
     * @return รายการผู้ใช้ที่มี role ตรงกัน
     */
    public java.util.List<User> searchUsersByRole(String role) {
        // ดึงข้อมูลทั้งหมด
        java.util.List<User> allUsers = userRepository.findAll();
        java.util.List<User> result = new java.util.ArrayList<>();

        // Sequential Search - วนลูปตรวจสอบทีละ element
        for (int i = 0; i < allUsers.size(); i++) {
            User user = allUsers.get(i);

            // ตรวจสอบเงื่อนไข role
            if (role != null && !role.isEmpty()) {
                // เปรียบเทียบแบบ case-insensitive
                if (user.getRole() != null &&
                        user.getRole().toLowerCase().equals(role.toLowerCase())) {
                    result.add(user);
                }
            }
        }

        return result;
    }

    /**
     * ค้นหาผู้ใช้ตามชื่อ (partial match) ด้วย Sequential Search
     * 
     * @param namePattern รูปแบบชื่อที่ต้องการค้นหา
     * @return รายการผู้ใช้ที่ชื่อตรงกับรูปแบบ
     */
    public java.util.List<User> searchUsersByName(String namePattern) {
        java.util.List<User> allUsers = userRepository.findAll();
        java.util.List<User> result = new java.util.ArrayList<>();

        // Sequential Search
        for (int i = 0; i < allUsers.size(); i++) {
            User user = allUsers.get(i);

            if (namePattern != null && !namePattern.isEmpty()) {
                // partial match, case-insensitive
                if (user.getUsername() != null &&
                        user.getUsername().toLowerCase().contains(namePattern.toLowerCase())) {
                    result.add(user);
                }
            }
        }

        return result;
    }

    // ==================== COMPOSITION EXAMPLE #2 ====================
    /**
     * UserProfile - ตัวอย่าง Composition
     * 
     * Composition: UserProfile "owns" ContactInfo และ Preferences objects
     * ถ้า UserProfile ถูกลบ, ContactInfo และ Preferences จะถูกลบด้วย
     * 
     * นี่แสดงความสัมพันธ์แบบ "has-a" ที่แข็งแกร่ง:
     * - ContactInfo ไม่สามารถอยู่ได้โดยไม่มี UserProfile
     * - Preferences ไม่สามารถอยู่ได้โดยไม่มี UserProfile
     */
    public static class UserProfile {
        private String username;
        // Composition: UserProfile owns ContactInfo
        private ContactInfo contactInfo;
        // Composition: UserProfile owns Preferences
        private Preferences preferences;

        public UserProfile(String username) {
            this.username = username;
            // Composition: สร้าง part objects พร้อมกับ whole
            this.contactInfo = new ContactInfo();
            this.preferences = new Preferences();
        }

        public String getUsername() {
            return username;
        }

        public ContactInfo getContactInfo() {
            return contactInfo;
        }

        public Preferences getPreferences() {
            return preferences;
        }

        // เมื่อ UserProfile ถูกทำลาย, parts ทั้งหมดจะถูกทำลายด้วย
        public void destroy() {
            this.contactInfo = null;
            this.preferences = null;
        }

        // Composition Part #1: ContactInfo
        public static class ContactInfo {
            private String email;
            private String phone;
            private String address;

            public void setEmail(String email) {
                this.email = email;
            }

            public void setPhone(String phone) {
                this.phone = phone;
            }

            public void setAddress(String address) {
                this.address = address;
            }

            public String getEmail() {
                return email;
            }

            public String getPhone() {
                return phone;
            }

            public String getAddress() {
                return address;
            }
        }

        // Composition Part #2: Preferences
        public static class Preferences {
            private boolean emailNotifications = true;
            private boolean smsNotifications = false;
            private String language = "th";

            public void setEmailNotifications(boolean enabled) {
                this.emailNotifications = enabled;
            }

            public void setSmsNotifications(boolean enabled) {
                this.smsNotifications = enabled;
            }

            public void setLanguage(String language) {
                this.language = language;
            }

            public boolean isEmailNotifications() {
                return emailNotifications;
            }

            public boolean isSmsNotifications() {
                return smsNotifications;
            }

            public String getLanguage() {
                return language;
            }
        }
    }
}
