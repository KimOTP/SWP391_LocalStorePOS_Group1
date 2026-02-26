package com.swp391pos.controller.inventory;

import com.swp391pos.entity.Account;
import com.swp391pos.service.ApprovalService;
import com.swp391pos.service.InventoryLogService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/inventory")
public class ApprovalController {
    @Autowired private ApprovalService approvalService;
    @Autowired private InventoryLogService logService;

    @GetMapping("/approval/queue")
    public String showQueue(Model model) {
        List<Map<String, Object>> unifiedQueue = approvalService.getAllPendingApprovals();
        model.addAttribute("pendingRequests", unifiedQueue);
        model.addAttribute("totalCount", unifiedQueue.size());
        return "inventory/manager/approval-queue";
    }

    @PostMapping("/approval/action")
    public String handleAction(@RequestParam String type, @RequestParam Integer id,
                               @RequestParam boolean approve, HttpSession session) {
        Account acc = (Account) session.getAttribute("loggedInAccount");
        approvalService.processApproval(type, id, approve, acc);
        return "redirect:/inventory/approval/queue";
    }
    @GetMapping("/log/show")
    public String showLogs(Model model) {
        List<Map<String, Object>> logs = logService.getAllInventoryLogs();

        model.addAttribute("logList", logs);
        model.addAttribute("totalCount", logs.size());
        model.addAttribute("countSI", logs.stream().filter(m -> "Stock-in".equals(m.get("type"))).count());
        model.addAttribute("countSO", logs.stream().filter(m -> "Stock-out".equals(m.get("type"))).count());
        model.addAttribute("countAU", logs.stream().filter(m -> "Audit".equals(m.get("type"))).count());

        return "inventory/manager/inventory-logs";
    }
}
