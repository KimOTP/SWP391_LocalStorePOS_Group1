package com.swp391pos.controller.pos;

import com.swp391pos.entity.Employee;
import com.swp391pos.entity.Order;
import com.swp391pos.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/reports")
@RequiredArgsConstructor
public class reportController {

    private final ReportService reportService;

    /**
     * GET /reports — renders the reports page with today's data pre-loaded.
     *
     * FIX: previously the "orders" list and full report were not passed to model,
     *      so ${report.orders}, ${totalRevenue}, etc. were all empty in JSP.
     */
    @GetMapping("")
    public String showReport(Model model) {
        LocalDate today = LocalDate.now();
        Map<String, Object> report = reportService.getDailyReport(today);

        // Individual keys for the summary cards (used by JSTL EL directly)
        model.addAttribute("totalRevenue",        report.get("totalRevenue"));
        model.addAttribute("totalOrders",         report.get("totalOrders"));
        model.addAttribute("averageValuePerUnit", report.get("averageValuePerUnit"));
        model.addAttribute("bestSellingProduct",  report.get("bestSellingProduct"));
        model.addAttribute("currentDate",          today);
        model.addAttribute("currentDateFormatted", today.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

        // ← FIX: pass the full report so ${report.orders} works in the order table
        model.addAttribute("report", report);

        // Cashier list for the filter panel radio buttons
        List<Employee> employees = reportService.getAllEmployees();
        model.addAttribute("employees", employees);

        return "pos/manager/reports";
    }

    // ─────────────────────────────────────────────────────
    // AJAX endpoints — return JSON consumed by reports.js
    // ─────────────────────────────────────────────────────

    @PostMapping("/api/reports-by-date-range")
    @ResponseBody
    public Map<String, Object> getReportByDateRange(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            Map<String, Object> report = reportService.getReportByDateRange(
                    LocalDate.parse(startDate), LocalDate.parse(endDate));
            return successResponse(report);
        } catch (Exception e) {
            return errorResponse("Error loading date range report: " + e.getMessage());
        }
    }

    @PostMapping("/api/reports-by-cashier")
    @ResponseBody
    public Map<String, Object> getReportByCashier(
            @RequestParam String startDate,
            @RequestParam String endDate,
            @RequestParam Integer cashierId) {
        try {
            Map<String, Object> report = reportService.getReportByCashier(
                    LocalDate.parse(startDate), LocalDate.parse(endDate), cashierId);
            return successResponse(report);
        } catch (Exception e) {
            return errorResponse("Error loading cashier report: " + e.getMessage());
        }
    }

    @PostMapping("/api/reports-by-payment-method")
    @ResponseBody
    public Map<String, Object> getReportByPaymentMethod(
            @RequestParam String startDate,
            @RequestParam String endDate,
            @RequestParam String paymentMethod) {
        try {
            Order.PaymentMethod method = Order.PaymentMethod.valueOf(paymentMethod.toUpperCase());
            Map<String, Object> report = reportService.getReportByPaymentMethod(
                    LocalDate.parse(startDate), LocalDate.parse(endDate), method);
            return successResponse(report);
        } catch (Exception e) {
            return errorResponse("Error loading payment method report: " + e.getMessage());
        }
    }

    @GetMapping("/api/daily-reports")
    @ResponseBody
    public Map<String, Object> getDailyReport(@RequestParam String date) {
        try {
            Map<String, Object> report = reportService.getDailyReport(LocalDate.parse(date));
            return successResponse(report);
        } catch (Exception e) {
            return errorResponse("Error loading daily report: " + e.getMessage());
        }
    }

    @PostMapping("/api/export-excel")
    @ResponseBody
    public Map<String, Object> exportExcel(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            Map<String, Object> report = reportService.getReportByDateRange(
                    LocalDate.parse(startDate), LocalDate.parse(endDate));
            Map<String, Object> response = successResponse(report);
            response.put("message", "Report ready for export");
            return response;
        } catch (Exception e) {
            return errorResponse("Export failed: " + e.getMessage());
        }
    }

    @GetMapping("/api/employees")
    @ResponseBody
    public Map<String, Object> getEmployees() {
        try {
            return successResponse(reportService.getAllEmployees());
        } catch (Exception e) {
            return errorResponse("Error loading employees: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────
    // Response helpers
    // ─────────────────────────────────────────────────────

    private Map<String, Object> successResponse(Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", data);
        return response;
    }

    private Map<String, Object> errorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return response;
    }
}