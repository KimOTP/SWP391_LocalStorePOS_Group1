package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalTime;

@Entity
@Data
@Table(name = "WorkShift")
public class WorkShift {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer shiftId;
    @Column(nullable = false, length = 50)
    private String shiftName;
    private LocalTime startTime;
    private LocalTime endTime;
}
