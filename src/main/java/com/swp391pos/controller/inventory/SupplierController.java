package com.swp391pos.controller.inventory;

import com.swp391pos.entity.Supplier;
import com.swp391pos.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/suppliers")
public class SupplierController {

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String viewSupplierList(Model model) {
        model.addAttribute("suppliers", supplierService.getSuppliersDashboardData());
        return "inventory/manager/supplier-list";
    }

    @PostMapping("/add")
    public String createSupplier(@ModelAttribute Supplier supplier,RedirectAttributes ra) {
        try {
            supplierService.saveSupplier(supplier);
            ra.addFlashAttribute("notification", "Supplier has been successfully created");
        } catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/suppliers";
    }

    @PostMapping("/update")
    public String updateSupplier(@ModelAttribute Supplier supplier, RedirectAttributes ra) {
        try {
            supplierService.updateSupplier(supplier);
            ra.addFlashAttribute("notification", "Supplier updated successfully!");
        }catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/delete/{id}")
    public String removeSupplier(@PathVariable Integer id, RedirectAttributes ra) {
        try {
            supplierService.deleteSupplier(id);
            ra.addFlashAttribute("notification", "Supplier has been successfully deleted!");
        }catch (Exception e) {
            ra.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/suppliers";
    }
}