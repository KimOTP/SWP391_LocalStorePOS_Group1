package com.swp391pos.controller.inventory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.StockInService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.*;

@Controller
@RequestMapping("/stockIn")
public class StockInController {

    @Autowired private StockInService stockInService;

    @GetMapping("/view")
    public String showRequestOrderPage() {
        return "inventory/manager/request-order";
    }

    @GetMapping("/supplier-info")
    @ResponseBody
    public ResponseEntity<?> getSupplierInfo(@RequestParam String name) {
        Map<String, String> data = stockInService.getSupplierEmail(name);
        return (data != null) ? ResponseEntity.ok(data) : ResponseEntity.notFound().build();
    }

    @GetMapping("/products-by-supplier")
    @ResponseBody
    public ResponseEntity<?> getProductsBySupplier(@RequestParam String name) {
        List<Product> products = stockInService.getProductsBySupplier(name);
        return products.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(products);
    }

    @GetMapping("/product-info")
    @ResponseBody
    public ResponseEntity<?> getSingleProductInfo(@RequestParam String sku) {
        Map<String, Object> data = stockInService.getProductDetails(sku);
        return (data != null) ? ResponseEntity.ok(data) : ResponseEntity.notFound().build();
    }

    // Request Order for Manager
    @PostMapping("/stock-in")
    public String submitOrder(
            @RequestParam String supplierName,
            @RequestParam String itemsJson,
            HttpSession session, RedirectAttributes ra) {
        try {
            Account account = (Account) session.getAttribute("loggedInAccount");
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> items = mapper.readValue(itemsJson, new TypeReference<>(){});
            stockInService.createRequest(supplierName, items, account);

            ra.addFlashAttribute("message", "Product Request submitted successfully!");
            ra.addFlashAttribute("status", "success");
        } catch (Exception e) {
            ra.addFlashAttribute("message", "Error: " + e.getMessage());
            ra.addFlashAttribute("status", "danger");
        }
        return "redirect:view";
    }

    //Stock In Notification For Inventory Staff
    @GetMapping("/notifications")
    public String showNotifications(Model model) {
        List<StockIn> pendingList = stockInService.getPendingNotifications();

        model.addAttribute("pendingRequests", pendingList);
        model.addAttribute("totalPending", pendingList.size());
        return "inventory/inventoryStaff/notifications";
    }

    //Stock In Process For InventoryStaff
    @GetMapping("/process")
    public String showProcessPage(@RequestParam Integer id, Model model) {
        model.addAttribute("stockIn", stockInService.getStockInForProcessing(id));
        return "inventory/inventoryStaff/stock-in";
    }

    //Stock In Submit for InventoryStaff
    @PostMapping("/submit-process")
    public String submitProcess(
            @RequestParam Integer stockInId,
            @RequestParam String actualDataJson,
            HttpSession session, RedirectAttributes ra) {
        try {
            Account staff = (Account) session.getAttribute("loggedInAccount");
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> actualData = mapper.readValue(actualDataJson, new TypeReference<>() {});

            stockInService.processStaffInput(stockInId, actualData, staff);
            ra.addFlashAttribute("message", "Stock-in data submitted for approval!");
            ra.addFlashAttribute("status", "success");
        } catch (Exception e) {
            ra.addFlashAttribute("message", "Error: " + e.getMessage());
            ra.addFlashAttribute("status", "danger");
        }
        return "redirect:/stockIn/inventory-staff/notifications";
    }

    //Views Stock In Detail for InventoryStaff
    @GetMapping("/stock-in-details")
    public String viewDetailed(@RequestParam Integer id, Model model) {
        StockIn stockIn = stockInService.getStockInById(id);
        model.addAttribute("stockIn", stockIn);
        return "inventory/inventoryStaff/stock-in-detail";
    }
}