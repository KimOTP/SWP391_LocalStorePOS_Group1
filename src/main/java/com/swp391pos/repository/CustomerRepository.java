package com.swp391pos.repository;

import com.swp391pos.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    @Query("SELECT SUM(c.currentPoint) From Customer c")
    Long sumTotalPoints();
    @Query("SELECT SUM(c.totalSpending) FROM Customer c")
    BigDecimal sumTotalSpending();
    @Query("Select c from Customer c where c.fullName like %:keyword% or c.phoneNumber like %:keyword%")
    List<Customer> searchByNameOrPhone(@Param("keyword") String keyword);
}