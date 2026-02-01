package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "InvLogHeader")
public class InvLogHeader {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long logHeaderId;
    @ManyToOne
    @JoinColumn(name = "action_type_id")
    private ActionType actionType;
    @ManyToOne
    @JoinColumn(name = "staff_id")
    private Employee staff;
    @ManyToOne
    @JoinColumn(name = "approver_id")
    private Employee approver;
    private LocalDateTime createdAt;
}
