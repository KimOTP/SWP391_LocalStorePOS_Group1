package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
@Table(
        name = "PosReceipt",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "UK_PosReceipt_ReceiptNumber",
                        columnNames = "receiptNumber"
                )
        }
)
public class PosReceipt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "receiptId")
    private Long receiptId;

    // FK -> Order
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "orderId",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_PosReceipt_Order")
    )
    private Order order;

    @Column(name = "receiptNumber", nullable = false, length = 50, unique = true)
    private String receiptNumber;

    @Column(name = "printedAt")
    private LocalDateTime printedAt;

    // FK -> Employee
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "printedBy",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_PosReceipt_Employee")
    )
    private Employee printedBy;

}
