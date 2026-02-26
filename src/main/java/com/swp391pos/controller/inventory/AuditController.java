package com.swp391pos.controller.inventory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import com.swp391pos.service.AuditService;
import com.swp391pos.service.ProductService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/audit")
public class AuditController {
    @Autowired private AuditService auditService;
    @Autowired private ProductService productService; // Giả định service lấy product

    @GetMapping("/add")
    public String showAuditPage(Model model) {
        return "inventory/inventoryStaff/audit-session";
    }
    @GetMapping("/api/products")
    @ResponseBody
    public List<Map<String, Object>> getProductsForModal() {
        return auditService.getAllProductsWithStock();
    }

    @PostMapping("/submit")
    public String submitAudit(@RequestParam String auditDataJson, HttpSession session, RedirectAttributes ra) {
        try {
            Account account = (Account) session.getAttribute("loggedInAccount");
            ObjectMapper mapper = new ObjectMapper();
            List<Map<String, Object>> items = mapper.readValue(auditDataJson, new TypeReference<>(){});

            auditService.saveAuditSession(items, account);
            ra.addFlashAttribute("message", "Audit session submitted successfully!");
            ra.addFlashAttribute("status", "success");
        } catch (Exception e) {
            ra.addFlashAttribute("message", "Error: " + e.getMessage());
            ra.addFlashAttribute("status", "error");
        }
        return "redirect:/audit/add";
    }

    @GetMapping("/details")
    public String viewAuditDetail(@RequestParam Integer id, Model model) {
        AuditSession audit = auditService.getAuditById(id);
        model.addAttribute("audit", audit);
        return "inventory/inventoryStaff/audit-detail";
    }
}
