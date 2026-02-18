package com.swp391pos.controller.shift;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/shift")
public class ShiftChangeReqController {

    @GetMapping("/manager/shift_change_req")
    public String shiftChangeReq() {
        return "shift/manager/shift_change_req";
    }
}
