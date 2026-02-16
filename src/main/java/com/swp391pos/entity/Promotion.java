package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import org.springframework.format.annotation.DateTimeFormat;
@Entity
@Data
@Table(name = "Promotion")
public class Promotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "promotionId")
    private Integer promotionId;

    @Column(name = "promoName", nullable = false)
    private String promoName;

    @Column(name = "startDate", nullable = false)
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    @Column(name = "endDate", nullable = false)
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    // DEFAULT 'ACTIVE'
    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20, nullable = false)
    private PromotionStatus status = PromotionStatus.ACTIVE;

    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum PromotionStatus {
        ACTIVE,
        INACTIVE,
        EXPIRED
    }
}