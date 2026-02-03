package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "Inventory")
public class Inventory {
    @Id
    private String productId;
    @OneToOne
    @MapsId
    @JoinColumn(name = "productId")
    private Product product;
    private Integer currentQuantity = 0;
    private BigDecimal unitCost = BigDecimal.ZERO;
    private Integer minThreshold = 10;
}
