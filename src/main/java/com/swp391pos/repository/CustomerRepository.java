package com.swp391pos.repository;

import com.swp391pos.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    @Query("SELECT SUM(c.currentPoint) From Customer c")
    Long sumTotalPoints();
    @Query("SELECT SUM(c.totalSpending) FROM Customer c")
    BigDecimal sumTotalSpending();
    @Query("SELECT c FROM Customer c WHERE " +
            "(:keyword IS NULL OR :keyword = '' OR c.fullName LIKE %:keyword% OR c.phoneNumber LIKE %:keyword%) " +
            "AND (:minPoint IS NULL OR c.currentPoint >= :minPoint) " +
            "AND (:status IS NULL OR c.status = :status) " +
            "AND (:startDate IS NULL OR c.lastTransactionDate >= :startDate)") // Lọc từ ngày này trở đi
    List<Customer> searchFullFilter(@Param("keyword") String keyword,
                                    @Param("minPoint") Integer minPoint,
                                    @Param("status") Integer status,
                                    @Param("startDate") LocalDateTime startDate);
}