package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "PointHistory")
public class PointHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "historyId")
    private Long historyId;

    // FK tới Customer
    @ManyToOne
    @JoinColumn(name = "customerId", nullable = false)
    private Customer customer;

    // FK tới Order (Có thể NULL)
    @ManyToOne
    @JoinColumn(name = "orderId")
    private Order order;

    @Column(name = "pointAmount", nullable = false)
    private Integer pointAmount;

    @Column(name = "actionType", length = 50, nullable = false)
    private String actionType;

    @Column(name = "description")
    private String description;

    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();
}