package com.swp391pos.service;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final OrderRepository      orderRepository;
    private final OrderItemRepository  orderItemRepository;
    private final EmployeeRepository   employeeRepository;
    private final PaymentRepository    paymentRepository;

    // ─────────────────────────────────────────────────────
    // Public API
    // ─────────────────────────────────────────────────────

    public Map<String, Object> getDailyReport(LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end   = date.atTime(LocalTime.MAX);
        return buildReportData(fetchOrders(start, end, null, null));
    }

    public Map<String, Object> getReportByDateRange(LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end   = endDate.atTime(LocalTime.MAX);
        return buildReportData(fetchOrders(start, end, null, null));
    }

    public Map<String, Object> getReportByCashier(LocalDate startDate, LocalDate endDate,
                                                  Integer employeeId) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end   = endDate.atTime(LocalTime.MAX);
        return buildReportData(fetchOrders(start, end, employeeId, null));
    }

    public Map<String, Object> getReportByPaymentMethod(LocalDate startDate, LocalDate endDate,
                                                        Order.PaymentMethod paymentMethod) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end   = endDate.atTime(LocalTime.MAX);
        return buildReportData(fetchOrders(start, end, null, paymentMethod));
    }

    /** Trả về tất cả nhân viên (dùng cho admin nếu cần). */
    public List<Employee> getAllEmployees() {
        return employeeRepository.findAll();
    }

    /**
     * Chỉ trả về nhân viên có role CASHIER để hiển thị trong filter.
     * Điều chỉnh điều kiện lọc theo trường role/position của entity Employee.
     */
    public List<Employee> getCashiers() {
        return employeeRepository.findAll().stream()
                .filter(e -> e.getRole() != null
                        && "CASHIER".equalsIgnoreCase(e.getRole().toString()))
                .collect(Collectors.toList());
    }

    public Map<String, Object> getDetailedReport(LocalDate date) {
        return getDailyReport(date);
    }

    // ─────────────────────────────────────────────────────
    // Export Excel (Apache POI)
    // ─────────────────────────────────────────────────────

    /**
     * Xuất báo cáo ra file Excel (.xlsx).
     * Trả về byte array để controller ghi vào HttpServletResponse.
     */
    public byte[] exportToExcel(LocalDate startDate, LocalDate endDate) throws IOException {
        Map<String, Object> report = getReportByDateRange(startDate, endDate);

        @SuppressWarnings("unchecked")
        List<Order> orders = (List<Order>) report.getOrDefault("orders", Collections.emptyList());

        try (XSSFWorkbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Báo cáo doanh thu");

            // ── Style: header row
            CellStyle headerStyle = wb.createCellStyle();
            Font headerFont = wb.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);

            // ── Style: currency
            CellStyle currencyStyle = wb.createCellStyle();
            DataFormat fmt = wb.createDataFormat();
            currencyStyle.setDataFormat(fmt.getFormat("#,##0"));

            // ── Tiêu đề báo cáo
            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("BÁO CÁO DOANH THU — "
                    + startDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                    + " đến "
                    + endDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            Font titleFont = wb.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 13);
            CellStyle titleStyle = wb.createCellStyle();
            titleStyle.setFont(titleFont);
            titleCell.setCellStyle(titleStyle);

            // ── Summary
            int r = 2;
            createSummaryRow(sheet, r++, "Tổng doanh thu (₫)",
                    ((BigDecimal) report.get("totalRevenue")).toPlainString(), currencyStyle);
            createSummaryRow(sheet, r++, "Tổng đơn hàng",
                    String.valueOf(report.get("totalOrders")), null);
            createSummaryRow(sheet, r++, "Giá trị TB/đơn vị (₫)",
                    ((BigDecimal) report.get("averageValuePerUnit")).toPlainString(), currencyStyle);
            createSummaryRow(sheet, r++, "Sản phẩm bán chạy",
                    String.valueOf(report.get("bestSellingProduct")), null);

            r++; // Dòng trống

            // ── Header bảng đơn hàng
            String[] headers = { "#", "Mã đơn", "Thu ngân", "Thanh toán", "Thành tiền (₫)", "Thời gian", "Trạng thái" };
            Row headerRow = sheet.createRow(r++);
            for (int i = 0; i < headers.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(headerStyle);
            }

            // ── Data rows
            int idx = 1;
            DateTimeFormatter dtFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            for (Order o : orders) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(idx++);
                row.createCell(1).setCellValue(o.getOrderId());
                row.createCell(2).setCellValue(
                        o.getEmployee() != null ? o.getEmployee().getFullName() : "—");
                String pm = "—";
                if (o.getPaymentMethod() != null) {
                    pm = o.getPaymentMethod() == Order.PaymentMethod.CASH ? "Tiền mặt" : "Chuyển khoản";
                }
                row.createCell(3).setCellValue(pm);

                Cell amtCell = row.createCell(4);
                if (o.getTotalAmount() != null) {
                    amtCell.setCellValue(o.getTotalAmount().doubleValue());
                    amtCell.setCellStyle(currencyStyle);
                }

                row.createCell(5).setCellValue(
                        o.getCreatedAt() != null ? o.getCreatedAt().format(dtFmt) : "—");
                row.createCell(6).setCellValue(
                        o.getOrderStatus() != null ? String.valueOf(o.getOrderStatus().getOrderStatusName()) : "—");
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            wb.write(out);
            return out.toByteArray();
        }
    }

    // ─────────────────────────────────────────────────────
    // Internal helpers
    // ─────────────────────────────────────────────────────

    private List<Order> fetchOrders(LocalDateTime start, LocalDateTime end,
                                    Integer employeeId, Order.PaymentMethod paymentMethod) {
        return orderRepository.findAll().stream()
                .filter(o -> o.getCreatedAt() != null
                        && !o.getCreatedAt().isBefore(start)
                        && !o.getCreatedAt().isAfter(end))
                .filter(o -> o.getOrderStatus() != null
                        && !"CANCELLED".equals(o.getOrderStatus().getOrderStatusName()))
                .filter(o -> employeeId == null
                        || (o.getEmployee() != null
                        && o.getEmployee().getEmployeeId().equals(employeeId)))
                .filter(o -> paymentMethod == null
                        || paymentMethod.equals(o.getPaymentMethod()))
                .collect(Collectors.toList());
    }

    private Map<String, Object> buildReportData(List<Order> orders) {
        Map<String, Object> report = new LinkedHashMap<>();

        BigDecimal totalRevenue = orders.stream()
                .map(Order::getTotalAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Set<Long> orderIds = orders.stream()
                .map(Order::getOrderId)
                .collect(Collectors.toSet());

        Map<Integer, List<OrderItem>> itemsByOrderId = orderItemRepository.findAll().stream()
                .filter(oi -> oi.getOrder() != null
                        && orderIds.contains(oi.getOrder().getOrderId()))
                .collect(Collectors.groupingBy(oi -> Math.toIntExact(oi.getOrder().getOrderId())));

        int totalItems = itemsByOrderId.values().stream()
                .mapToInt(List::size)
                .sum();

        BigDecimal avgPerUnit = BigDecimal.ZERO;
        if (totalItems > 0) {
            avgPerUnit = totalRevenue.divide(BigDecimal.valueOf(totalItems), 0, RoundingMode.HALF_UP);
        }

        String bestSelling = getBestSellingProduct(itemsByOrderId);

        report.put("totalRevenue",        totalRevenue);
        report.put("totalOrders",         orders.size());
        report.put("totalItems",          totalItems);
        report.put("averageValuePerUnit", avgPerUnit);
        report.put("bestSellingProduct",  bestSelling);
        report.put("orders",              orders);

        return report;
    }

    private String getBestSellingProduct(Map<Integer, List<OrderItem>> itemsByOrderId) {
        Map<String, Integer> salesCount = new HashMap<>();
        itemsByOrderId.values().forEach(items ->
                items.forEach(item -> {
                    if (item.getProduct() != null) {
                        String name = item.getProduct().getProductName();
                        salesCount.merge(name, item.getQuantity(), Integer::sum);
                    }
                })
        );
        return salesCount.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("N/A");
    }

    private void createSummaryRow(Sheet sheet, int rowIdx, String label, String value,
                                  CellStyle valueStyle) {
        Row row = sheet.createRow(rowIdx);
        row.createCell(0).setCellValue(label);
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value);
        if (valueStyle != null) valueCell.setCellStyle(valueStyle);
    }
}