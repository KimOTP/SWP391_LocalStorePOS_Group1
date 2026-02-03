package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Entity
@Data
@Table(name = "PosReceipt")
public class PosReceipt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long receiptId;
    @OneToOne
    @JoinColumn(name = "orderId")
    private Order orderId;
    private String receiptData;
    private LocalDate printTime;
    private int printBy;
}
