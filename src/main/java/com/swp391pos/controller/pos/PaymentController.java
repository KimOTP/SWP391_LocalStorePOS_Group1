package com.swp391pos.controller.pos;

import com.swp391pos.dto.PaymentDTO;
import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.entity.*;
import com.swp391pos.enums.OrderStatusName;
import com.swp391pos.enums.PaymentMethod;
import com.swp391pos.enums.PaymentStatus;
import com.swp391pos.repository.OrderPromotionRepository;
import com.swp391pos.repository.PromotionRepository;
import com.swp391pos.service.*;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/pos/payment")
@RequiredArgsConstructor
public class PaymentController {

    private static final String SESSION_CART_ORDER_JSON = "posCurrentOrderJson";
    private static final String SESSION_CURRENT_ORDER_ID  = "posCurrentOrderId";

    private final PaymentService paymentService;
    private final OrderService orderService;
    private final OrderItemService orderItemService;
    private final PosService posService;
    private final OrderStatusService orderStatusService;
    private final PosReceiptService posReceiptService;
    private final SystemSettingService systemSettingService;
    private final com.swp391pos.gateway.PaymentGateway paymentGateway;
    private final CustomerService customerService;
    private final OrderPromotionRepository orderPromotionRepository;
    private final PromotionRepository promotionRepository;

    /* ================================================================
       PAYMENT PAGE
       GET /pos/payment?orderId=xxx
       ================================================================ */
    @GetMapping
    public String showPayment(@RequestParam Long orderId,
                              Model model,
                              HttpSession session) {
        Order order = orderService.findById(orderId);

        List<OrderItem> items = orderItemService.findByOrder(order);

        List<PaymentDTO.OrderItemDTO> cartItems = items.stream()
                .filter(oi -> oi.getProduct() != null) // chỉ lấy product, bỏ qua combo
                .map(oi -> {
                    PaymentDTO.OrderItemDTO dto = new PaymentDTO.OrderItemDTO();
                    dto.setOrderId(order.getOrderId());
                    dto.setProductId(oi.getProduct().getProductId());
                    dto.setQuantity(oi.getQuantity());
                    return dto;
                }).collect(Collectors.toList());

        PaymentDTO.PaymentSummary summary = posService.calculatePromotion(cartItems);
        Map<String, String> pointConfig = systemSettingService.getAllSettings();
        //Gửi cho Vanh cấu hình điểm
        model.addAttribute("pointConfig", pointConfig);
        //Gửi cho Vanh áp dụng giảm giá sản phẩm
        model.addAttribute("summary", summary);
        model.addAttribute("order", order);
        model.addAttribute("bankConfig", session.getAttribute("posBankConfig"));

        return "pos/cashier/payment";
    }

    /* ================================================================
       CONFIRM PAYMENT (Cash)
       POST /pos/payment/confirm
       ================================================================ */
    @PostMapping("/confirm")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> confirmPayment(
            @RequestBody Map<String, Object> body,
            HttpSession session) {

        Map<String, Object> resp = new HashMap<>();
        try {
            Long   orderId       = Long.parseLong(String.valueOf(body.get("orderId")));
            String paymentMethod = String.valueOf(body.getOrDefault("paymentMethod", "CASH")).toUpperCase();
            // Normalise: frontend gửi 'BANKING' hoặc 'CASH'
            if (!paymentMethod.equals("BANKING")) paymentMethod = "CASH";

            double totalPaid    = ((Number) body.getOrDefault("totalPaid",    0)).doubleValue();
            double customerPaid = ((Number) body.getOrDefault("customerPaid", totalPaid)).doubleValue();
            double changeAmount = ((Number) body.getOrDefault("changeAmount", 0)).doubleValue();
            double discountAmt  = ((Number) body.getOrDefault("discount",    0)).doubleValue();
            double loyaltyUsed  = ((Number) body.getOrDefault("loyaltyUsed", 0)).doubleValue();

            Order order = orderService.findById(orderId);

            // Idempotency: nếu đã PAID rồi thì trả thành công luôn (tránh double-confirm khi poll)
            if (order.getOrderStatus() != null
                    && "PAID".equals(order.getOrderStatus().getOrderStatusName().name())) {
                resp.put("success", true);
                resp.put("orderId", orderId);
                return ResponseEntity.ok(resp);
            }

            // Ghi nhận thanh toán và trừ kho nếu chưa từng đóng tiền
            boolean isFirstPaymentForOrder = order.getPaidAt() == null;
            
            if (isFirstPaymentForOrder) {
                String validationError = paymentService.validateStockBeforePayment(orderId);
                if (validationError != null) {
                    resp.put("success", false);
                    resp.put("errorMessage", validationError);
                    return ResponseEntity.ok(resp);
                }
            }

            OrderStatus completed = orderStatusService.findByOrderStatusName(
                    OrderStatusName.valueOf("PAID"));
            order.setOrderStatus(completed);
            order.setPaidAt(LocalDateTime.now());

            // Cập nhật giá trị cuối cùng sau giảm giá
            order.setDiscountAmount(BigDecimal.valueOf(discountAmt + loyaltyUsed));
            order.setTotalAmount(BigDecimal.valueOf(totalPaid));

            PaymentMethod orderPayMethod = paymentMethod.equals("BANKING")
                    ? PaymentMethod.BANKING
                    : PaymentMethod.CASH;
            order.setPaymentMethod(orderPayMethod);

            // Xử lý an toàn chuỗi rỗng của customerId
            Object rawCustId = body.get("customerId");
            Long customerId = null;
            if (rawCustId != null && !String.valueOf(rawCustId).trim().isEmpty()) {
                customerId = Long.valueOf(String.valueOf(rawCustId).trim());
                Customer cus = customerService.findById(customerId);
                order.setCustomer(cus);
            }

            orderService.save(order);

            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setPaymentSessionId(UUID.randomUUID().toString());
            payment.setPaymentMethod(orderPayMethod);
            payment.setPaymentStatus(PaymentStatus.PAID);
            payment.setAmount(BigDecimal.valueOf(totalPaid));
            payment.setAmountPaid(BigDecimal.valueOf(customerPaid));
            payment.setChangeAmount(BigDecimal.valueOf(changeAmount));
            payment.setPaidAt(LocalDateTime.now());
            paymentService.save(payment);

            if (isFirstPaymentForOrder) {
                paymentService.deductStockAfterPayment(orderId);

                // Record applied promotions to OrderPromotion table
                try {
                    List<OrderItem> currentItems = orderItemService.findByOrder(order);
                    List<PaymentDTO.OrderItemDTO> cartItems = currentItems.stream()
                            .filter(oi -> oi.getProduct() != null)
                            .map(oi -> {
                                PaymentDTO.OrderItemDTO dto = new PaymentDTO.OrderItemDTO();
                                dto.setOrderId(order.getOrderId());
                                dto.setProductId(oi.getProduct().getProductId());
                                dto.setQuantity(oi.getQuantity());
                                return dto;
                            }).collect(Collectors.toList());

                    PaymentDTO.PaymentSummary summary = posService.calculatePromotion(cartItems);
                    if (summary.getItems() != null) {
                        for (PaymentDTO.PaymentItem pi : summary.getItems()) {
                            if (pi.getPromotionId() != null && pi.getDiscountAmount().compareTo(BigDecimal.ZERO) > 0) {
                                promotionRepository.findById(pi.getPromotionId()).ifPresent(promo -> {
                                    OrderPromotion op = new OrderPromotion();
                                    op.setOrder(order);
                                    op.setPromotion(promo);
                                    op.setDiscountAmount(pi.getDiscountAmount());
                                    orderPromotionRepository.save(op);
                                });
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error saving promotions: " + e.getMessage());
                }
            }

            // Tạo PosReceipt sau khi thanh toán thành công
            PosReceipt receipt = new PosReceipt();
            receipt.setOrder(order);
            receipt.setReceiptNumber("RCP-" + orderId + "-" + System.currentTimeMillis());
            receipt.setPrintedAt(LocalDateTime.now());
            receipt.setPrintedBy(order.getEmployee()); // cashier = người tạo order
            posReceiptService.save(receipt);

            // Lấy pointsUsed
            Object rawPts = body.get("pointsUsed");
            Integer pointsUsed = (rawPts != null && !String.valueOf(rawPts).trim().isEmpty())
                    ? Integer.valueOf(String.valueOf(rawPts).trim()) : 0;
            //Call service
            customerService.updateCustomerAfterPayment(orderId, customerId, totalPaid , pointsUsed);

            session.removeAttribute(SESSION_CART_ORDER_JSON);
            session.removeAttribute(SESSION_CURRENT_ORDER_ID);

            resp.put("success", true);
            resp.put("orderId", orderId);
            return ResponseEntity.ok(resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.put("success", false);
            resp.put("errorMessage", ex.getMessage());
            return ResponseEntity.status(500).body(resp);
        }
    }

    /* ================================================================
       CASH PAYMENT (từ PaymentService flow)
       POST /pos/payment/cash
       ================================================================ */
    @PostMapping("/cash")
    public String payCash(@RequestParam String paymentSessionId) {
        paymentService.payCash(paymentSessionId);
        return "redirect:/pos";
    }

    /* ================================================================
       CREATE QR
       POST /pos/payment/qr
       ================================================================ */

    @PostMapping("/qr")
    @ResponseBody
    public ResponseEntity<?> createQR(@RequestBody PaymentRequest request) {
        String validationError = paymentService.validateStockBeforePayment(request.getOrderId());
        if (validationError != null) {
            return ResponseEntity.badRequest().body(Map.of("errorMessage", validationError));
        }
        return ResponseEntity.ok(paymentService.createQR(request));
    }

    /* ================================================================
       POLL PAYMENT STATUS
       GET /pos/payment/status?paymentSessionId=xxx
       ================================================================ */
    @GetMapping("/status")
    @ResponseBody
    public ResponseEntity<String> getStatus(@RequestParam String paymentSessionId) {
        PaymentStatus status = paymentService.getPaymentStatus(paymentSessionId);
        if (status == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(status.name());
    }

    /* ================================================================
       CHECK GATEWAY AVAILABILITY
       GET /pos/payment/gateway-status
       ================================================================ */
    @GetMapping("/gateway-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> gatewayStatus() {
        Map<String, Object> resp = new HashMap<>();
        try {
            boolean available = paymentGateway.isAvailable();
            resp.put("available", available);
            resp.put("message", available ? "PayOS is operational" : "PayOS is currently unavailable");
        } catch (Exception e) {
            resp.put("available", false);
            resp.put("errorMessage", "Gateway check failed: " + e.getMessage());
        }
        return ResponseEntity.ok(resp);
    }

    /* ================================================================
       PAYOS RETURN URL — khách được redirect về sau khi thanh toán
       GET /pos/payment/banking-return?orderCode=xxx&status=PAID&...
       ================================================================ */
    @GetMapping("/banking-return")
    public String bankingReturn(@RequestParam(required = false) String orderCode,
                                @RequestParam(required = false) String status,
                                Model model) {
        model.addAttribute("orderCode", orderCode);
        model.addAttribute("payosStatus", status);
        // Redirect về POS, polling JS sẽ tự detect PAID qua /status endpoint
        return "redirect:/pos";
    }

    /* ================================================================
       PAYOS CANCEL URL — khách bấm huỷ trên trang PayOS
       GET /pos/payment/banking-cancel?orderCode=xxx
       ================================================================ */
    @GetMapping("/banking-cancel")
    public String bankingCancel(@RequestParam(required = false) String orderCode) {
        // Chỉ redirect về POS; payment vẫn PENDING/CANCELLED trong DB
        return "redirect:/pos";
    }
}