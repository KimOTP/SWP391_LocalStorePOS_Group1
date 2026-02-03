package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "OrderStatus")
public class OrderStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "orderStatusId")
    private Integer orderStatusId;

    @Enumerated(EnumType.STRING)
    @Column(name = "orderStatusName", nullable = false, length = 30)
    private OrderStatusName orderStatusName;

    public enum OrderStatusName {
        DRAFT,
        PENDING_PAYMENT,
        PAID,
        CANCELLED
    }

}
