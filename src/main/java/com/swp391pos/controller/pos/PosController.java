package com.swp391pos.controller.pos;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.CategoryService;
import com.swp391pos.service.ProductService;
import com.swp391pos.service.PromotionService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
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
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final PromotionRepository promotionRepository;
    private final PromotionService promotionService;
    private final CategoryRepository categoryRepository;
    private final CategoryService categoryService;
    private final InventoryRepository inventoryRepository;
    private final PaymentRepository paymentRepository;
    private final EmployeeRepository employeeRepository;

    /**
     * Hiển thị trang POS chính
     */
    @GetMapping("")
    public String showPOS(Model model, HttpSession session) {
        // Lấy tất cả sản phẩm (hoặc có thể phân trang)
        List<Product> products = productService.getAllProducts();
        model.addAttribute("products", products);

        // Lấy tất cả danh mục
        List<Category> categories = categoryService.getAllCategories();
        model.addAttribute("categories", categories);

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
                            // Dùng String.valueOf để tránh lỗi kiểu dữ liệu
                            String.valueOf(p.getCategory().getCategoryId()).equals(categoryId))
                    .collect(Collectors.toList());
        } else {
            // Lấy tất cả sản phẩm
            products = productRepository.findAll();
        }

        // Chuyển đổi thành DTO
        return products.stream().map(p -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", p.getProductId());
            map.put("name", p.getProductName());
            map.put("price", p.getPrice());
            map.put("imageUrl", p.getImageUrl());
            map.put("unit", p.getUnit());
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
            map.put("id", p.getProductId());
            map.put("name", p.getProductName());
            map.put("price", p.getPrice());
            map.put("imageUrl", p.getImageUrl());
            return map;
        }).collect(Collectors.toList());
    }

}
