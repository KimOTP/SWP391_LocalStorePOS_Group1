package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class HrController {

    @GetMapping("/manager/manager_profile")
    public String managerProfile() {
        return "hr/manager/manager_profile";
    }

    @GetMapping("/cashier/cashier_profile")
    public String cashierProfile() {
        return "hr/cashier/cashier_profile";
    }
}

