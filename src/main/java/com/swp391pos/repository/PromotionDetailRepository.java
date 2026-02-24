package com.swp391pos.repository;

import com.swp391pos.entity.PromotionDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
@Repository
public interface PromotionDetailRepository extends JpaRepository<PromotionDetail, Long> {
    @Query("SELECT pd FROM PromotionDetail pd WHERE pd.promotion.promotionId = :promotionId " +
            "AND (:keyword IS NULL OR pd.product.productName LIKE %:keyword% OR CAST(pd.promoDetailId AS string) LIKE %:keyword%) " +
            "AND (:productName IS NULL OR pd.product.productName = :productName) " + // Đổi thành lọc theo tên
            "AND (:discountType IS NULL OR pd.discountType = :discountType)")
    List<PromotionDetail> searchDetails(@Param("promotionId") Integer promotionId,
                                        @Param("keyword") String keyword,
                                        @Param("productName") String productName, // Đổi tham số
                                        @Param("discountType") PromotionDetail.DiscountType discountType);


    @Query("SELECT DISTINCT pd.product.productName FROM PromotionDetail pd WHERE pd.promotion.promotionId = :promotionId")
    List<String> findDistinctProductNamesByPromotionId(@Param("promotionId") Integer promotionId);

    @Query("SELECT pd FROM PromotionDetail pd WHERE pd.promotion.status = 'ACTIVE' " +
            "AND :today >= pd.promotion.startDate " +
            "AND :today <= pd.promotion.endDate")
    List<PromotionDetail> findAllActivePromotionsForPos(@Param("today") LocalDate today);
}