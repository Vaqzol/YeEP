package com.yeep.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Abstract Base Entity สำหรับ Entity ทั้งหมดในระบบ
 * ใช้หลักการ Inheritance เพื่อลดการซ้ำซ้อนของ code
 * 
 * ทุก Entity ที่สืบทอดจะมี:
 * - id: Primary Key
 * - createdAt: วันที่สร้าง
 * - updatedAt: วันที่อัพเดทล่าสุด
 */
@MappedSuperclass
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    protected Long id;

    @Column(name = "created_at", updatable = false)
    protected LocalDateTime createdAt;

    @Column(name = "updated_at")
    protected LocalDateTime updatedAt;

    // ==================== LIFECYCLE CALLBACKS ====================

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // ==================== GETTERS AND SETTERS ====================

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    // ==================== COMMON METHODS ====================

    /**
     * ตรวจสอบว่า Entity นี้เป็น Entity ใหม่หรือไม่
     */
    public boolean isNew() {
        return id == null;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;
        BaseEntity that = (BaseEntity) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
