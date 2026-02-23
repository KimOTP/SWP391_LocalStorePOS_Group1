package com.swp391pos.controller.inventory;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.InventoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/requestOrder")
public class RequestOrderController {

    @Autowired private ProductRepository productRepo;
    @Autowired private InventoryRepository inventoryRepo;
    @Autowired private SupplierRepository supplierRepo;
    @Autowired private InventoryService inventoryService;

    // 1. CHỈNH SỬA: Phương thức trả về giao diện JSP
    @GetMapping("/admin/view")
    public String showRequestOrderPage() {
        return "inventory/request-order";
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
    @ResponseBody
    public ResponseEntity<?> saveRequest(@RequestBody Map<String, Object> payload) {
        inventoryService.createRequest(payload);
        return ResponseEntity.ok().build();
    }
}