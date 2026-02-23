package com.swp391pos.controller.hr;

import com.swp391pos.entity.Account;
import com.swp391pos.repository.AccountRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
@RequestMapping("/hr")
public class HrController {

    private final AccountRepository accountRepository;

    public HrController(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    @GetMapping("/manager/manager_profile")
    public String managerProfile(HttpSession session, Model model) {

        Account sessionAccount = (Account) session.getAttribute("account");

        if (sessionAccount == null) {
            return "redirect:/login";
        }

        Account account = accountRepository
                .findById(sessionAccount.getAccountId())
                .orElse(null);

        model.addAttribute("account", account);
//------------------
        LocalDateTime previousLogin =
                (LocalDateTime) session.getAttribute("previousLogin");

        String lastLoginFormatted;

        if (previousLogin != null) {
            DateTimeFormatter formatter =
                    DateTimeFormatter.ofPattern("dd/MM/yyyy - HH:mm");
            lastLoginFormatted = previousLogin.format(formatter);
        } else {
            lastLoginFormatted = "First time login";
        }

        model.addAttribute("lastLoginFormatted", lastLoginFormatted);
//----------------
        return "hr/manager/manager_profile";
    }

    @GetMapping("/cashier/cashier_profile")
    public String cashierProfile(HttpSession session, Model model) {

        Account sessionAccount = (Account) session.getAttribute("account");

        if (sessionAccount == null) {
            return "redirect:/login";
        }

        Account account = accountRepository
                .findById(sessionAccount.getAccountId())
                .orElse(null);

        model.addAttribute("account", account);
//------------------
        LocalDateTime previousLogin =
                (LocalDateTime) session.getAttribute("previousLogin");

        String lastLoginFormatted;

        if (previousLogin != null) {
            DateTimeFormatter formatter =
                    DateTimeFormatter.ofPattern("dd/MM/yyyy - HH:mm");
            lastLoginFormatted = previousLogin.format(formatter);
        } else {
            lastLoginFormatted = "First time login";
        }

        model.addAttribute("lastLoginFormatted", lastLoginFormatted);
//----------------
        return "hr/cashier/cashier_profile";
    }
}
