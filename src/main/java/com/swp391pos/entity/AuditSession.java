package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@Table(name = "AuditSession")
public class AuditSession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer auditId;
    @ManyToOne
    @JoinColumn(name = "staffId")
    private Employee staff;
    @ManyToOne
    @JoinColumn(name = "approverId")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "transactionStatusId")
    private TransactionStatus status;
    @OneToMany(mappedBy = "auditSession", fetch = FetchType.EAGER)
    private List<AuditDetail> details;
    private LocalDateTime auditDate;
}
