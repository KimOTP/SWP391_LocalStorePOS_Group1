package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class CreateEmpAccountController {

    @GetMapping("/manager/create_emp_account")
    public String createEmpAccount() {
        return "hr/manager/create_emp_account";
    }
}