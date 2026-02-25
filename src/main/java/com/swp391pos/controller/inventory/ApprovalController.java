package com.swp391pos.controller.inventory;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.StockIn;
import com.swp391pos.service.ApprovalService;
import com.swp391pos.service.StockInService;
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
}
