package com.yeep.controller;

import com.yeep.dto.*;
import com.yeep.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // Allow Flutter app to access
public class UserController {
    
    @Autowired
    private UserService userService;
    
    // POST /api/login
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<UserResponse>> login(@RequestBody LoginRequest request) {
        try {
            UserResponse user = userService.login(request);
            return ResponseEntity.ok(ApiResponse.success("เข้าสู่ระบบสำเร็จ", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // POST /api/register
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponse>> register(@RequestBody RegisterRequest request) {
        try {
            UserResponse user = userService.register(request);
            return ResponseEntity.ok(ApiResponse.success("ลงทะเบียนสำเร็จ", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // GET /api/user/{username}
    @GetMapping("/user/{username}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable String username) {
        try {
            UserResponse user = userService.getUserByUsername(username);
            return ResponseEntity.ok(ApiResponse.success("สำเร็จ", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // POST /api/update-password
    @PostMapping("/update-password")
    public ResponseEntity<ApiResponse<Void>> updatePassword(
            @RequestParam String email,
            @RequestParam String newPassword) {
        try {
            userService.updatePasswordByEmail(email, newPassword);
            return ResponseEntity.ok(ApiResponse.success("เปลี่ยนรหัสผ่านสำเร็จ"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // GET /api/check-email?email=xxx
    @GetMapping("/check-email")
    public ResponseEntity<ApiResponse<Boolean>> checkEmail(@RequestParam String email) {
        boolean exists = userService.emailExists(email);
        return ResponseEntity.ok(ApiResponse.success("ตรวจสอบสำเร็จ", exists));
    }
    
    // GET /api/check-username?username=xxx
    @GetMapping("/check-username")
    public ResponseEntity<ApiResponse<Boolean>> checkUsername(@RequestParam String username) {
        boolean exists = userService.usernameExists(username);
        return ResponseEntity.ok(ApiResponse.success("ตรวจสอบสำเร็จ", exists));
    }
    
    // Health check
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        return ResponseEntity.ok(ApiResponse.success("OK", "YeEP Backend is running!"));
    }
}
