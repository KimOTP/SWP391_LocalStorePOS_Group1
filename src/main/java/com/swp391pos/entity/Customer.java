package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "Customer")
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customerId")
    private Long customerId;

    @Column(name = "phoneNumber", length = 15, nullable = false, unique = true)
    private String phoneNumber;

    @Column(name = "fullName", length = 100, nullable = false)
    private String fullName;

    // DEFAULT 0 trong SQL -> Gán = 0 trong Java
    @Column(name = "currentPoint")
    private Integer currentPoint = 0;

    // DEFAULT 0 trong SQL
    @Column(name = "totalSpending")
    private BigDecimal totalSpending = BigDecimal.ZERO;

    @Column(name = "lastTransactionDate")
    private LocalDateTime lastTransactionDate;

    // DEFAULT 1 (Active)
    @Column(name = "status")
    private Integer status = 1;

    // DEFAULT GETDATE() -> Gán thời gian hiện tại khi tạo mới
    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();
}