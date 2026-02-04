package com.swp391pos.controller;

import jakarta.servlet.http.HttpSession;
import com.swp391pos.entity.Account;
import com.swp391pos.repository.AccountRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.password.PasswordEncoder;

@Controller
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
        return "login";
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
            return "login";
        }

        // ✅ SO SÁNH BẰNG HASH
        if (!passwordEncoder.matches(password, account.getPasswordHash())) {
            model.addAttribute("error", "Wrong password");
            return "login";
        }

        String role = account.getEmployee().getRole();
        session.setAttribute("account", account);
        session.setAttribute("role", role);

        switch (role) {
            case "MANAGER":
                return "manager/home";
            case "CASHIER":
                return "cashier/home";
            case "SUPPLIER":
                return "supplier/home";
            default:
                model.addAttribute("error", "Invalid role");
                return "login";
        }
    }
}