package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "StockOutSale")
public class StockOutSale {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long saleStockOutId;
    @ManyToOne
    @JoinColumn(name = "orderId")
    private Order order;
    @ManyToOne
    @JoinColumn(name = "stockOutId")
    private StockOut stockOut;
    private LocalDateTime craeteTime;
}
