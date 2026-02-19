package com.swp391pos.service;

import com.swp391pos.entity.PromotionDetail;
import com.swp391pos.repository.PromotionDetailRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PromotionDetailService {
    @Autowired
    private PromotionDetailRepository promotionDetailRepository;

    public List<PromotionDetail> searchDetails(Integer promotionId, String keyword, String productName, String discountTypeStr) {
        String pName = (productName != null && !productName.isEmpty()) ? productName : null;

        PromotionDetail.DiscountType discountType = null;
        if (discountTypeStr != null && !discountTypeStr.isEmpty()) {
            try {
                discountType = PromotionDetail.DiscountType.valueOf(discountTypeStr);
            } catch (IllegalArgumentException e) {}
        }

        return promotionDetailRepository.searchDetails(promotionId, keyword, pName, discountType);
    }

    public List<String> getProductNamesInPromotion(Integer promotionId) {
        return promotionDetailRepository.findDistinctProductNamesByPromotionId(promotionId);
    }
}
