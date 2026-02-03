package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "OrderStatus")
public class OrderStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_status_id")
    private Integer orderStatusId;

    @Enumerated(EnumType.STRING)
    @Column(name = "order_status_name", nullable = false, length = 30)
    private OrderStatus orderStatusName;

    public enum OrderStatusName {
        DRAFT,
        PENDING_PAYMENT,
        PAID,
        CANCELLED
    }

}
