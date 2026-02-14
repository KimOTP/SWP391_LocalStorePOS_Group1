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

        // 1. Xử lý Status (Giữ nguyên)
        PromotionStatus statusEnum = null;
        if (statusStr != null && !statusStr.isEmpty()) {
            try {
                statusEnum = PromotionStatus.valueOf(statusStr);
            } catch (IllegalArgumentException e) {}
        }

        // 2. Xử lý Ngày (Convert LocalDate -> LocalDateTime)
        LocalDateTime startDateTime = null;
        LocalDateTime endDateTime = null;

        if (fromDate != null) {
            // Ngày bắt đầu: Lấy từ 00:00:00
            startDateTime = fromDate.atStartOfDay();
        }

        if (toDate != null) {
            // Ngày kết thúc: Lấy đến 23:59:59 của ngày đó
            endDateTime = toDate.atTime(23, 59, 59);
        }

        return promotionRepository.searchPromotions(keyword, statusEnum, startDateTime, endDateTime);
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

}
