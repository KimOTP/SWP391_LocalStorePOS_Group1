package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "StockIn")
public class StockIn {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer stockInId;
    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;
    @ManyToOne
    @JoinColumn(name = "requester_id")
    private Employee requester;
    @ManyToOne
    @JoinColumn(name = "staff_id")
    private Employee staff;
    @ManyToOne
    @JoinColumn(name = "approver_id")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "transaction_status_id")
    private TransactionStatus status;
    private LocalDateTime createdAt = LocalDateTime.now();
}
