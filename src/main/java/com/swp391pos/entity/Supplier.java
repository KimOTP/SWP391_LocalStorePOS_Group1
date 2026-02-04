package com.swp391pos.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "Supplier")
public class Supplier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer supplierId;
    private String supplierName;
    private String contactNumber;
    private String email;
}
