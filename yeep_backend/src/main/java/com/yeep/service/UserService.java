package com.yeep.service;

import com.yeep.dto.LoginRequest;
import com.yeep.dto.RegisterRequest;
import com.yeep.dto.UserResponse;
import com.yeep.entity.User;
import com.yeep.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Optional;

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
                ? rawPassword.equals(user.getPassword())  // Driver: plain text
                : hashPassword(rawPassword).equals(user.getPassword());  // User: hashed
        
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
                user.getRole()
        );
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
}
