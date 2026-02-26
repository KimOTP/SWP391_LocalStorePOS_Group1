package com.swp391pos.controller.hr;

import com.swp391pos.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/hr")
@RequiredArgsConstructor
public class CreateEmpAccountController {

    private final AccountService accountService;

    // Hiển thị form
    @GetMapping("/create_emp_account")
    public String createEmpAccount() {
        return "hr/manager/create_emp_account";
    }

    // Xử lý submit form
    @PostMapping("/create_emp_account")
    public String createAccount(
            @RequestParam String fullName,
            @RequestParam String username,
            @RequestParam String email,
            @RequestParam String role,
            @RequestParam String password,
            @RequestParam String confirmPassword,
            Model model
    ) {

        String result = accountService.createAccount(
                fullName, username, email, role, password, confirmPassword
        );

        if (!result.equals("success")) {
            model.addAttribute("error", result);
            return "hr/manager/create_emp_account";
        }

        model.addAttribute("success", "Create Successfully!");
        return "hr/manager/create_emp_account";
    }
}