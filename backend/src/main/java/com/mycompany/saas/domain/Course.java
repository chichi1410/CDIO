package com.mycompany.saas.domain;

import java.math.BigDecimal;
import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "khoa_hoc")
@Getter
@Setter
@NoArgsConstructor
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_giang_vien", nullable = false)
    private User instructor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_danh_muc", nullable = false)
    private Category category;

    @Column(name = "tieu_de", nullable = false, length = 255)
    private String title;

    @Column(name = "duong_dan", nullable = false, unique = true, length = 300)
    private String slug;

    @Column(name = "tieu_de_phu", length = 500)
    private String subtitle;

    @Column(name = "mo_ta_chi_tiet", columnDefinition = "LONGTEXT")
    private String description;

    @Column(name = "anh_dai_dien", length = 500)
    private String thumbnailUrl;

    @Column(name = "video_gioi_thieu", length = 500)
    private String introVideoUrl;

    @Column(name = "gia_goc", nullable = false, precision = 12, scale = 2)
    private BigDecimal originalPrice = BigDecimal.ZERO;

    @Column(name = "gia_khuyen_mai", precision = 12, scale = 2)
    private BigDecimal salePrice = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "trinh_do", nullable = false)
    private CourseLevel level = CourseLevel.TAT_CA;

    @Column(name = "ngon_ngu", nullable = false, length = 50)
    private String language = "Tiếng Việt";

    @Enumerated(EnumType.STRING)
    @Column(name = "trang_thai", nullable = false)
    private CourseStatus status = CourseStatus.BAN_NHAP;

    @Column(name = "ly_do_tu_choi", columnDefinition = "TEXT")
    private String rejectReason;

    @Column(name = "tong_thoi_luong_giay", nullable = false)
    private Integer totalDurationSeconds = 0;

    @Column(name = "tong_so_bai_hoc", nullable = false)
    private Integer totalLessons = 0;

    @Column(name = "ngay_tao", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "ngay_cap_nhat", nullable = false)
    private Instant updatedAt;

    @PrePersist
    public void prePersist() {
        Instant now = Instant.now();
        if (createdAt == null) {
            createdAt = now;
        }
        updatedAt = now;
        if (status == null) {
            status = CourseStatus.BAN_NHAP;
        }
        if (originalPrice == null) {
            originalPrice = BigDecimal.ZERO;
        }
        if (level == null) {
            level = CourseLevel.TAT_CA;
        }
        if (language == null) {
            language = "Tiếng Việt";
        }
        if (totalDurationSeconds == null) {
            totalDurationSeconds = 0;
        }
        if (totalLessons == null) {
            totalLessons = 0;
        }
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = Instant.now();
    }
}
