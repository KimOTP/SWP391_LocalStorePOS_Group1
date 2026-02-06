package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class HrController {

    @GetMapping("/manager/manager-profile")
    public String managerProfile() {
        return "hr/manager/manager-profile";
    }

    @GetMapping("/cashier/cashier-profile")
    public String cashierProfile() {
        return "hr/cashier/cashier-profile";
    }
}

