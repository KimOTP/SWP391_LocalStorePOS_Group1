package entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "Customer")
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long customerId;
    private String phoneNumber;
    private String fullName;
    private Integer currentPoint;
    private BigDecimal totalSpending;
}
