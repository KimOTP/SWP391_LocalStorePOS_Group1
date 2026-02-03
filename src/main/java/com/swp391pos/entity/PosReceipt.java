package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@Table(
        name = "PosReceipt",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "UK_PosReceipt_ReceiptNumber",
                        columnNames = "receipt_number"
                )
        }
)
public class PosReceipt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "receipt_id")
    private Long receiptId;

    // FK -> Order
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "order_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_PosReceipt_Order")
    )
    private Order order;

    @Column(name = "receipt_number", nullable = false, length = 50, unique = true)
    private String receiptNumber;

    @Column(name = "printed_at")
    private LocalDateTime printedAt;

    // FK -> Employee
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "printed_by",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_PosReceipt_Employee")
    )
    private Employee printedBy;

}
