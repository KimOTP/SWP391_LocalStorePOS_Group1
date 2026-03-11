package com.swp391pos.repository;

import com.swp391pos.entity.OrderStatus;
import com.swp391pos.enums.OrderStatusName;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OrderStatusRepository extends JpaRepository<OrderStatus, Integer> {
    // lấy order status by name
    Optional<OrderStatus> findByOrderStatusName(OrderStatusName statusName);


}