package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "[Order]")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ordeId")
    private Long orderId;

    // FK -> Employee(employee_id)
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "cashierId",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_Order_Employee")
    )
    private Employee employee;

    // FK -> Customer(customer_id)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "customerId",
            foreignKey = @ForeignKey(name = "FK_Order_Customer")
    )
    private Customer customer;

    // FK -> OrderStatus(order_status_id)
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "orderStatusId",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_Order_OrderStatus")
    )
    private OrderStatus orderStatus;

    @Column(name = "totalAmount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "discountAmount", precision = 15, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "paymentMethod", length = 20)
    private PaymentMethod paymentMethod;

    @Column(name = "createdAt", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "cancelledAt")
    private LocalDateTime cancelledAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.discountAmount == null) {
            this.discountAmount = BigDecimal.ZERO;
        }
    }
    public enum PaymentMethod {
        CASH,
        ONLINE
    }
}