package com.swp391pos.repository;

import com.swp391pos.entity.PosReceipt;
import com.swp391pos.enums.OrderStatusName;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PosReceiptRepository extends JpaRepository<PosReceipt, Long> {

    /* Fetch all – eagerly load relations to avoid LazyInitializationException */
    @Query("""
            SELECT r FROM PosReceipt r
            JOIN FETCH r.order o
            JOIN FETCH o.employee
            JOIN FETCH o.orderStatus
            JOIN FETCH r.printedBy
            LEFT JOIN FETCH o.customer
            ORDER BY r.printedAt DESC
            """)
    List<PosReceipt> findAllWithDetails();

    /* Find single receipt by receiptNumber – also fetch orderItems if mapped */
    @Query("""
            SELECT r FROM PosReceipt r
            JOIN FETCH r.order o
            JOIN FETCH o.employee
            JOIN FETCH o.orderStatus
            JOIN FETCH r.printedBy
            LEFT JOIN FETCH o.customer
            WHERE r.receiptNumber = :receiptNumber
            """)
    Optional<PosReceipt> findByReceiptNumber(@Param("receiptNumber") String receiptNumber);

    /* Count by OrderStatus.orderStatusName (enum OrderStatusName) */
    @Query("SELECT COUNT(r) FROM PosReceipt r WHERE r.order.orderStatus.orderStatusName = :statusName")
    long countByOrderStatusName(@Param("statusName") OrderStatusName statusName);

    /* Count printed today */
    long countByPrintedAtBetween(LocalDateTime start, LocalDateTime end);

    /* Sum revenue for a given order status */
    @Query("SELECT SUM(r.order.totalAmount) FROM PosReceipt r WHERE r.order.orderStatus.orderStatusName = :statusName")
    java.math.BigDecimal sumRevenueByOrderStatusName(@Param("statusName") OrderStatusName statusName);
}