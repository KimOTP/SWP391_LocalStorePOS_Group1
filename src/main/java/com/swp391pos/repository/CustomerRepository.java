package com.swp391pos.repository;

import com.swp391pos.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    @Query("SELECT SUM(c.currentPoint) From Customer c")
    Long sumTotalPoints();
    @Query("SELECT SUM(c.totalSpending) FROM Customer c")
    BigDecimal sumTotalSpending();
}