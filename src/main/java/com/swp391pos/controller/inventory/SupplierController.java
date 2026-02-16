package com.swp391pos.controller.inventory;

import com.swp391pos.entity.Supplier;
import com.swp391pos.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/suppliers")
public class SupplierController {

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String viewSupplierList(Model model) {
        // Put all data to a model
        model.addAttribute("suppliers", supplierService.getSuppliersDashboardData());
        return "inventory/supplier-list";
    }

    @PostMapping("/add")
    public String createSupplier(@ModelAttribute Supplier supplier) {
        supplierService.saveSupplier(supplier);
        return "redirect:/admin/suppliers";
    }

    @PostMapping("/update")
    public String updateSupplier(@ModelAttribute Supplier supplier) {
        supplierService.updateSupplier(supplier);
        return "redirect:/admin/suppliers";
    }

    @GetMapping("/delete/{id}")
    public String removeSupplier(@PathVariable Integer id) {
        supplierService.deleteSupplier(id);
        return "redirect:/admin/suppliers";
    }
}