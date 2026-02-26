package com.swp391pos.controller.inventory;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.InventoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.Map;


@Controller
@RequestMapping("/inventory")
public class InventoryController {
    @Autowired private InventoryService inventoryService;

    @GetMapping("/dashboard")
    public String showDashboard(@RequestParam(required = false) String search, Model model) {
        model.addAttribute("stats", inventoryService.getDashboardStats());
        model.addAttribute("inventoryList", inventoryService.getInventoryList(search));
        return "inventory/manager/inventory-dashboard";
    }

    @PostMapping("/updateMinStock")
    @ResponseBody
    public ResponseEntity<String> updateMin(
            @RequestParam String productId,
            @RequestParam(name = "minThreshold") Integer min
    ) {
        try {
            inventoryService.updateMinThreshold(productId, min);
            return ResponseEntity.ok("Success");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}
