package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "AuditDetail")
public class AuditDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long auditDetailId;

    @ManyToOne
    @JoinColumn(name = "audit_id", nullable = false)
    private AuditSession auditSession;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private Integer expectedQuantity; // Số lượng trên hệ thống

    @Column(nullable = false)
    private Integer actualQuantity;   // Số lượng kiểm kê thực tế

    private String discrepancyReason; // Lý do sai lệch (nếu có)
}
