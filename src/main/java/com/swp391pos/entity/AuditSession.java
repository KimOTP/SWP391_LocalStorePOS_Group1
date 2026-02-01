package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "AuditSession")
public class AuditSession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer auditId;
    @ManyToOne
    @JoinColumn(name = "staff_id")
    private Employee staff;
    @ManyToOne
    @JoinColumn(name = "approver_id")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "transaction_status_id")
    private TransactionStatus status;
    private LocalDateTime auditDate;
}
