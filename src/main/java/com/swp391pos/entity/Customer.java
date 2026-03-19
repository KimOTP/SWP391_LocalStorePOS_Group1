package com.swp391pos.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
@Entity
@Data
@Table(name = "Customer")
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customerId")
    private Long customerId;

    @Column(name = "phoneNumber", length = 15, nullable = false, unique = true)
    @NotBlank(message = "The phone number must not be left blank.")
    @Pattern(regexp = "0\\d{9}", message = "Phone must be numeric or 10 digits")
    private String phoneNumber;

    @Column(name = "fullName", length = 100, nullable = false)
    @NotBlank(message = "Customer name cannot be left blank.")
    @Size(min = 2, max = 50, message = "Names must be between 2 and 50 characters long.")
    private String fullName;

    // DEFAULT 0 trong SQL -> Gán = 0 trong Java
    @Column(name = "currentPoint")
    private Integer currentPoint = 0;

    // DEFAULT 0 trong SQL
    @Column(name = "totalSpending")
    private BigDecimal totalSpending = BigDecimal.ZERO;

    @Column(name = "lastTransactionDate")
    private LocalDateTime lastTransactionDate;

    // DEFAULT 1 (Active)
    @Column(name = "status")
    private Integer status = 1;

    // DEFAULT GETDATE() -> Gán thời gian hiện tại khi tạo mới
    @Column(name = "createdAt")
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "customer", fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"}) // Giúp tránh lỗi Lazy Loading khi convert JSON
    @OrderBy("createdAt DESC") // Nhằm ưu tiên mới thì ở trên cùng transaction history
    private List<PointHistory> pointHistories;

    @OneToMany(mappedBy = "customer", fetch = FetchType.LAZY)
    @JsonIgnore // Chặn JSON để tránh lặp vào vòng luẩn quẩn
    private List<Order> orders;
}