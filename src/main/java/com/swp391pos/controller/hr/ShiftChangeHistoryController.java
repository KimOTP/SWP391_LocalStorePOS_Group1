package com.swp391pos.controller.hr;

import com.swp391pos.entity.*;
import com.swp391pos.repository.ShiftChangeRequestRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/hr")
public class ShiftChangeHistoryController {

    @Autowired
    private ShiftChangeRequestRepository shiftChangeRequestRepository;

    @GetMapping("/cashier/shift_change_history")
    public String shiftChangeHistory(
            @RequestParam(defaultValue = "0") int page,
            HttpSession session,
            Model model
    ) {

        Account account = (Account) session.getAttribute("account");
        if (account == null) return "redirect:/login";

        Employee employee = account.getEmployee();

        Page<ShiftChangeRequest> employeePage =
                shiftChangeRequestRepository
                        .findByEmployeeEmployeeIdOrderByWorkDateDesc(
                                employee.getEmployeeId(),
                                PageRequest.of(page, 5)
                        );

        model.addAttribute("employeePage", employeePage);
        model.addAttribute("currentPage", page);

        return "hr/cashier/shift_change_history";
    }
}