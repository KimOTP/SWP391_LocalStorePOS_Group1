package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class AttendanceRecordController {

    @GetMapping("/cashier/attendance_record")
    public String attendanceRecord() {
        return "hr/cashier/attendance_record";
    }
}
