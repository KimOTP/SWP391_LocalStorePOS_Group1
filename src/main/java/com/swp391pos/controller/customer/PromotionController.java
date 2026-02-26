package com.swp391pos.controller.customer;


import com.swp391pos.entity.Product;
import com.swp391pos.entity.Promotion;
import com.swp391pos.entity.PromotionDetail;
import com.swp391pos.service.ProductService;
import com.swp391pos.service.PromotionService;
import com.swp391pos.service.PromotionDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.swp391pos.entity.Promotion.PromotionStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

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
            redirectAttributes.addFlashAttribute("success", "Add promotion successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Failed to add promotion.");
        }
        return "redirect:/promotion";
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
        return "redirect:/promotion";
    }

    @GetMapping("/delete")
    public String deletePromotion(@RequestParam Integer id, RedirectAttributes redirectAttributes) {
        try {
            promotionService.deletePromotion(id);
            redirectAttributes.addFlashAttribute("success", "Deleted promotion successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to delete promotion.");
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
            redirectAttributes.addFlashAttribute("success", msg);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to update status.");
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
            @RequestParam String productId, // Theo comment của bạn, productId là String
            @RequestParam Integer minQuantity,
            @RequestParam BigDecimal discountValue,
            @RequestParam String discountType,
            RedirectAttributes redirectAttributes) {
        try {
            // Tìm Promotion và Product tương ứng
            Promotion promotion = promotionService.getPromotionById(promotionId);
            Product product = productService.getProductById(productId);

            // Tạo đối tượng Detail mới và set giá trị
            PromotionDetail detail = new PromotionDetail();
            detail.setPromotion(promotion);
            detail.setProduct(product);
            detail.setMinQuantity(minQuantity);
            detail.setDiscountValue(discountValue);
            detail.setDiscountType(PromotionDetail.DiscountType.valueOf(discountType));

            // Lưu xuống DB
            promotionDetailService.savePromotionDetail(detail);
            redirectAttributes.addFlashAttribute("success", "Thêm sản phẩm khuyến mãi thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Lỗi khi thêm sản phẩm khuyến mãi.");
        }

        // Trở lại trang detail của chính promotion đó
        return "redirect:/promotion/detail?id=" + promotionId;
    }

    //API EDIT
    @PostMapping("/detail/update")
    public String updatePromotionDetail(
            @RequestParam Long promoDetailId, // Bắt buộc phải có ID để update
            @RequestParam Integer promotionId,
            @RequestParam String productId,
            @RequestParam Integer minQuantity,
            @RequestParam BigDecimal discountValue,
            @RequestParam String discountType,
            RedirectAttributes redirectAttributes) {
        try {
            Promotion promotion = promotionService.getPromotionById(promotionId);
            Product product = productService.getProductById(productId);

            PromotionDetail detail = new PromotionDetail();
            detail.setPromoDetailId(promoDetailId); // <-- Set ID để Spring JPA hiểu là Cập nhật
            detail.setPromotion(promotion);
            detail.setProduct(product);
            detail.setMinQuantity(minQuantity);
            detail.setDiscountValue(discountValue);
            detail.setDiscountType(PromotionDetail.DiscountType.valueOf(discountType));

            promotionDetailService.savePromotionDetail(detail);
            redirectAttributes.addFlashAttribute("success", "Cập nhật sản phẩm khuyến mãi thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Lỗi khi cập nhật sản phẩm khuyến mãi.");
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
            redirectAttributes.addFlashAttribute("success", "Xóa sản phẩm khỏi đợt khuyến mãi thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Lỗi khi xóa sản phẩm.");
        }
        return "redirect:/promotion/detail?id=" + promotionId;
    }
}
