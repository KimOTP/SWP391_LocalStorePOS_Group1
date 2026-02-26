package com.swp391pos.controller.shift;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.ShiftChangeRequest;
import com.swp391pos.repository.ShiftChangeRequestRepository;
import com.swp391pos.repository.WorkShiftRepository;
import com.swp391pos.service.ShiftChangeService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/shift")
public class ShiftChangeReqController {

    @Autowired
    private ShiftChangeRequestRepository shiftChangeRequestRepository;

    @Autowired
    private WorkShiftRepository workShiftRepository;

    @Autowired
    private ShiftChangeService shiftChangeService;
    // =========================
    // MANAGER VIEW PAGE
    // =========================
    @GetMapping("/shift_change_req")
    public String shiftChangeReq(
            @RequestParam(required = false) String employeeId,
            @RequestParam(required = false) String currentShiftId,
            @RequestParam(required = false) String requestedShiftId,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            Model model) {

        Integer empId = null;
        if (employeeId != null && !employeeId.isBlank()) {
            try {
                empId = Integer.parseInt(employeeId);
            } catch (NumberFormatException e) {
                empId = null;
            }
        }

        Integer curShift = (currentShiftId == null || currentShiftId.isBlank())
                ? null : Integer.parseInt(currentShiftId);

        Integer reqShift = (requestedShiftId == null || requestedShiftId.isBlank())
                ? null : Integer.parseInt(requestedShiftId);

        String finalStatus = (status == null || status.isBlank())
                ? null : status;

        Page<ShiftChangeRequest> requestPage =
                shiftChangeRequestRepository.filterRequests(
                        empId,
                        curShift,
                        reqShift,
                        finalStatus,
                        PageRequest.of(page, 5)
                );

        model.addAttribute("requests", requestPage.getContent());
        model.addAttribute("requestPage", requestPage);
        model.addAttribute("currentPage", page);
        model.addAttribute("shiftList", workShiftRepository.findAll());

        return "shift/manager/shift_change_req";
    }

    // =========================
    // APPROVE
    // =========================

    @PostMapping("/manager/approve")
    public String approveRequest(
            @RequestParam("id") Integer requestId,
            HttpSession session) {

        Account account = (Account) session.getAttribute("account");
        if (account == null) return "redirect:/login";

        shiftChangeService.approveRequest(
                requestId,
                account.getEmployee()
        );

        return "redirect:/shift/shift_change_req";
    }

    // =========================
    // REJECT
    // =========================
    @PostMapping("/manager/reject")
    public String rejectRequest(
            @RequestParam("id") Integer requestId,
            HttpSession session) {

        Account account = (Account) session.getAttribute("account");
        if (account == null) return "redirect:/login";

        ShiftChangeRequest request =
                shiftChangeRequestRepository.findById(requestId).orElse(null);

        if (request == null || !request.getStatus().equals("Pending")) {
            return "redirect:/shift/shift_change_req";
        }

        request.setStatus("Rejected");
        request.setManager(account.getEmployee());
        request.setReviewedAt(LocalDateTime.now());

        shiftChangeRequestRepository.save(request);

        return "redirect:/shift/shift_change_req";
    }
}