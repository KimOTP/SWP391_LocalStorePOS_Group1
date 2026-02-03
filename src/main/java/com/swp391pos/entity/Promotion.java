package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

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
    private LocalDateTime startDate;

    @Column(name = "endDate", nullable = false)
    private LocalDateTime endDate;

    // DEFAULT 'ACTIVE'
    @Column(name = "status", length = 20)
    private String status = "ACTIVE";

    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();
}