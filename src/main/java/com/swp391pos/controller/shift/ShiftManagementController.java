package com.swp391pos.controller.shift;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/shift")
public class ShiftManagementController {

    @GetMapping("/manager/shift_management")
    public String shiftManagement() {
        return "shift/manager/shift_management";
    }
}
