package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "PromotionDetail")
public class PromotionDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long promoDetailId;
    @ManyToOne
    @JoinColumn(name = "promotion_id")
    private Promotion promotion;
    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;
    private BigDecimal discountValue;
}
