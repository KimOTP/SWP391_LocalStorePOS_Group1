package com.swp391pos.controller.customer;


import com.swp391pos.entity.Product;
import com.swp391pos.entity.Promotion;
import com.swp391pos.entity.PromotionDetail;
import com.swp391pos.service.ProductService;
import com.swp391pos.service.PromotionService;
import com.swp391pos.service.PromotionDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.swp391pos.entity.Promotion.PromotionStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/promotion")
public class PromotionController {
    @Autowired
    private PromotionService promotionService;
    @Autowired
    private PromotionDetailService promotionDetailService;
    @Autowired
    private ProductService productService;

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
            redirectAttributes.addFlashAttribute("notification", "Add promotion successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to add promotion");
        }
        return "redirect:/promotion";
    }

    @PostMapping("/update")
    public String updatePromotion(@ModelAttribute Promotion promotion, RedirectAttributes redirectAttributes) {
        try {
            promotionService.savePromotion(promotion);
            redirectAttributes.addFlashAttribute("notification", "Update promotion successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to update promotion");
        }
        return "redirect:/promotion";
    }

    @GetMapping("/delete")
    public String deletePromotion(@RequestParam Integer id, RedirectAttributes redirectAttributes) {
        try {
            promotionService.deletePromotion(id);
            redirectAttributes.addFlashAttribute("notification", "Deleted promotion successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to delete promotion");
        }
        return "redirect:/promotion";
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
            redirectAttributes.addFlashAttribute("notification", msg);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to update status");
        }
        return "redirect:/promotion";
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

        //danh sach san pham de hien thi ơ add PromoDetail
        model.addAttribute("allProducts", productService.getAllProducts());

        return "promotion/promotion-detail";
    }

    @PostMapping("/detail/add")
    public String addPromotionDetail(
            @RequestParam Integer promotionId,
            @RequestParam String productId,
            @RequestParam Integer minQuantity,
            @RequestParam BigDecimal discountValue,
            @RequestParam String discountType,
            RedirectAttributes redirectAttributes) {
        try {
            promotionDetailService.addPromotionDetail(promotionId, productId, minQuantity, discountValue, discountType);
            redirectAttributes.addFlashAttribute("notification", "Successfully added a promotional product!");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "Error when adding promotional products");
        }
        return "redirect:/promotion/detail?id=" + promotionId;
    }

    //API EDIT
    @PostMapping("/detail/update")
    public String updatePromotionDetail(
            @RequestParam Long promoDetailId,
            @RequestParam Integer promotionId,
            @RequestParam String productId,
            @RequestParam Integer minQuantity,
            @RequestParam BigDecimal discountValue,
            @RequestParam String discountType,
            RedirectAttributes redirectAttributes) {
        try {
            promotionDetailService.updatePromotionDetail(promoDetailId, promotionId, productId, minQuantity, discountValue, discountType);
            redirectAttributes.addFlashAttribute("notification", "Promotional product update successful!");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "Error when updating promotional products");
        }
        return "redirect:/promotion/detail?id=" + promotionId;
    }

    //API DELETE
    @GetMapping("/detail/delete")
    public String deletePromotionDetail(
            @RequestParam Long detailId,
            @RequestParam Integer promotionId, // Truyền kèm cái này để biết đường redirect về
            RedirectAttributes redirectAttributes) {
        try {
            promotionDetailService.deletePromotionDetail(detailId);
            redirectAttributes.addFlashAttribute("notification", "Product successfully removed from promotion!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Error when deleting a product");
        }
        return "redirect:/promotion/detail?id=" + promotionId;
    }

    @PostMapping("/promotion/{promotionId}/import-details")
    @ResponseBody
    public ResponseEntity<?> importDetails(@PathVariable int promotionId, @RequestParam("file")MultipartFile file) {
        try {
            promotionDetailService.importPromotionDetails(promotionId, file);
            return ResponseEntity.ok(Map.of("success", true, "message", "Import success"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success",false,"message", e.getMessage()));
        }
    }

}
