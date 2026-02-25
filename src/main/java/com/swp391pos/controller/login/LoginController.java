package com.swp391pos.controller.login;

import com.swp391pos.service.AttendanceService;
import jakarta.servlet.http.HttpSession;
import com.swp391pos.entity.Account;
import com.swp391pos.repository.AccountRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import com.swp391pos.repository.AttendanceRepository;
import java.time.LocalDate;

@Controller
@RequestMapping("/auth")
public class LoginController {

    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final AttendanceRepository attendanceRepository;
    private final AttendanceService attendanceService;

    public LoginController(AccountRepository accountRepository,
                           PasswordEncoder passwordEncoder,
                           AttendanceRepository attendanceRepository,
                           AttendanceService attendanceService) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
        this.attendanceRepository = attendanceRepository;
        this.attendanceService = attendanceService;
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

        // ===== CHECK-IN =====
        if (!role.equals("MANAGER")) {
            attendanceService.checkIn(account.getEmployee());
        }

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

        Account account = (Account) session.getAttribute("account");

        if (account != null && account.getEmployee() != null) {

            attendanceRepository
                    .findByEmployeeAndWorkDate(account.getEmployee(), LocalDate.now())
                    .ifPresent(attendance -> {

                        LocalDateTime now = LocalDateTime.now();
                        attendance.setCheckOutTime(now);

                        // ===== TÍNH VỀ SỚM =====
                        if (attendance.getShift() != null) {
                            attendance.setIsEarlyLeave(
                                    now.toLocalTime()
                                            .isBefore(attendance.getShift().getEndTime())
                            );
                        }

                        attendanceRepository.save(attendance);
                    });
        }
        session.invalidate();
        return "redirect:/auth/login";
    }
}
