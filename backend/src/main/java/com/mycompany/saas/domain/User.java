package com.mycompany.saas.domain;

import java.time.Instant;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "nguoi_dung")
@Getter
@Setter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "ho_ten", nullable = false)
    private String name;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @JsonIgnore
    @Column(name = "mat_khau", nullable = false)
    private String password;

    @Column(name = "so_dien_thoai")
    private String phone;

    @Column(name = "anh_dai_dien")
    private String avatarUrl;

    @Column(name = "tieu_su")
    private String bio;

    @Enumerated(EnumType.STRING)
    @Column(name = "vai_tro", nullable = false)
    private Role role = Role.ROLE_USER;

    @Column(name = "trang_thai_hoat_dong", nullable = false)
    private boolean active = true;

    @Column(name = "da_xac_thuc_email", nullable = false)
    private boolean emailVerified = false;

    @Column(name = "ngay_tao", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "ngay_cap_nhat")
    private Instant updatedAt;

    @PrePersist
    public void handleBeforeCreate() {
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    public void handleBeforeUpdate() {
        this.updatedAt = Instant.now();
    }
}
