package com.yeep.service;

import com.yeep.dto.LoginRequest;
import com.yeep.dto.RegisterRequest;
import com.yeep.dto.UserResponse;
import com.yeep.entity.User;
import com.yeep.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Optional;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    // Hash password using SHA-256
    public String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    // Register new user
    public UserResponse register(RegisterRequest request) throws Exception {
        // Check if username exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new Exception("ชื่อผู้ใช้งานนี้มีอยู่แล้ว");
        }
        
        // Check if email exists
        if (request.getEmail() != null && !request.getEmail().isEmpty()) {
            if (userRepository.existsByEmail(request.getEmail())) {
                throw new Exception("Email นี้มีบัญชีอยู่แล้ว");
            }
        }
        
        // Create new user
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setPassword(hashPassword(request.getPassword())); // Hash password
        user.setRole("user");
        
        User savedUser = userRepository.save(user);
        
        return new UserResponse(
            savedUser.getId(),
            savedUser.getUsername(),
            savedUser.getEmail(),
            savedUser.getPhone(),
            savedUser.getRole()
        );
    }
    
    // Login
    public UserResponse login(LoginRequest request) throws Exception {
        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());
        
        if (userOpt.isEmpty()) {
            throw new Exception("ไม่พบชื่อผู้ใช้งานนี้");
        }
        
        User user = userOpt.get();
        
        // Check password
        boolean passwordMatch;
        if ("driver".equals(user.getRole())) {
            // Driver: plain text comparison
            passwordMatch = request.getPassword().equals(user.getPassword());
        } else {
            // User: hash comparison
            passwordMatch = hashPassword(request.getPassword()).equals(user.getPassword());
        }
        
        if (!passwordMatch) {
            throw new Exception("รหัสผ่านไม่ถูกต้อง");
        }
        
        return new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getPhone(),
            user.getRole()
        );
    }
    
    // Get user by username
    public UserResponse getUserByUsername(String username) throws Exception {
        Optional<User> userOpt = userRepository.findByUsername(username);
        
        if (userOpt.isEmpty()) {
            throw new Exception("ไม่พบผู้ใช้งาน");
        }
        
        User user = userOpt.get();
        return new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getPhone(),
            user.getRole()
        );
    }
    
    // Update password by username
    public void updatePassword(String username, String newPassword) throws Exception {
        Optional<User> userOpt = userRepository.findByUsername(username);
        
        if (userOpt.isEmpty()) {
            throw new Exception("ไม่พบผู้ใช้งาน");
        }
        
        User user = userOpt.get();
        user.setPassword(hashPassword(newPassword));
        userRepository.save(user);
    }
    
    // Update password by email
    public void updatePasswordByEmail(String email, String newPassword) throws Exception {
        Optional<User> userOpt = userRepository.findByEmail(email);
        
        if (userOpt.isEmpty()) {
            throw new Exception("ไม่พบ Email นี้ในระบบ");
        }
        
        User user = userOpt.get();
        user.setPassword(hashPassword(newPassword));
        userRepository.save(user);
    }
    
    // Check if email exists
    public boolean emailExists(String email) {
        return userRepository.existsByEmail(email);
    }
    
    // Check if username exists
    public boolean usernameExists(String username) {
        return userRepository.existsByUsername(username);
    }
    
    // Get user by email
    public UserResponse getUserByEmail(String email) throws Exception {
        Optional<User> userOpt = userRepository.findByEmail(email);
        
        if (userOpt.isEmpty()) {
            throw new Exception("ไม่พบ Email นี้ในระบบ");
        }
        
        User user = userOpt.get();
        return new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getPhone(),
            user.getRole()
        );
    }
}
