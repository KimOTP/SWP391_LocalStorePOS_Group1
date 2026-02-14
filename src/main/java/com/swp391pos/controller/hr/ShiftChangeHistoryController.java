package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class ShiftChangeHistoryController {

    @GetMapping("/cashier/shift_change_history")
    public String shiftChangeHistory() {
        return "hr/cashier/shift_change_history";
    }
}
