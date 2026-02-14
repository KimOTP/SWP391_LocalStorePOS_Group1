package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class EmployeeDetailController {

    @GetMapping("/manager/employee_detail")
    public String employeeDetail() {
        return "hr/manager/employee_detail";
    }
}
