package com.swp391pos.repository;

import com.swp391pos.entity.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import com.swp391pos.entity.Promotion.PromotionStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PromotionRepository extends JpaRepository<Promotion, Integer> {

    @Query("SELECT p FROM Promotion p WHERE p.status != 'DELETED' " +
            "AND(:keyword IS NULL OR p.promoName LIKE %:keyword% OR CAST(p.promotionId AS string) LIKE %:keyword%) " +
            "AND (:status IS NULL OR p.status = :status) " +
            "AND (:fromDate IS NULL OR p.startDate >= :fromDate) " +
            "AND (:toDate IS NULL OR p.startDate <= :toDate)") // Lọc trong khoảng ngày bắt đầu
    List<Promotion> searchPromotions(@Param("keyword") String keyword,
                                     @Param("status") PromotionStatus status,
                                     @Param("fromDate") LocalDate fromDate,
                                     @Param("toDate") LocalDate toDate);

    long countByStatus(PromotionStatus status);
    long countByStatusNot(PromotionStatus status); //đếm số promo chưa bị deleted
}