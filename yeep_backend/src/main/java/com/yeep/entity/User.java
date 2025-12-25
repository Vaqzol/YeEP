package com.yeep.entity;

import jakarta.persistence.*;

/**
 * User Entity - สืบทอดจาก BaseEntity
 * ใช้หลักการ Inheritance เพื่อ reuse fields และ methods จาก parent class
 */
@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true)
    private String email;

    private String phone;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role = "user"; // "user" or "driver"

    // Profile picture path (สำหรับ File Input feature)
    @Column(name = "profile_picture")
    private String profilePicture;

    // Constructors
    public User() {
        super();
    }

    public User(String username, String email, String phone, String password, String role) {
        super();
        this.username = username;
        this.email = email;
        this.phone = phone;
        this.password = password;
        this.role = role;
    }

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getProfilePicture() {
        return profilePicture;
    }

    public void setProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
    }
}
