package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "OrderItem")
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long orderItemId;
    @ManyToOne
    @JoinColumn(name = "orderId")
    private Order orderId;
    @ManyToOne
    @JoinColumn(name = "productId")
    private Product productId;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal subTotal;
}
