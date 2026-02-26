package com.swp391pos.controller.shift;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Employee;
import com.swp391pos.entity.ShiftChangeRequest;
import com.swp391pos.repository.ShiftChangeRequestRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/shift")
public class ShiftChangeReqController {

    @Autowired
    private ShiftChangeRequestRepository shiftChangeRequestRepository;

    // =========================
    // CASHIER - VIEW HISTORY
    // =========================
//    @GetMapping("/cashier/shift_change_history")
//    public String viewShiftHistory(
//            @RequestParam(defaultValue = "0") int page,
//            HttpSession session,
//            Model model) {
//
//        Account account = (Account) session.getAttribute("account");
//
//        if (account == null) {
//            return "redirect:/login";
//        }
//
//        Employee employee = account.getEmployee();
//
//        PageRequest pageable = PageRequest.of(page, 5); // 5 record / page
//
//        Page<ShiftChangeRequest> historyPage =
//                shiftChangeRequestRepository
//                        .findByEmployeeOrderByWorkDateDesc(employee, pageable);
//
//        model.addAttribute("employeePage", historyPage);
//        model.addAttribute("currentPage", page);
//
//        return "shift/cashier/shift_change_history";
//    }

    // =========================
    // MANAGER PAGE
    // =========================
    @GetMapping("/manager/shift_change_req")
    public String shiftChangeReq() {
        return "shift/manager/shift_change_req";
    }
}