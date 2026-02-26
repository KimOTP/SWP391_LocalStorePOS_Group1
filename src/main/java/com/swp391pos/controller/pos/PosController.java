package com.swp391pos.controller.pos;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.*;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/pos")
@RequiredArgsConstructor
public class PosController {

    private final ProductRepository  productRepository;
    private final ProductService     productService;
    private final OrderService       orderService;
    private final OrderItemService   orderItemService;
    private final OrderStatusService orderStatusService;
    private final PromotionService   promotionService;
    private final CategoryService    categoryService;
    private final InventoryService   inventoryService;
    private final PaymentService     paymentService;
    private final EmployeeService    employeeService;
    private final ObjectMapper       objectMapper;   // Spring Boot tự tạo bean này

    private static final String SESSION_PRINT_TEMPLATE  = "posPrintTemplate";

    /**
     * Key session chứa JSON của order items để Promotion module đọc.
     *
     * Format JSON được lưu:
     * [
     *   {
     *     "orderItemId" : 10,
     *     "orderId"     : 5,
     *     "productId"   : 3,
     *     "productName" : "Pepsi 330ml",
     *     "unit"        : "Chai",
     *     "quantity"    : 2,
     *     "unitPrice"   : 10000.00,
     *     "lineTotal"   : 20000.00
     *   },
     *   ...
     * ]
     *
     * Promotion module đọc bằng cách:
     *   String json = (String) session.getAttribute("posCurrentOrderJson");
     *   List<Map> items = objectMapper.readValue(json, List.class);
     *
     * Hoặc gọi GET /pos/api/cart-items để nhận trực tiếp JSON response.
     */
    private static final String SESSION_CART_ORDER_JSON = "posCurrentOrderJson";

    /* ================================================================
       POS MAIN PAGE
       ================================================================ */
    @GetMapping("")
    public String showPOS(Model model, HttpSession session) {
        model.addAttribute("products",   productService.getAllProducts());
        model.addAttribute("categories", categoryService.getAllCategories());

        @SuppressWarnings("unchecked")
        Map<String, String> tpl = (Map<String, String>) session.getAttribute(SESSION_PRINT_TEMPLATE);
        if (tpl == null) {
            tpl = new HashMap<>();
            tpl.put("paperSize", "58mm");
            tpl.put("fontSize",  "12");
            tpl.put("title",     "Sales invoice");
            tpl.put("thanks",    "Thank you for your purchase.");
            tpl.put("company",   "Local store POS system");
            tpl.put("address",   "123 Đường ABC, Hòa Lạc, thành phố Hà Nội");
            tpl.put("phone",     "0956328396");
            tpl.put("email",     "info@gmail.com");
        }
        model.addAttribute("templateSettings", tpl);

        return "pos/cashier/pos";
    }

    /* ================================================================
       PRODUCT APIS
       ================================================================ */
    @GetMapping("/api/products")
    @ResponseBody
    public List<Map<String, Object>> getProductsByCategory(
            @RequestParam(required = false) String categoryId) {

        List<Product> products = categoryId != null && !categoryId.isEmpty()
                ? productRepository.findAll().stream()
                .filter(p -> p.getCategory() != null &&
                        String.valueOf(p.getCategory().getCategoryId()).equals(categoryId))
                .collect(Collectors.toList())
                : productRepository.findAll();

        return toProductDtoList(products);
    }

    @GetMapping("/api/search")
    @ResponseBody
    public List<Map<String, Object>> searchProducts(@RequestParam String query) {
        List<Product> products = productRepository.findAll().stream()
                .filter(p -> p.getProductName().toLowerCase().contains(query.toLowerCase()))
                .collect(Collectors.toList());
        return toProductDtoList(products);
    }

    private List<Map<String, Object>> toProductDtoList(List<Product> products) {
        return products.stream().map(p -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id",       p.getProductId());
            m.put("name",     p.getProductName());
            m.put("price",    p.getPrice());
            m.put("imageUrl", p.getImageUrl());
            m.put("unit",     p.getUnit());
            return m;
        }).collect(Collectors.toList());
    }

    /* ================================================================
       CHECKOUT
       POST /pos/api/checkout
       Body: { items: [{productId, productName, price, quantity, unit}], totalAmount }
       ================================================================ */
    @PostMapping("/api/checkout")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkout(
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        Map<String, Object> resp = new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> items =
                    (List<Map<String, Object>>) body.get("items");

            double totalAmount = ((Number) body.getOrDefault("totalAmount", 0)).doubleValue();

            // ── Tạo Order DRAFT ──
            Order order = new Order();
            order.setCreatedAt(LocalDateTime.now());
            order.setTotalAmount(BigDecimal.valueOf(totalAmount));
            order.setOrderStatus(orderStatusService.findByOrderStatusName(
                    OrderStatus.OrderStatusName.valueOf("DRAFT")));

            Object account = session.getAttribute("account");
            if (account instanceof Account) {
                order.setEmployee(((Account) account).getEmployee());
            }

            Order saved = orderService.save(order);

            // ── Tạo từng OrderItem và build DTO map song song ──
            List<Map<String, Object>> orderItemJsonList = new ArrayList<>();

            for (Map<String, Object> item : items) {

                // Lưu entity vào DB
                OrderItem oi = new OrderItem();
                oi.setOrder(saved);

                Object pid = item.get("productId");
                productRepository
                        .findById((int) Long.parseLong(String.valueOf(pid)))
                        .ifPresent(oi::setProduct);

                int        qty       = ((Number) item.getOrDefault("quantity", 1)).intValue();
                BigDecimal unitPrice = BigDecimal.valueOf(
                        ((Number) item.getOrDefault("price", 0)).doubleValue());

                oi.setQuantity(qty);
                oi.setUnitPrice(unitPrice);

                OrderItem savedItem = orderItemService.save(oi);

                // Build DTO – chỉ chứa giá trị thuần, không chứa entity lồng nhau.
                // Lý do: tránh LazyInitializationException khi Jackson serialize
                // các quan hệ @ManyToOne/@OneToMany chưa được load.
                Map<String, Object> dto = new LinkedHashMap<>();
                dto.put("orderItemId",  savedItem.getOrderItemId());
                dto.put("orderId",      saved.getOrderId());
                dto.put("productId",    pid);
                dto.put("productName",  item.getOrDefault("productName", ""));
                dto.put("unit",         item.getOrDefault("unit", ""));
                dto.put("quantity",     qty);
                dto.put("unitPrice",    unitPrice);
                dto.put("lineTotal",    unitPrice.multiply(BigDecimal.valueOf(qty)));

                orderItemJsonList.add(dto);
            }

            // ── Serialize sang JSON String rồi lưu vào session ──
            //
            // Tại sao JSON String thay vì List<OrderItem> entity?
            //
            // 1. TRÁNH LazyInitializationException
            //    Entity chứa @ManyToOne Product, @ManyToOne Order v.v.
            //    Khi Hibernate session đóng (sau khi request checkout kết thúc),
            //    Jackson không thể serialize các quan hệ lazy → exception.
            //    JSON String đã được tạo trong cùng request → an toàn.
            //
            // 2. PROMOTION MODULE ĐỌC DỄ HƠN
            //    Module khác chỉ cần:
            //      String json = (String) session.getAttribute("posCurrentOrderJson");
            //      List<Map> items = objectMapper.readValue(json, List.class);
            //    Không cần import entity, không cần Spring context của POS module.
            //
            // 3. DỄ DEBUG
            //    Có thể log thẳng giá trị session ra console để kiểm tra.
            //
            String orderItemsJson = objectMapper.writeValueAsString(orderItemJsonList);
            session.setAttribute(SESSION_CART_ORDER_JSON, orderItemsJson);

            resp.put("success", true);
            resp.put("orderId", saved.getOrderId());
            return ResponseEntity.ok(resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.put("success", false);
            resp.put("message", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    /* ================================================================
       ENDPOINT ĐỌC JSON CHO PROMOTION MODULE
       GET /pos/api/cart-items
       Promotion controller gọi endpoint này thay vì đọc session trực tiếp.
       ================================================================ */
    @GetMapping("/api/cart-items")
    @ResponseBody
    public ResponseEntity<Object> getCartItemsJson(HttpSession session) {
        String json = (String) session.getAttribute(SESSION_CART_ORDER_JSON);

        // Không có cart → trả về mảng rỗng, không lỗi
        if (json == null || json.isBlank()) {
            return ResponseEntity.ok(Collections.emptyList());
        }

        try {
            // Parse String → List<Map> rồi để Spring tự serialize lại thành JSON response
            Object parsed = objectMapper.readValue(json, List.class);
            return ResponseEntity.ok(parsed);
        } catch (Exception ex) {
            return ResponseEntity.status(500)
                    .body(Map.of("error", "Failed to parse cart items: " + ex.getMessage()));
        }
    }

    /* ================================================================
       PAYMENT PAGE
       GET /pos/payment?orderId=xxx
       ================================================================ */
    @GetMapping("/payment")
    public String showPayment(@RequestParam Long orderId,
                              Model model,
                              HttpSession session) {
        Order order = orderService.findById(orderId);
        model.addAttribute("order",      order);
        model.addAttribute("bankConfig", session.getAttribute("posBankConfig"));
        return "pos/cashier/payment";
    }

    /* ================================================================
       CONFIRM PAYMENT
       POST /pos/api/payment/confirm
       ================================================================ */
    @PostMapping("/api/payment/confirm")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> confirmPayment(
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        Map<String, Object> resp = new HashMap<>();
        try {
            Long   orderId       = Long.parseLong(String.valueOf(body.get("orderId")));
            String paymentMethod = String.valueOf(body.getOrDefault("paymentMethod", "cash"));
            double totalPaid     = ((Number) body.getOrDefault("totalPaid", 0)).doubleValue();
            String note          = String.valueOf(body.getOrDefault("note", ""));

            Order order = orderService.findById(orderId);

            OrderStatus completed = orderStatusService.findByOrderStatusName(
                    OrderStatus.OrderStatusName.valueOf("PAID"));
            order.setOrderStatus(completed);
            orderService.save(order);

            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setPaymentMethod(Payment.PaymentMethod.valueOf(paymentMethod.toUpperCase()));
            payment.setAmount(BigDecimal.valueOf(totalPaid));
            payment.setPaidAt(LocalDateTime.now());
            paymentService.save(payment);

            // Xóa JSON session sau khi thanh toán xong
            session.removeAttribute(SESSION_CART_ORDER_JSON);

            resp.put("success", true);
            resp.put("orderId", orderId);
            return ResponseEntity.ok(resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.put("success", false);
            resp.put("message", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    /* ================================================================
       CANCEL ORDER
       POST /pos/api/order/{orderId}/cancel
       ================================================================ */
    @PostMapping("/api/order/{orderId}/cancel")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> cancelOrder(
            @PathVariable Long orderId,
            HttpSession session) {

        Map<String, Object> resp = new HashMap<>();
        try {
            Order order = orderService.findById(orderId);

            OrderStatus cancelled = orderStatusService.findByOrderStatusName(
                    OrderStatus.OrderStatusName.valueOf("CANCELLED"));
            order.setOrderStatus(cancelled);
            orderService.save(order);

            session.removeAttribute(SESSION_CART_ORDER_JSON);

            resp.put("success", true);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            resp.put("success", false);
            resp.put("message", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    /* ================================================================
       PRINT TEMPLATE SETTINGS
       ================================================================ */
    @PostMapping("/api/print-template")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> savePrintTemplate(
            @RequestBody Map<String, String> settings,
            HttpSession session) {

        List<String> required = Arrays.asList(
                "paperSize","fontSize","title","thanks","company","address","phone","email");
        for (String k : required) {
            if (!settings.containsKey(k) || settings.get(k).isBlank()) {
                Map<String, Object> err = new HashMap<>();
                err.put("success", false);
                err.put("message", "Missing: " + k);
                return ResponseEntity.badRequest().body(err);
            }
        }
        session.setAttribute(SESSION_PRINT_TEMPLATE, new HashMap<>(settings));

        Map<String, Object> resp = new HashMap<>();
        resp.put("success", true);
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/api/print-template")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getPrintTemplate(HttpSession session) {
        @SuppressWarnings("unchecked")
        Map<String, String> s = (Map<String, String>) session.getAttribute(SESSION_PRINT_TEMPLATE);
        Map<String, Object> resp = new HashMap<>();
        resp.put("success", s != null);
        if (s != null) resp.put("settings", s);
        return ResponseEntity.ok(resp);
    }
}