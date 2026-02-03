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
    @Column(name = "orderPromotionId")
    private Long orderPromotionId;

    // FK -> Order
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "orderId",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_OrderPromotion_Order")
    )
    private Order order;

    // FK -> Promotion
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "promotionId",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_OrderPromotion_Promotion")
    )
    private Promotion promotion;

    @Column(name = "discountAmount", nullable = false, precision = 15, scale = 2)
    private BigDecimal discountAmount;
}
