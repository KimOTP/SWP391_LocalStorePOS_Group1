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
    @Column(name = "paymentId")
    private Long paymentId;

    // FK -> Order
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "orderId",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_Payment_Order")
    )
    private Order order;

    @Enumerated(EnumType.STRING)
    @Column(name = "paymentMethod", nullable = false, length = 20)
    private PaymentMethod paymentMethod;

    @Enumerated(EnumType.STRING)
    @Column(name = "paymentStatus", nullable = false, length = 20)
    private PaymentStatus paymentStatus;

    @Column(name = "gatewayReference", length = 254)
    private String gatewayReference;

    @Column(name = "amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(name = "createdAt", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public enum PaymentMethod {
        CASH,
        ONLINE
    }

    public enum PaymentStatus {
        PENDING,
        SUCCESS,
        FAIL,
        TIMEOUT
    }

}
