package com.swp391pos.repository;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    // Lấy tất cả Payment của một Order.
    List<Payment> findByOrder(Order order);
}