package com.swp391pos.repository;

import com.swp391pos.entity.OrderPromotion;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderPromotionRepository extends JpaRepository<OrderPromotion, Long> {
}