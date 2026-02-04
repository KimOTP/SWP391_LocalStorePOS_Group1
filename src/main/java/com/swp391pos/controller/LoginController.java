package com.swp391pos.controller;

import jakarta.servlet.http.HttpSession;
import com.swp391pos.entity.Account;
import com.swp391pos.repository.AccountRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.password.PasswordEncoder;

@Controller
@RequestMapping("/auth")
public class LoginController {

    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    public LoginController(AccountRepository accountRepository,
                           PasswordEncoder passwordEncoder) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/login")
    public String showLogin() {
        return "auth/login";
    }

    @PostMapping("/login")
    public String doLogin(
            @RequestParam String username,
            @RequestParam String password,
            Model model,
            HttpSession session) {

        Account account = accountRepository.findByUsername(username).orElse(null);

        if (account == null) {
            model.addAttribute("error", "Account does not exist.");
            return "auth/login";
        }

        if (!passwordEncoder.matches(password, account.getPasswordHash())) {
            model.addAttribute("error", "Wrong password");
            return "auth/login";
        }

        if (account.getEmployee() == null) {
            model.addAttribute("error", "Account has no employee info");
            return "auth/login";
        }

        String role = account.getEmployee().getRole();
        session.setAttribute("account", account);
        session.setAttribute("role", role);

        switch (role) {
            case "MANAGER":
                return "hr/manager/profile";
            case "CASHIER":
                return "hr/cashier/profile";
            default:
                model.addAttribute("error", "Invalid role");
                return "auth/login";
        }
    }
}