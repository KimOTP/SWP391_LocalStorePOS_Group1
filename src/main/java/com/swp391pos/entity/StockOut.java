package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "StockOut")
public class StockOut {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer stockOutId;
    @ManyToOne
    @JoinColumn(name = "requester_id")
    private Employee requester;
    @ManyToOne
    @JoinColumn(name = "approver_id")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "transaction_status_id")
    private TransactionStatus status;
    private LocalDateTime createdAt;
}
