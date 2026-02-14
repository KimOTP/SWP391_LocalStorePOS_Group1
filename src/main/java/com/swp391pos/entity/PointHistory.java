package com.swp391pos.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
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
    @JsonIgnore
    private Customer customer;

    // FK tới Order (Có thể NULL)
    @ManyToOne
    @JoinColumn(name = "orderId")
    private Order order;

    @Column(name = "pointAmount", nullable = false)
    private Integer pointAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "actionType", length = 50, nullable = false)
    private ActionType actionType;
    //Bỏ table description
    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum ActionType {
        EARN,
        USE
    }
}