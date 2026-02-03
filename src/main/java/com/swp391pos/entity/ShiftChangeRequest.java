package com.swp391pos.entity;


import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "ShiftChangeRequest")
public class ShiftChangeRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "requestId")
    private Integer requestId;

    @ManyToOne
    @JoinColumn(name = "employeeId", nullable = false)
    private Employee employee;

    @ManyToOne
    @JoinColumn(name = "managerId")
    private Employee manager;

    @Column(name = "workDate", nullable = false)
    private LocalDate workDate;

    @ManyToOne
    @JoinColumn(name = "currentShiftId", nullable = false)
    private WorkShift currentShift;

    @ManyToOne
    @JoinColumn(name = "requestedShiftId", nullable = false)
    private WorkShift requestedShift;

    @Column(name = "reason", columnDefinition = "VARCHAR(255)")
    private String reason;

    @Column(name = "status", nullable = false)
    private String status = "Pending";

    @Column(name = "reviewedAt")
    private LocalDateTime reviewedAt;
}
