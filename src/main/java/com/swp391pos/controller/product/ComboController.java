package com.swp391pos.controller.product;

import com.swp391pos.entity.Combo;
import com.swp391pos.service.ComboService;
import com.swp391pos.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Controller
@RequestMapping("/combos")
public class ComboController {

    private final ComboService comboService;
    private final ProductService productService;

    public ComboController(ComboService comboService, ProductService productService) {
        this.comboService = comboService;
        this.productService = productService;
    }

    @GetMapping("/manage")
    public String manage(@RequestParam(value = "status", required = false) List<String> statuses,
                         Model model) {

        List<Combo> combos;
        if (statuses != null && !statuses.isEmpty()) {
            // Lọc theo danh sách trạng thái được chọn
            combos = comboService.getCombosByStatuses(statuses);
        } else {
            // Hiển thị tất cả nếu không chọn filter
            combos = comboService.getAllCombos();
        }
        model.addAttribute("selectedStatuses", statuses);
        model.addAttribute("listCombos", comboService.getAllCombos());
        model.addAttribute("totalCombos", comboService.countTotal());
        model.addAttribute("activeCount", comboService.countByStatus(Combo.Status.ACTIVE));
        model.addAttribute("pendingCount", comboService.countByStatus(Combo.Status.PENDING_APPROVAL));
        return "combo/combo-manage";
    }

    @GetMapping("/add")
    public String showAddForm(Model model) {
        model.addAttribute("combo", new Combo());
        model.addAttribute("nextSku", comboService.generateSku()); // Gợi ý SKU ra UI
        model.addAttribute("products", productService.getAllProducts()); // Cho dropdown list
        return "combo/combo-add";
    }

    @PostMapping("/add")
    public String addCombo(@ModelAttribute Combo combo,
                           @RequestParam("productIds") List<String> productIds,
                           @RequestParam("quantities") List<Integer> quantities,
                           @RequestParam("imageFile") MultipartFile imageFile) {
        try {
            // Truyền thêm list quantities vào service
            comboService.addCombo(combo, productIds, quantities, imageFile);
            return "redirect:/combos/manage?success";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/combos/add?error";
        }
    }

    @GetMapping("/update/{id}")
    public String showUpdateForm(@PathVariable String id, Model model) {
        Combo combo = comboService.getComboById(id);
        if (combo == null) {
            return "redirect:/combos/manage?error=notfound";
        }
        model.addAttribute("combo", combo);
        model.addAttribute("products", productService.getAllProducts());
        return "combo/combo-update"; // Trỏ đến file JSP bạn vừa tạo
    }

    @PostMapping("/update")
    public String updateCombo(@ModelAttribute Combo combo,
                              @RequestParam(value = "productIds", required = false) List<String> productIds,
                              @RequestParam(value = "quantities", required = false) List<Integer> quantities,
                              @RequestParam("imageFile") MultipartFile imageFile,
                              @RequestParam("existingImageUrl") String existingImageUrl) {
        try {
            comboService.updateCombo(combo, productIds, quantities, imageFile, existingImageUrl);
            return "redirect:/combos/manage?updatesuccess";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/combos/update/" + combo.getComboId() + "?error";
        }
    }

    @GetMapping("/detail-fragment/{id}")
    public String getComboDetailFragment(@PathVariable("id") String id, Model model) {

        Combo combo = comboService.getComboById(id);
        model.addAttribute("combo", combo);
        return "combo/combo-detail";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable String id) {
        comboService.deleteCombo(id);
        return "redirect:/combos/manage";
    }
}