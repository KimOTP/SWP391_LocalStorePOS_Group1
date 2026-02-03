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
    @Column(name = "employeeId")
    private Integer employeeId;

    @Column(name = "fullName", nullable = false, length = 100)
    private String fullName;

    @Column(name = "email", unique = true, length = 100)
    private String email;

    @Column(name = "role", nullable = false, length = 20)
    private String role;

    @Column(name = "status", nullable = false)
    private Boolean status = true;

    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();
}
