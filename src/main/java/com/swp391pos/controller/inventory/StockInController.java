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
import com.swp391pos.dto.StockInItemDTO;

import java.util.*;

@Controller
@RequestMapping("/stockIn")
public class StockInController {

    @Autowired private StockInService stockInService;

    @GetMapping("/add")
    public String showRequestOrderPage(Model model) {
        model.addAttribute("suppliers", stockInService.getAllSuppliers());
        return "inventory/manager/stock-in-request"; // Tên file JSP mới của bạn
    }

    @GetMapping("/supplier-info")
    @ResponseBody
    public ResponseEntity<?> getSupplierInfo(@RequestParam String name) {
        Map<String, String> data = stockInService.getSupplierEmail(name);
        return (data != null) ? ResponseEntity.ok(data) : ResponseEntity.notFound().build();
    }

    @GetMapping("/api/all-prioritized")
    @ResponseBody
    public List<Inventory> getPrioritizedApi() {
        return stockInService.getPrioritizedInventory();
    }

    @PostMapping("/stock-in")
    public String submitOrder(
            @RequestParam Integer supplierId,
            @RequestParam(required = false) String note,
            @RequestParam String itemsJson,
            HttpSession session, RedirectAttributes ra) {
        try {
            Account account = (Account) session.getAttribute("loggedInAccount");
            ObjectMapper mapper = new ObjectMapper();
            List<StockInItemDTO> items = mapper.readValue(itemsJson, new TypeReference<List<StockInItemDTO>>() {});
            stockInService.createRequest(supplierId, items, account);

            ra.addFlashAttribute("message", "Stock-in request created successfully!");
            ra.addFlashAttribute("status", "success");
        } catch (Exception e) {
            ra.addFlashAttribute("message", "Error: " + e.getMessage());
            ra.addFlashAttribute("status", "danger");
        }
        return "redirect:/inventory/dashboard"; // Quay về Dashboard sau khi tạo xong
    }

    @GetMapping("/product-info")
    @ResponseBody
    public ResponseEntity<?> getSingleProductInfo(@RequestParam String sku) {
        Map<String, Object> data = stockInService.getProductDetails(sku);
        return (data != null) ? ResponseEntity.ok(data) : ResponseEntity.notFound().build();
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
        return "redirect:/stockIn/notifications";
    }

    //Views Stock In Detail for InventoryStaff
    @GetMapping("/details")
    public String viewDetailed(@RequestParam Integer id, Model model) {
        StockIn stockIn = stockInService.getStockInById(id);
        model.addAttribute("stockIn", stockIn);
        return "inventory/inventoryStaff/stock-in-detail";
    }
}