package com.swp391pos.repository;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    // Lấy tất cả Order theo trạng thái.
    List<Order> findByOrderStatus(OrderStatus status);

    // Lấy Order theo khoảng thời gian tạo (dùng cho báo cáo doanh thu).
    List<Order> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);

    // Đếm tổng đơn hàng hôm nay
    @Query("SELECT COUNT(o) FROM Order o WHERE o.createdAt >= :startOfDay AND o.createdAt < :endOfDay")
    long countOrdersToday(@Param("startOfDay") LocalDateTime startOfDay,
                          @Param("endOfDay") LocalDateTime endOfDay);
}