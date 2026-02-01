package com.swp391pos.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "OrderStatus")
public class OrderStatus {
    @Id
    private Integer orderStatusId;
    private String orderStatusName;
}
