package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "Account")
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer accountId;
    @OneToOne
    @JoinColumn(name = "employee_id", unique = true)
    private Employee employee;
    @Column(nullable = false, unique = true, length = 50)
    private String username;
    private String passwordHash;
    private LocalDateTime lastLogin;
}
