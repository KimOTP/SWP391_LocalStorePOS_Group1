package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "ProductStatus")
public class ProductStatus {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer productStatusId;
    private String productStatusName;
}
