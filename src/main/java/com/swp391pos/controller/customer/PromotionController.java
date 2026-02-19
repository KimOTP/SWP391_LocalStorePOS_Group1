package com.swp391pos.controller.customer;


import com.swp391pos.entity.Promotion;
import com.swp391pos.entity.PromotionDetail;
import com.swp391pos.service.PromotionService;
import com.swp391pos.service.PromotionDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.swp391pos.entity.Promotion.PromotionStatus;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/promotions")
public class PromotionController {
    @Autowired
    private PromotionService promotionService;
    @Autowired
    private PromotionDetailService promotionDetailService;
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

    @PostMapping("/add")
    public String addPromotion(@ModelAttribute Promotion promotion, RedirectAttributes redirectAttributes) {
        try {
            promotionService.savePromotion(promotion);
            redirectAttributes.addFlashAttribute("success", "Add promotion successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Failed to add promotion.");
        }
        return "redirect:/promotions";
    }

    @PostMapping("/update")
    public String updatePromotion(@ModelAttribute Promotion promotion, RedirectAttributes redirectAttributes) {
        try {
            promotionService.savePromotion(promotion);
            redirectAttributes.addFlashAttribute("success", "Update promotion successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Failed to update promotion.");
        }
        return "redirect:/promotions";
    }

    @GetMapping("/delete")
    public String deletePromotion(@RequestParam Integer id, RedirectAttributes redirectAttributes) {
        try {
            promotionService.deletePromotion(id);
            redirectAttributes.addFlashAttribute("success", "Deleted promotion successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to delete promotion.");
        }
        return "redirect:/promotions";
    }

    @GetMapping("/status")
    public String updatePromotionStatus(@RequestParam Integer id,
                                        @RequestParam String status,
                                        RedirectAttributes redirectAttributes) {
        try {
            // Convert String -> Enum
            PromotionStatus newStatus = PromotionStatus.valueOf(status);
            promotionService.updateStatus(id, newStatus);
            String msg = (newStatus == PromotionStatus.ACTIVE) ? "Activated promotion!" : "Inactivated promotion!";
            redirectAttributes.addFlashAttribute("success", msg);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to update status.");
        }
        return "redirect:/promotions";
    }

    @GetMapping("/detail")
    public String viewPromotionDetail(@RequestParam Integer id,
                                      @RequestParam(required = false) String keyword,
                                      @RequestParam(required = false) String productName, // Đổi tham số
                                      @RequestParam(required = false) String discountType,
                                      Model model) {

        Promotion promotion = promotionService.getPromotionById(id);
        List<PromotionDetail> details = promotionDetailService.searchDetails(id, keyword, productName, discountType);

        List<String> productNamesList = promotionDetailService.getProductNamesInPromotion(id);
        model.addAttribute("productNamesList", productNamesList);

        model.addAttribute("promotion", promotion);
        model.addAttribute("details", details);

        model.addAttribute("keyword", keyword);
        model.addAttribute("productName", productName); // Trả về lại JSP
        model.addAttribute("discountType", discountType);

        return "promotion/promotion-detail";
    }
}
