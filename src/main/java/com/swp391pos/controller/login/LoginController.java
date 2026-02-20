package com.swp391pos.controller.login;

import jakarta.servlet.http.HttpSession;
import com.swp391pos.entity.Account;
import com.swp391pos.repository.AccountRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;

//@Controller
//@RequestMapping("/auth")
//public class LoginController {
//
//    private final AccountRepository accountRepository;
//    private final PasswordEncoder passwordEncoder;
//
//    public LoginController(AccountRepository accountRepository,
//                           PasswordEncoder passwordEncoder) {
//        this.accountRepository = accountRepository;
//        this.passwordEncoder = passwordEncoder;
//    }
//
//    @GetMapping("/login")
//    public String showLogin() {
//        return "auth/login";
//    }
//
//    @PostMapping("/login")
//    public String doLogin(
//            @RequestParam String username,
//            @RequestParam String password,
//            Model model,
//            HttpSession session) {
//
//        Account account = accountRepository.findByUsername(username).orElse(null);
//
//        if (account == null) {
//            model.addAttribute("error", "Account does not exist.");
//            return "auth/login";
//        }
//
//        if (!passwordEncoder.matches(password, account.getPasswordHash())) {
//            model.addAttribute("error", "Wrong password");
//            return "auth/login";
//        }
//
//        if (account.getEmployee() == null) {
//            model.addAttribute("error", "Account has no employee info");
//            return "auth/login";
//        }
//
//        String role = account.getEmployee().getRole();
//        session.setAttribute("account", account);
//        session.setAttribute("role", role);
//
//        switch (role) {
//            case "MANAGER":
//                return "hr/manager/manager-profile";
//            case "CASHIER":
//                return "hr/cashier/cashier-profile";
//            default:
//                model.addAttribute("error", "Invalid role");
//                return "auth/login";
//        }
//    }
//}

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
        //Lấy thời gian login cũ
        LocalDateTime previousLogin = account.getLastLogin();

        //Lưu vào session
        session.setAttribute("previousLogin", previousLogin);

        //Update login mới
        account.setLastLogin(LocalDateTime.now());
        accountRepository.save(account);

        //Lưu account vào session
        session.setAttribute("account", account);
        session.setAttribute("loggedInAccount", account);
        session.setAttribute("role", role);

        switch (role) {
            case "MANAGER":
                return "redirect:/hr/manager/manager_profile";
            case "CASHIER":
                return "redirect:/hr/cashier/cashier_profile";
            default:
                model.addAttribute("error", "Invalid role");
                return "auth/login";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();   //huỷ toàn bộ session
        return "redirect:/auth/login";
    }

}
