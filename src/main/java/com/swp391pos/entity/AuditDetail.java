package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "AuditDetail")
public class AuditDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long auditDetailId;

    @ManyToOne
    @JoinColumn(name = "auditId", nullable = false)
    private AuditSession auditSession;

    @ManyToOne
    @JoinColumn(name = "productId", nullable = false)
    private Product product;

    @Column(nullable = false)
    private Integer expectedQuantity; // Số lượng trên hệ thống

    @Column(nullable = false)
    private Integer actualQuantity;   // Số lượng kiểm kê thực tế

    private String discrepancyReason; // Lý do sai lệch (nếu có)

    private BigDecimal unitCostAtAudit;
}