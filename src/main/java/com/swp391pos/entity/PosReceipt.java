package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "PosReceipt")
public class PosReceipt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long receiptId;
    @OneToOne
    @JoinColumn(name = "order_id")
    private Order order;
    private String receiptData;
}
