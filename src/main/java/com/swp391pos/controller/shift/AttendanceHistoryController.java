package com.swp391pos.controller.shift;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/shift")
public class AttendanceHistoryController {

    @GetMapping("/manager/attendance_history")
    public String attendanceHistory() {
        return "shift/manager/attendance_history";
    }
}
