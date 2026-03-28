package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

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
    @OneToMany(mappedBy = "stockOut", fetch = FetchType.EAGER)
    private List<StockOutDetail> details;
    private String generalReason;
    private LocalDateTime createdAt;
}
