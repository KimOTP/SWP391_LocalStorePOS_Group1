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
    @JoinColumn(name = "requesterId")
    private Employee requester;
    @ManyToOne
    @JoinColumn(name = "approverId")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "transactionStatusId")
    private TransactionStatus status;
    private String generalReason;
    private LocalDateTime createdAt;
}
