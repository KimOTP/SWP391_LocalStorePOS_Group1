package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "InvLogDetail")
public class InvLogDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long logDetailId;
    @ManyToOne
    @JoinColumn(name = "log_header_id")
    private InvLogHeader header;
    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;
    private Integer oldQuantity;
    private Integer newQuantity;
}
