package com.swp391pos.controller.customer;


import com.swp391pos.entity.Promotion;
import com.swp391pos.service.PromotionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/promotions")
public class PromotionController {
    @Autowired
    private PromotionService promotionService;
    @GetMapping
    public String listPromotions(Model model,
                                 @RequestParam(required = false) String keyword,
                                 @RequestParam(required = false) String status,
                                 // Nhận 2 ngày riêng biệt
                                 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,
                                 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate) {

        // Gọi Service
        List<Promotion> promotions = promotionService.getPromotions(keyword, status, fromDate, toDate);
        model.addAttribute("promotions", promotions);

        // Giữ lại giá trị trên form để người dùng biết mình đang lọc cái gì
        model.addAttribute("keyword", keyword);
        model.addAttribute("status", status);
        model.addAttribute("fromDate", fromDate);
        model.addAttribute("toDate", toDate);

        // Stats (Giữ nguyên)
        model.addAttribute("totalPromotions", promotionService.getTotalPromotions());
        model.addAttribute("activeCount", promotionService.countByStatus("ACTIVE"));
        model.addAttribute("inactiveCount", promotionService.countByStatus("INACTIVE"));
        model.addAttribute("expiredCount", promotionService.countByStatus("EXPIRED"));

        return "promotion/promotion-list";
    }
}
