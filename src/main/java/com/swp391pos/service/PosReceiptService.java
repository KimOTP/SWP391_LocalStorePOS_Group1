package com.swp391pos.service;

import com.swp391pos.entity.PosReceipt;
import com.swp391pos.enums.OrderStatusName;
import com.swp391pos.enums.PaymentMethod;
import com.swp391pos.repository.PosReceiptRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PosReceiptService {

    @Autowired
    private PosReceiptRepository posReceiptRepository;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /* ----------------------------------------------------------------
       Basic queries
       ---------------------------------------------------------------- */

    public List<PosReceipt> getAllReceipts() {
        return posReceiptRepository.findAllWithDetails();
    }

    public PosReceipt getByReceiptNumber(String receiptNumber) {
        return posReceiptRepository.findByReceiptNumber(receiptNumber).orElse(null);
    }

    /* ----------------------------------------------------------------
       Stat counts
       ---------------------------------------------------------------- */

    public long countAll() {
        return posReceiptRepository.count();
    }

    /**
     * @param statusName – OrderStatusName enum value, e.g. OrderStatusName.PENDING
     */
    public long countByOrderStatus(OrderStatusName statusName) {
        return posReceiptRepository.countByOrderStatusName(statusName);
    }

    public long countToday() {
        LocalDateTime start = LocalDate.now().atStartOfDay();
        LocalDateTime end   = start.plusDays(1);
        return posReceiptRepository.countByPrintedAtBetween(start, end);
    }

    public BigDecimal sumRevenue() {
        BigDecimal total = posReceiptRepository.sumRevenueByOrderStatusName(OrderStatusName.PAID);
        return total != null ? total : BigDecimal.ZERO;
    }

    /* ----------------------------------------------------------------
       Detail map – returned as JSON from the API endpoint
       ---------------------------------------------------------------- */

    public Map<String, Object> getDetailByReceiptNumber(String receiptNumber) {
        PosReceipt receipt = getByReceiptNumber(receiptNumber);
        if (receipt == null) return null;

        Map<String, Object> detail = new HashMap<>();

        // PosReceipt fields
        detail.put("receiptNumber", receipt.getReceiptNumber());
        detail.put("printedAt", receipt.getPrintedAt() != null
                ? receipt.getPrintedAt().format(DATETIME_FMT) : "—");
        detail.put("printedBy", receipt.getPrintedBy() != null
                ? receipt.getPrintedBy().getFullName() : "—");

        // Order fields
        var order = receipt.getOrder();
        if (order != null) {
            // Status label from OrderStatus.orderStatusName (enum OrderStatusName)
            OrderStatusName statusEnum = order.getOrderStatus() != null
                    ? order.getOrderStatus().getOrderStatusName() : null;
            String statusName = statusEnum != null ? statusEnum.name() : "—";
            detail.put("orderStatus",   statusName);
            detail.put("statusLabel",   resolveStatusLabel(statusEnum));

            // Payment method (enum)
            PaymentMethod pm = order.getPaymentMethod();
            detail.put("paymentMethod", pm != null ? pm.name() : "—");

            // Customer (nullable – walk-in guest allowed)
            detail.put("customerName", order.getCustomer() != null
                    ? order.getCustomer().getFullName() : "Guest");

            // Cashier from Order.employee
            detail.put("cashierName", order.getEmployee() != null
                    ? order.getEmployee().getFullName() : "—");

            // Created date
            detail.put("createdAt", order.getCreatedAt() != null
                    ? order.getCreatedAt().format(DATE_FMT) : "—");

            // Amounts (BigDecimal – serialized as number in JSON)
            detail.put("subtotal",  order.getTotalAmount());
            detail.put("discount",  order.getDiscountAmount() != null
                    ? order.getDiscountAmount() : BigDecimal.ZERO);

            // NOTE: Order entity has no customerPayment / changeAmount columns.
            // Set to null so the modal shows "—" for those fields.
            detail.put("customerPayment", null);
            detail.put("change",          null);

            // Order items – only available if you add @OneToMany on Order
            detail.put("items", List.of());
        }

        return detail;
    }

    /* ----------------------------------------------------------------
       Export Excel
       ---------------------------------------------------------------- */

    public void exportToExcel(HttpServletResponse response) throws IOException {
        List<PosReceipt> receipts = getAllReceipts();

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Receipts");

            // Header
            String[] cols = {
                    "Receipt Number", "Printed At", "Printed By",
                    "Order ID", "Customer", "Cashier",
                    "Payment Method", "Total Amount", "Discount", "Status"
            };
            Row header = sheet.createRow(0);
            CellStyle headerStyle = workbook.createCellStyle();
            Font font = workbook.createFont();
            font.setBold(true);
            headerStyle.setFont(font);
            for (int i = 0; i < cols.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(cols[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            int rowIdx = 1;
            for (PosReceipt r : receipts) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(r.getReceiptNumber());
                row.createCell(1).setCellValue(r.getPrintedAt() != null
                        ? r.getPrintedAt().format(DATETIME_FMT) : "");
                row.createCell(2).setCellValue(r.getPrintedBy() != null
                        ? r.getPrintedBy().getFullName() : "");

                var order = r.getOrder();
                if (order != null) {
                    row.createCell(3).setCellValue(
                            order.getOrderId() != null ? order.getOrderId() : 0);
                    row.createCell(4).setCellValue(order.getCustomer() != null
                            ? order.getCustomer().getFullName() : "Guest");
                    row.createCell(5).setCellValue(order.getEmployee() != null
                            ? order.getEmployee().getFullName() : "");
                    row.createCell(6).setCellValue(order.getPaymentMethod() != null
                            ? order.getPaymentMethod().name() : "");
                    row.createCell(7).setCellValue(order.getTotalAmount() != null
                            ? order.getTotalAmount().doubleValue() : 0);
                    row.createCell(8).setCellValue(order.getDiscountAmount() != null
                            ? order.getDiscountAmount().doubleValue() : 0);
                    row.createCell(9).setCellValue(order.getOrderStatus() != null
                            ? order.getOrderStatus().getOrderStatusName().name() : "");
                }
            }

            for (int i = 0; i < cols.length; i++) sheet.autoSizeColumn(i);

            response.setContentType(
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition",
                    "attachment; filename=receipts.xlsx");
            workbook.write(response.getOutputStream());
        }
    }

    /* ----------------------------------------------------------------
       Helpers
       ---------------------------------------------------------------- */

    private String resolveStatusLabel(OrderStatusName status) {
        if (status == null) return "—";
        return switch (status) {
            case DRAFT -> "Create order";
            case PAID -> "Payment has been made.";
            case PENDING_PAYMENT   -> "Awaiting confirmation";
            case CANCELLED -> "Cancelled";
        };
    }
}