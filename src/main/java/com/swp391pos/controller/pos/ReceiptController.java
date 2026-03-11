package com.swp391pos.controller.pos;

import com.swp391pos.entity.PosReceipt;
import com.swp391pos.enums.OrderStatusName;
import com.swp391pos.service.PosReceiptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletResponse;
import java.util.Map;

@Controller
@RequestMapping("/pos/receipts")
public class ReceiptController {

    @Autowired
    private PosReceiptService posReceiptService;

    /* --------------------------------------------------------
       GET /pos/receipts/manage  →  render manage receipt page
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
       -------------------------------------------------------- */
    @GetMapping("/api/detail/{receiptNumber}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getReceiptDetail(
            @PathVariable String receiptNumber) {

        Map<String, Object> detail =
                posReceiptService.getDetailByReceiptNumber(receiptNumber);
        if (detail == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(detail);
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
