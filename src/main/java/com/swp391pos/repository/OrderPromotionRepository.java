package com.swp391pos.repository;

import com.swp391pos.entity.OrderPromotion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderPromotionRepository extends JpaRepository<OrderPromotion, Long> {
    List<OrderPromotion> findByOrder_OrderId(Long orderId);
}