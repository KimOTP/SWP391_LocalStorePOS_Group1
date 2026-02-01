package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Data
@Table(name = "Product")
public class Product {
    @Id
    @Column(length = 50)
    private String productId;
    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;
    @ManyToOne
    @JoinColumn(name = "product_status_id")
    private ProductStatus status;
    private String productName;
    private String unit;
    private BigDecimal price;
    private String imageUrl;
    @Column(columnDefinition = "VARCHAR(255)")
    private String attribute;
}