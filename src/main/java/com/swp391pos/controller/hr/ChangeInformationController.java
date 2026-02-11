package com.swp391pos.controller.hr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/hr")
public class ChangeInformationController {
    @GetMapping("/common/change_information")
    public String changeInformation() {
        return "hr/common/change_information";
    }
}
