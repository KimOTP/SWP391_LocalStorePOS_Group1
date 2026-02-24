package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "InvLogHeader")
public class InvLogHeader {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long logHeaderId;
    @ManyToOne
    @JoinColumn(name = "actionTypeId")
    private ActionType actionType;
    @ManyToOne
    @JoinColumn(name = "staffId")
    private Employee staff;
    @ManyToOne
    @JoinColumn(name = "approverId")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "stockInId")
    private StockIn stockInId;
    @ManyToOne
    @JoinColumn(name = "StockOutId")
    private StockOut stockOutId;
    @ManyToOne
    @JoinColumn(name = "auditSessionId")
    private AuditSession auditSessionId;
    private LocalDateTime createdAt = LocalDateTime.now();
}
