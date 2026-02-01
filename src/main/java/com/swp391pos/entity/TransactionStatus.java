package com.swp391pos.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "TransactionStatus")
public class TransactionStatus {
    @Id
    private Integer transactionStatusId;
    private String transactionStatusName;
    private String description;
}