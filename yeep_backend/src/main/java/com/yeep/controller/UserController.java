package com.yeep.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.yeep.dto.ApiResponse;
import com.yeep.dto.LoginRequest;
import com.yeep.dto.RegisterRequest;
import com.yeep.dto.UserResponse;
import com.yeep.service.UserService;

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
    
    // POST /api/init-drivers - สร้างข้อมูลคนขับเริ่มต้น
    @PostMapping("/init-drivers")
    public ResponseEntity<ApiResponse<String>> initDrivers() {
        try {
            userService.initializeDrivers();
            return ResponseEntity.ok(ApiResponse.success("สร้างข้อมูลคนขับสำเร็จ", "Created 6 drivers"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // Health check
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> health() {
        return ResponseEntity.ok(ApiResponse.success("OK", "YeEP Backend is running!"));
    }
}
