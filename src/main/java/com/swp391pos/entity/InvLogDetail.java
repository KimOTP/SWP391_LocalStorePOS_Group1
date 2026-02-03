package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "InvLogDetail")
public class InvLogDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long logDetailId;
    @ManyToOne
    @JoinColumn(name = "logHeaderId")
    private InvLogHeader header;
    @ManyToOne
    @JoinColumn(name = "productId")
    private Product product;
    private Integer oldQuantity;
    private Integer newQuantity;
    private BigDecimal unitCost;
}
