package com.swp391pos.controller.shift;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/shift")
public class WorkScheduleController {

    @GetMapping("/cashier/work_schedule")
    public String workSchedule() {
        return "shift/cashier/work_schedule";
    }
}
