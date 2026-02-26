package com.swp391pos.repository;

import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {

    // Lấy tất cả Order theo trạng thái.
    List<Order> findByOrderStatus(OrderStatus status);

    // Lấy Order theo khoảng thời gian tạo (dùng cho báo cáo doanh thu).
    List<Order> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);
}