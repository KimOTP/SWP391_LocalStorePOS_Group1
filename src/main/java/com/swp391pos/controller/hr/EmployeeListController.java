package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class EmployeeListController {

    @GetMapping("/manager/employee_list")
    public String employeeList() {
        return "hr/manager/employee_list";
    }
}
