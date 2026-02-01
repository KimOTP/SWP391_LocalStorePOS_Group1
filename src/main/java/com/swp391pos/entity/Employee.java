package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "Employee")
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer employeeId;
    @Column(nullable = false, length = 100)
    private String fullName;
    @Column(unique = true, length = 100)
    private String email;
    @Column(nullable = false, length = 20)
    private String role;
    private Boolean status = true;
    private LocalDateTime createdAt = LocalDateTime.now();
}
