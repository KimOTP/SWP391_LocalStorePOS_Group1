package com.swp391pos.controller.pos;

import com.swp391pos.dto.PaymentRequest;
import com.swp391pos.dto.PaymentResponse;
import com.swp391pos.entity.Order;
import com.swp391pos.entity.OrderStatus;
import com.swp391pos.entity.Payment;
import com.swp391pos.enums.PaymentMethod;
import com.swp391pos.enums.PaymentStatus;
import com.swp391pos.service.OrderService;
import com.swp391pos.service.OrderStatusService;
import com.swp391pos.service.PaymentService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/pos/payment")
@RequiredArgsConstructor
public class PaymentController {

    private static final String SESSION_CART_ORDER_JSON = "posCurrentOrderJson";

    private final PaymentService paymentService;
    private final OrderService orderService;
    private final OrderStatusService orderStatusService;

    /* ================================================================
       PAYMENT PAGE
       GET /pos/payment?orderId=xxx
       ================================================================ */
    @GetMapping
    public String showPayment(@RequestParam Long orderId,
                              Model model,
                              HttpSession session) {
        Order order = orderService.findById(orderId);
        model.addAttribute("order",      order);
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
            String paymentMethod = String.valueOf(body.getOrDefault("paymentMethod", "CASH"));
            double totalPaid     = ((Number) body.getOrDefault("totalPaid", 0)).doubleValue();

            Order order = orderService.findById(orderId);

            OrderStatus completed = orderStatusService.findByOrderStatusName(
                    OrderStatus.OrderStatusName.valueOf("PAID"));
            order.setOrderStatus(completed);
            order.setPaidAt(LocalDateTime.now());

            // Map enums.PaymentMethod → Order.PaymentMethod để report đọc được
            Order.PaymentMethod orderPayMethod = paymentMethod.equalsIgnoreCase("BANKING")
                    ? Order.PaymentMethod.ONLINE
                    : Order.PaymentMethod.CASH;
            order.setPaymentMethod(orderPayMethod);
            orderService.save(order);

            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setPaymentSessionId(UUID.randomUUID().toString());
            payment.setPaymentMethod(PaymentMethod.valueOf(paymentMethod.toUpperCase()));
            payment.setPaymentStatus(PaymentStatus.PAID);
            payment.setAmount(BigDecimal.valueOf(totalPaid));
            payment.setPaidAt(LocalDateTime.now());
            paymentService.save(payment);

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
    public PaymentResponse createQR(@RequestBody PaymentRequest request) {
        return paymentService.createQR(request);
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
}