package com.swp391pos.repository;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderStatus;
import com.swp391pos.enums.PaymentMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    // Filtered queries for reports (ALL statuses — DRAFT, PENDING_PAYMENT, PAID, CANCELLED)
    @Query("SELECT o FROM Order o WHERE o.createdAt BETWEEN :from AND :to")
    List<Order> findByCreatedAtBetweenAndNotCancelled(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    @Query("SELECT o FROM Order o WHERE o.createdAt BETWEEN :from AND :to " +
            "AND o.employee.employeeId = :employeeId")
    List<Order> findByCreatedAtBetweenAndEmployeeAndNotCancelled(@Param("from") LocalDateTime from,
                                                                 @Param("to") LocalDateTime to,
                                                                 @Param("employeeId") Integer employeeId);

    @Query("SELECT o FROM Order o WHERE o.createdAt BETWEEN :from AND :to " +
            "AND o.paymentMethod = :paymentMethod")
    List<Order> findByCreatedAtBetweenAndPaymentMethodAndNotCancelled(@Param("from") LocalDateTime from,
                                                                      @Param("to") LocalDateTime to,
                                                                      @Param("paymentMethod") PaymentMethod paymentMethod);

    // Đếm tổng đơn hàng hôm nay
    @Query("SELECT COUNT(o) FROM Order o WHERE o.createdAt >= :startOfDay AND o.createdAt < :endOfDay")
    long countOrdersToday(@Param("startOfDay") LocalDateTime startOfDay,
                          @Param("endOfDay") LocalDateTime endOfDay);
}