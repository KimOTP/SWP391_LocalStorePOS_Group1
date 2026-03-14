package com.swp391pos.controller.pos;

import com.swp391pos.entity.PosReceipt;
import com.swp391pos.enums.OrderStatusName;
import com.swp391pos.service.PosReceiptService;
import com.swp391pos.service.PaymentService;
import com.swp391pos.entity.Payment;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Map;
import java.util.List;

@Controller
@RequestMapping("/pos/receipts")
public class ReceiptController {

    @Autowired
    private PosReceiptService posReceiptService;

    @Autowired
    private PaymentService paymentService;

    /* --------------------------------------------------------
       GET /pos/receipts  →  render manage receipt page
       -------------------------------------------------------- */
    @GetMapping("")
    public String manageReceipt(Model model) {
        model.addAttribute("receipts",     posReceiptService.getAllReceiptRows());
        model.addAttribute("totalBill",    posReceiptService.countAll());
        model.addAttribute("totalRevenue", posReceiptService.sumRevenue());
        model.addAttribute("pending",      posReceiptService.countByOrderStatus(OrderStatusName.PENDING_PAYMENT));
        model.addAttribute("completed",    posReceiptService.countByOrderStatus(OrderStatusName.PAID));
        model.addAttribute("cancelled",    posReceiptService.countByOrderStatus(OrderStatusName.CANCELLED));
        model.addAttribute("today",        posReceiptService.countToday());
        return "pos/manager/receipt-manage";
    }

    /* --------------------------------------------------------
       GET /pos/receipts/api/detail/{receiptNumber}  →  JSON
       Trả về thông tin receipt + danh sách OrderItem của order đó
       -------------------------------------------------------- */
    @GetMapping("/api/detail/{receiptNumber}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getReceiptDetail(
            @PathVariable String receiptNumber) {

        Map<String, Object> detail =
                posReceiptService.getDetailByReceiptNumber(receiptNumber);
        if (detail == null) return ResponseEntity.notFound().build();

        // Nếu service chưa tự load items, load thêm từ orderId
        if (!detail.containsKey("items") || detail.get("items") == null) {
            Object orderIdObj = detail.get("orderId");
            if (orderIdObj != null) {
                Long orderId = Long.valueOf(orderIdObj.toString());
                detail.put("items", posReceiptService.getOrderItemsByOrderId(orderId));
            }
        }

        // Load payment info (amountPaid, changeAmount) từ bảng Payment
        Object orderIdObj2 = detail.get("orderId");
        if (orderIdObj2 != null) {
            Long orderId = Long.valueOf(orderIdObj2.toString());
            List<Payment> payments = paymentService.findByOrderId(orderId);
            if (!payments.isEmpty()) {
                // Lấy payment PAID đầu tiên, fallback về payment mới nhất
                Payment p = payments.stream()
                        .filter(pay -> com.swp391pos.enums.PaymentStatus.PAID
                                .equals(pay.getPaymentStatus()))
                        .findFirst()
                        .orElse(payments.get(payments.size() - 1));
                detail.put("customerPayment", p.getAmountPaid());
                detail.put("change",          p.getChangeAmount());
            }
        }

        return ResponseEntity.ok(detail);
    }

    /* --------------------------------------------------------
       GET /pos/receipts/api/print-template  →  JSON from session
       -------------------------------------------------------- */
    @GetMapping("/api/print-template")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getPrintTemplate(HttpSession session) {
        @SuppressWarnings("unchecked")
        Map<String, Object> template =
                (Map<String, Object>) session.getAttribute("SESSION_PRINT_TEMPLATE");
        if (template == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(template);
    }

    /* --------------------------------------------------------
       GET /pos/receipts/print/{receiptNumber}  →  print view
       -------------------------------------------------------- */
    @GetMapping("/print/{receiptNumber}")
    public String printReceipt(@PathVariable String receiptNumber, Model model) {
        PosReceipt receipt = posReceiptService.getByReceiptNumber(receiptNumber);
        model.addAttribute("receipt", receipt);
        return "pos/receipt-print";
    }

    /* --------------------------------------------------------
       GET /pos/receipts/export-excel  →  download Excel
       -------------------------------------------------------- */
    @GetMapping("/export-excel")
    public void exportExcel(HttpServletResponse response) throws Exception {
        posReceiptService.exportToExcel(response);
    }
}