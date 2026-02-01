package com.swp391pos.entity;


import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "ShiftChangeRequest")
public class ShiftChangeRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer requestId;
    @ManyToOne
    @JoinColumn(name = "requester_id")
    private Employee requester;
    @ManyToOne
    @JoinColumn(name = "approver_id")
    private Employee approver;
    private LocalDateTime requestDate;
    private String status;
}
