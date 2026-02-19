package com.swp391pos.service;


import com.swp391pos.entity.Promotion;
import com.swp391pos.repository.PromotionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.swp391pos.entity.Promotion.PromotionStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class PromotionService {
    @Autowired
    private PromotionRepository promotionRepository;

    public List<Promotion> getAllPromotions() {
        return promotionRepository.findAll();
    }

    // Sửa tham số: Nhận LocalDate thay vì timePeriod String
    public List<Promotion> getPromotions(String keyword, String statusStr, LocalDate fromDate, LocalDate toDate) {

        // Xử lý Status
        PromotionStatus statusEnum = null;
        if (statusStr != null && !statusStr.isEmpty()) {
            try {
                statusEnum = PromotionStatus.valueOf(statusStr);
            } catch (IllegalArgumentException e) {}
        }

        // Gọi Repository
        return promotionRepository.searchPromotions(keyword, statusEnum, fromDate, toDate);
    }

    public long getTotalPromotions() {
        return promotionRepository.count();
    }
    public long countByStatus(String status) {
        try {
            return promotionRepository.countByStatus(PromotionStatus.valueOf(status));
        } catch (Exception e) {
            return 0; // Trả 0 nếu sai
        }

    }

    // Hàm thêm mới hoặc cập nhật
    public void savePromotion(Promotion promotion) {
        // Kiểm tra nếu là Update (có ID) -> giữ lại createdAt cũ
        if (promotion.getPromotionId() != null) {
            Promotion oldPromo = promotionRepository.findById(promotion.getPromotionId()).orElse(null);
            if (oldPromo != null) {
                promotion.setCreatedAt(oldPromo.getCreatedAt());
            }
        }
        // Lưu xuống DB
        promotionRepository.save(promotion);
    }

    public void deletePromotion(Integer id) {
        promotionRepository.deleteById(id);
    }

    public void updateStatus(Integer id, PromotionStatus newStatus) {
        Promotion promotion = promotionRepository.findById(id).orElse(null);
        if(promotion!=null) {
            promotion.setStatus(newStatus);
            promotionRepository.save(promotion);
        }
    }

    public Promotion getPromotionById(Integer id) {
        return promotionRepository.findById(id).orElse(null);
    }
}
