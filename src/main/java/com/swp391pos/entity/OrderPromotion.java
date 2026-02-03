package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "OrderPromotion")
public class OrderPromotion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long orderPromoId;
    @ManyToOne
    @JoinColumn(name = "orderId")
    private Order orderId;
    @ManyToOne
    @JoinColumn(name = "promotionId")
    private Promotion promotionId;
    private BigDecimal appliedValue;
}
