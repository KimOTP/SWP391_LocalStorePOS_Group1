package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@Table(name = "StockIn")
public class StockIn {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer stockInId;
    @ManyToOne
    @JoinColumn(name = "supplierId")
    private Supplier supplier;
    @ManyToOne
    @JoinColumn(name = "requesterId")
    private Employee requester;
    @ManyToOne
    @JoinColumn(name = "staffId")
    private Employee staff;
    @ManyToOne
    @JoinColumn(name = "approverId")
    private Employee approver;
    @ManyToOne
    @JoinColumn(name = "transactionStatusId")
    private TransactionStatus status;
    @OneToMany(mappedBy = "stockIn", fetch = FetchType.EAGER)
    private List<StockInDetail> details;
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime receivedAt;

}
