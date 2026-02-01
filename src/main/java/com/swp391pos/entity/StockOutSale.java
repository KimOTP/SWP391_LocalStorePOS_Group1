package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "StockOutSale")
public class StockOutSale {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long saleStockOutId;
    @ManyToOne
    @JoinColumn(name = "order_id")
    private Order order;
    @ManyToOne
    @JoinColumn(name = "stock_out_id")
    private StockOut stockOut;
}
