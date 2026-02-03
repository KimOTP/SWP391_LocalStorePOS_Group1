package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "Payment")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long paymentId;
    @OneToOne
    @JoinColumn(name = "orderId")
    private Order orderId;
    private String paymentMethod;
    private BigDecimal amount;
    private String transactionStatus;
    private String gateWayReference;
    private LocalDateTime createdDate;
}
