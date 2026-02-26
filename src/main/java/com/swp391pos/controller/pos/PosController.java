package com.swp391pos.controller.pos;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.*;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/pos")
@RequiredArgsConstructor
public class PosController {

    private final ProductRepository productRepository;
    private final ProductService productService;
    private final OrderService orderService;
    private final OrderItemService orderItemService;
    private final OrderStatusService orderStatusService;
    private final PromotionService promotionService;
    private final CategoryService categoryService;
    private final InventoryService inventoryService;
    private final PaymentService paymentService;
    private final EmployeeService employeeService;

    // Session key cho print template settings
    private static final String SESSION_PRINT_TEMPLATE = "posPrintTemplate";

    /**
     * Hiển thị trang POS chính
     */
    @GetMapping("")
    public String showPOS(Model model, HttpSession session) {
        List<Product> products = productService.getAllProducts();
        model.addAttribute("products", products);

        List<Category> categories = categoryService.getAllCategories();
        model.addAttribute("categories", categories);

        // Truyền template settings đã lưu (nếu có) xuống view
        @SuppressWarnings("unchecked")
        Map<String, String> templateSettings =
                (Map<String, String>) session.getAttribute(SESSION_PRINT_TEMPLATE);
        if (templateSettings == null) {
            // Default values
            templateSettings = new HashMap<>();
            templateSettings.put("paperSize", "58mm");
            templateSettings.put("fontSize",  "12");
            templateSettings.put("title",     "Sales invoice");
            templateSettings.put("thanks",    "Thank you for your purchase.");
            templateSettings.put("company",   "Local store POS system");
            templateSettings.put("address",   "123 Đường ABC, Hòa Lạc, thành phố Hà Nội");
            templateSettings.put("phone",     "0956328396");
            templateSettings.put("email",     "info@gmail.com");
        }
        model.addAttribute("templateSettings", templateSettings);

        return "pos/cashier/pos";
    }

    /**
     * Lấy sản phẩm theo danh mục (AJAX)
     */
    @GetMapping("/api/products")
    @ResponseBody
    public List<Map<String, Object>> getProductsByCategory(
            @RequestParam(required = false) String categoryId) {

        List<Product> products;

        if (categoryId != null && !categoryId.isEmpty()) {
            products = productRepository.findAll().stream()
                    .filter(p -> p.getCategory() != null &&
                            String.valueOf(p.getCategory().getCategoryId()).equals(categoryId))
                    .collect(Collectors.toList());
        } else {
            products = productRepository.findAll();
        }

        return products.stream().map(p -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id",       p.getProductId());
            map.put("name",     p.getProductName());
            map.put("price",    p.getPrice());
            map.put("imageUrl", p.getImageUrl());
            map.put("unit",     p.getUnit());
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * Tìm kiếm sản phẩm (AJAX)
     */
    @GetMapping("/api/search")
    @ResponseBody
    public List<Map<String, Object>> searchProducts(@RequestParam String query) {
        List<Product> products = productRepository.findAll().stream()
                .filter(p -> p.getProductName().toLowerCase().contains(query.toLowerCase()))
                .collect(Collectors.toList());

        return products.stream().map(p -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id",       p.getProductId());
            map.put("name",     p.getProductName());
            map.put("price",    p.getPrice());
            map.put("imageUrl", p.getImageUrl());
            map.put("unit",     p.getUnit());
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * Lưu cài đặt print template vào session (AJAX POST)
     * Body JSON: { paperSize, fontSize, title, thanks, company, address, phone, email }
     */
    @PostMapping("/api/print-template")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> savePrintTemplate(
            @RequestBody Map<String, String> settings,
            HttpSession session) {

        // Chỉ cho phép MANAGER lưu
        Object account = session.getAttribute("account");
        // (Tuỳ project: kiểm tra role qua session attribute của bạn)
        // if (account == null || !isManager(account)) {
        //     return ResponseEntity.status(403).body(Map.of("success", false, "message", "Forbidden"));
        // }

        // Validate các field bắt buộc
        List<String> required = Arrays.asList("paperSize","fontSize","title","thanks","company","address","phone","email");
        for (String key : required) {
            if (!settings.containsKey(key) || settings.get(key).isBlank()) {
                Map<String, Object> err = new HashMap<>();
                err.put("success", false);
                err.put("message", "Missing required field: " + key);
                return ResponseEntity.badRequest().body(err);
            }
        }

        // Lưu vào session
        session.setAttribute(SESSION_PRINT_TEMPLATE, new HashMap<>(settings));

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Template saved successfully.");
        return ResponseEntity.ok(response);
    }

    /**
     * Lấy cài đặt print template từ session (AJAX GET)
     */
    @GetMapping("/api/print-template")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getPrintTemplate(HttpSession session) {
        @SuppressWarnings("unchecked")
        Map<String, String> settings =
                (Map<String, String>) session.getAttribute(SESSION_PRINT_TEMPLATE);

        Map<String, Object> response = new HashMap<>();
        if (settings != null) {
            response.put("success", true);
            response.put("settings", settings);
        } else {
            response.put("success", false);
            response.put("message", "No template settings found.");
        }
        return ResponseEntity.ok(response);
    }
}