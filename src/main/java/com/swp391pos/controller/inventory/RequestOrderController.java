package com.swp391pos.controller.inventory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.StockInService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.*;

@Controller
@RequestMapping("/requestOrder")
public class RequestOrderController {

    @Autowired private ProductRepository productRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private SupplierRepository supplierRepo;
    @Autowired private StockInService stockInService;

    @GetMapping("/admin/view")
    public String showRequestOrderPage() {
        return "inventory/admin/request-order";
    }

    @GetMapping("/admin/supplier-info")
    @ResponseBody
    public ResponseEntity<?> getSupplierInfo(@RequestParam String name) {
        return supplierRepo.findBySupplierName(name)
                .map(s -> {
                    Map<String, String> res = new HashMap<>();
                    res.put("email", s.getEmail());
                    return ResponseEntity.ok((Object) res);
                })
                .orElse(ResponseEntity.status(404).body("Cannot find this supplier!"));
    }

    @GetMapping("/admin/products-by-supplier")
    @ResponseBody
    public ResponseEntity<?> getProductsBySupplier(@RequestParam String name) {
        List<Product> products = productRepo.searchBySupplierName(name);
        if (products.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(products);
    }

    @GetMapping("/admin/product-info")
    @ResponseBody
    public ResponseEntity<?> getSingleProductInfo(@RequestParam String sku) {
        Product product = productRepo.findProductByProductId(sku);
        if (product == null) return ResponseEntity.notFound().build();
        Inventory inventory = inventoryRepo.findById(sku).orElse(null);
        Map<String, Object> response = new HashMap<>();
        response.put("productName", product.getProductName());
        response.put("unitCost", (inventory != null) ? inventory.getUnitCost() : BigDecimal.ZERO);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/admin/stock-in")
    public String submitOrder(
            @RequestParam String supplierName,
            @RequestParam String itemsJson,
            HttpSession session, RedirectAttributes ra) {
        try {
            Account account = (Account) session.getAttribute("loggedInAccount");
//            if (account == null) return "redirect:/login";

            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> items = mapper.readValue(itemsJson, new TypeReference<List<Map<String, Object>>>(){});

            stockInService.createRequest(supplierName, items, account);
            ra.addFlashAttribute("message", "Product Request submitted successfully!");
            ra.addFlashAttribute("status", "success");
        } catch (Exception e) {
            ra.addFlashAttribute("message", "Error: " + e.getMessage());
            ra.addFlashAttribute("status", "danger");
        }
        return "redirect:/requestOrder/admin/view";
    }
}