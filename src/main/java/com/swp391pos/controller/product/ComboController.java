package com.swp391pos.controller.product;

import com.swp391pos.entity.Combo;
import com.swp391pos.service.ComboService;
import com.swp391pos.service.ProductService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.util.List;

@Controller
@RequestMapping("/combos")
public class ComboController {

    @Autowired
    private ComboService comboService;

    @Autowired
    private ProductService productService;


    @GetMapping("/manage")
    public String manage(Model model) {

        model.addAttribute("listCombos", comboService.getAllCombos());
        model.addAttribute("totalCombos", comboService.countTotal());
        model.addAttribute("activeCount", comboService.countByStatus(Combo.Status.ACTIVE));
        model.addAttribute("pendingCount", comboService.countByStatus(Combo.Status.PENDING_APPROVAL));
        return "combo/combo-manage";
    }

    @GetMapping("/add")
    public String showAddForm(Model model) {
        model.addAttribute("combo", new Combo());
        model.addAttribute("nextSku", comboService.generateSku()); // gợi ý SKU ra UI
        model.addAttribute("products", productService.getAllProducts());
        return "combo/combo-add";
    }

    @PostMapping("/add")
    public String addCombo(@ModelAttribute Combo combo,
                           @RequestParam("productIds") List<String> productIds,
                           @RequestParam("quantities") List<Integer> quantities,
                           @RequestParam("imageFile") MultipartFile imageFile) {
        try {
            // truyền thêm list quantities vào service
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
        return "combo/combo-update";
    }

    @PostMapping("/update")
    public String updateCombo(@ModelAttribute Combo combo,
                              @RequestParam(value = "productIds", required = false) List<String> productIds,
                              @RequestParam(value = "quantities", required = false) List<Integer> quantities,
                              @RequestParam("imageFile") MultipartFile imageFile,
                              @RequestParam("existingImageUrl") String existingImageUrl,
                              RedirectAttributes redirectAttributes) {
        try {
            comboService.updateCombo(combo, productIds, quantities, imageFile, existingImageUrl);
            redirectAttributes.addFlashAttribute("notification", "Combo update successfully!");
            return "redirect:/combos/manage";
        } catch(RuntimeException e){
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            e.printStackTrace();
            return "redirect:/combos/update/" + combo.getComboId();
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to update combo!");
            return "redirect:/combos/update/"  + combo.getComboId();
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

    @GetMapping("/export-excel")
    public void exportToExcel(HttpServletResponse response) throws IOException {
        response.setContentType("application/octet-stream");
        String headerKey = "Content-Disposition";
        String headerValue = "attachment; filename=combos_list.xlsx";
        response.setHeader(headerKey, headerValue);

        List<Combo> list = comboService.getAllCombos();
        comboService.exportCombosToExcel(list, response);
    }
}