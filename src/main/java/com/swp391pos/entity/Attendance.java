package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "Attendance")
public class Attendance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attendanceId")
    private Integer attendanceId;

    @ManyToOne
    @JoinColumn(name = "employeeId", nullable = false)
    private Employee employee;

    @ManyToOne
    @JoinColumn(name = "shiftId", nullable = false)
    private WorkShift shift;

    @Column(name = "workDate", nullable = false)
    private LocalDate workDate;

    @Column(name = "checkInTime")
    private LocalDateTime checkInTime;

    @Column(name = "checkOutTime")
    private LocalDateTime checkOutTime;

    @Column(name = "isLate")
    private Boolean isLate;

    @Column(name = "isEarlyLeave")
    private Boolean isEarlyLeave;

    @Column(name = "violationNote")
    private String violationNote;

    @Column(name = "autoCheckout")
    private Boolean autoCheckout;
}
