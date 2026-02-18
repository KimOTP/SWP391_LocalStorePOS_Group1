package com.swp391pos.controller.shift;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/shift")
public class AttendanceController {

    @GetMapping("/manager/attendance")
    public String attendance() {
        return "shift/manager/attendance";
    }
}