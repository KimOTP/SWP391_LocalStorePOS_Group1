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
    @Column(name = "promoDetailId")
    private Long promoDetailId;

    // FK tới Promotion
    @ManyToOne
    @JoinColumn(name = "promotionId", nullable = false)
    private Promotion promotion;

    // FK tới Product (Lưu ý: product_id trong script là VARCHAR)
    @ManyToOne
    @JoinColumn(name = "productId", nullable = false)
    private Product product;

    @Column(name = "minQuantity", nullable = false)
    private Integer minQuantity = 1;

    @Column(name = "discountValue", nullable = false)
    private BigDecimal discountValue;

    @Enumerated(EnumType.STRING)
    @Column(name = "discountType", length = 20, nullable = false)
    private DiscountType discountType;

    public enum DiscountType {
        PERCENT,
        AMOUNT
    }
}