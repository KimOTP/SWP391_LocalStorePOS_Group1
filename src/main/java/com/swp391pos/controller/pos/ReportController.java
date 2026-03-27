package com.swp391pos.controller.pos;

import com.swp391pos.entity.Employee;
import com.swp391pos.entity.Order;
import com.swp391pos.enums.PaymentMethod;
import com.swp391pos.service.ReportService;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    // ─────────────────────────────────────────────────────
    // GET /reports — trang chính, load dữ liệu hôm nay
    // ─────────────────────────────────────────────────────

    @GetMapping("")
    public String showReport(Model model) {
        LocalDate today = LocalDate.now();
        Map<String, Object> report = reportService.getDailyReport(today);

        // Summary cards
        model.addAttribute("totalSales",           report.get("totalRevenue"));
        model.addAttribute("totalOrders",         report.get("totalOrders"));
        model.addAttribute("averageValuePerUnit", report.get("averageValuePerUnit"));
        model.addAttribute("bestSellingProduct",  report.get("bestSellingProduct"));
        model.addAttribute("currentDate",          today);
        model.addAttribute("currentDateFormatted",
                today.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

        // Toàn bộ report (bao gồm orders list cho bảng JSP)
        model.addAttribute("report", report);

        // CHỈ lấy cashier để hiển thị trong filter
        List<Employee> cashiers = reportService.getCashiers();
        model.addAttribute("cashiers", cashiers);

        return "pos/manager/reports";
    }

    // ─────────────────────────────────────────────────────
    // AJAX endpoints
    // ─────────────────────────────────────────────────────

    @PostMapping("/api/reports-by-date-range")
    @ResponseBody
    public Map<String, Object> getReportByDateRange(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            return successResponse(
                    reportService.getReportByDateRange(
                            LocalDate.parse(startDate), LocalDate.parse(endDate)));
        } catch (Exception e) {
            return errorResponse("Lỗi khi tải báo cáo theo ngày: " + e.getMessage());
        }
    }

    @PostMapping("/api/reports-by-cashier")
    @ResponseBody
    public Map<String, Object> getReportByCashier(
            @RequestParam String startDate,
            @RequestParam String endDate,
            @RequestParam Integer cashierId) {
        try {
            return successResponse(
                    reportService.getReportByCashier(
                            LocalDate.parse(startDate), LocalDate.parse(endDate), cashierId));
        } catch (Exception e) {
            return errorResponse("Lỗi khi tải báo cáo theo thu ngân: " + e.getMessage());
        }
    }

    @PostMapping("/api/reports-by-payment-method")
    @ResponseBody
    public Map<String, Object> getReportByPaymentMethod(
            @RequestParam String startDate,
            @RequestParam String endDate,
            @RequestParam String paymentMethod) {
        try {
            PaymentMethod method = PaymentMethod.valueOf(paymentMethod.toUpperCase());
            return successResponse(
                    reportService.getReportByPaymentMethod(
                            LocalDate.parse(startDate), LocalDate.parse(endDate), method));
        } catch (Exception e) {
            return errorResponse("Lỗi khi tải báo cáo theo phương thức thanh toán: " + e.getMessage());
        }
    }

    @GetMapping("/api/daily-reports")
    @ResponseBody
    public Map<String, Object> getDailyReport(@RequestParam String date) {
        try {
            return successResponse(reportService.getDailyReport(LocalDate.parse(date)));
        } catch (Exception e) {
            return errorResponse("Lỗi khi tải báo cáo ngày: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────
    // Export Excel — trả về file .xlsx thật
    // ─────────────────────────────────────────────────────

    @PostMapping("/api/export-excel")
    public void exportExcel(
            @RequestParam String startDate,
            @RequestParam String endDate,
            HttpServletResponse response) {
        try {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end   = LocalDate.parse(endDate);

            byte[] excelBytes = reportService.exportToExcel(start, end);

            String filename = "BaoCaoDoanhThu_"
                    + start.format(DateTimeFormatter.ofPattern("ddMMyyyy"))
                    + "_"
                    + end.format(DateTimeFormatter.ofPattern("ddMMyyyy"))
                    + ".xlsx";

            response.setContentType(
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition",
                    "attachment; filename=\"" + filename + "\"");
            response.setContentLength(excelBytes.length);
            response.getOutputStream().write(excelBytes);
            response.getOutputStream().flush();

        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try {
                response.getWriter().write("Xuất Excel thất bại: " + e.getMessage());
            } catch (IOException ignored) { }
        }
    }

    @GetMapping("/api/employees")
    @ResponseBody
    public Map<String, Object> getEmployees() {
        try {
            // Trả về tất cả employees (dành cho admin API)
            return successResponse(reportService.getAllEmployees());
        } catch (Exception e) {
            return errorResponse("Lỗi khi tải danh sách nhân viên: " + e.getMessage());
        }
    }

    @GetMapping("/api/cashiers")
    @ResponseBody
    public Map<String, Object> getCashiers() {
        try {
            return successResponse(reportService.getCashiers());
        } catch (Exception e) {
            return errorResponse("Lỗi khi tải danh sách thu ngân: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────
    // Response helpers
    // ─────────────────────────────────────────────────────

    private Map<String, Object> successResponse(Object data) {
        Map<String, Object> r = new HashMap<>();
        r.put("success", true);
        // If data is a report map containing raw Order entities, convert orders to safe DTOs
        if (data instanceof Map) {
            @SuppressWarnings("unchecked")
            Map<String, Object> reportMap = new HashMap<>((Map<String, Object>) data);
            Object ordersObj = reportMap.get("orders");
            if (ordersObj instanceof List) {
                @SuppressWarnings("unchecked")
                List<Order> orders = (List<Order>) ordersObj;
                reportMap.put("orders", toOrderDtoList(orders));
            }
            r.put("data", reportMap);
        } else {
            r.put("data", data);
        }
        return r;
    }

    /** Convert Order entity list to plain Map list — avoids @JsonIgnore fields being lost */
    private List<Map<String, Object>> toOrderDtoList(List<Order> orders) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Order o : orders) {
            Map<String, Object> dto = new HashMap<>();
            dto.put("orderId",       o.getOrderId());
            dto.put("totalAmount",   o.getTotalAmount());
            dto.put("createdAt",     o.getCreatedAt() != null ? o.getCreatedAt().toString() : null);
            dto.put("paymentMethod", o.getPaymentMethod() != null ? o.getPaymentMethod().name() : null);

            // Employee (cashier) — normally @JsonIgnore, so we manually map it
            if (o.getEmployee() != null) {
                Map<String, Object> emp = new HashMap<>();
                emp.put("fullName", o.getEmployee().getFullName());
                dto.put("employee", emp);
            } else {
                dto.put("employee", null);
            }

            // OrderStatus — normally @JsonIgnore, so we manually map it
            if (o.getOrderStatus() != null && o.getOrderStatus().getOrderStatusName() != null) {
                Map<String, Object> st = new HashMap<>();
                st.put("orderStatusName", o.getOrderStatus().getOrderStatusName().name());
                dto.put("orderStatus", st);
            } else {
                dto.put("orderStatus", null);
            }

            result.add(dto);
        }
        return result;
    }
    private Map<String, Object> errorResponse(String message) {
        Map<String, Object> r = new HashMap<>();
        r.put("success", false);
        r.put("errorMessage", message);
        return r;
    }
}