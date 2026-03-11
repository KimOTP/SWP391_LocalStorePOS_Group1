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

        // ===== CHẶN LOGIN NHIỀU LẦN =====
        if (session.getAttribute("account") != null) {
            return "redirect:/dashboard";
        }

        Account account = accountRepository.findByUsername(username).orElse(null);

        //Check Account
        if (account == null) {
            model.addAttribute("error", "Account does not exist.");
            return "auth/login";
        }

        //Check password
        if (!passwordEncoder.matches(password, account.getPasswordHash())) {
            model.addAttribute("error", "Wrong password");
            return "auth/login";
        }

        //Check employee information
        if (account.getEmployee() == null) {
            model.addAttribute("error", "Account has no employee info");
            return "auth/login";
        }

        //Check Status
        if (Boolean.FALSE.equals(account.getEmployee().getStatus())) {
            model.addAttribute("error", "Your account has been deactivated.");
            return "auth/login";
        }

        String role = account.getEmployee().getRole();

//------------------------------------------------------------------------------------------------------------------
//        // ===== CASHIER CHỈ LOGIN 1 LẦN / NGÀY =====
//        if (role.equals("CASHIER") && account.getLastLogin() != null) {
//
//            LocalDate lastLoginDate = account.getLastLogin().toLocalDate();
//            LocalDate today = LocalDate.now();
//
//            if (lastLoginDate.equals(today)) {
//                model.addAttribute("error", "Cashier can only login once per day.");
//                return "auth/login";
//            }
//        }
//------------------------------------------------------------------------------------------------------------------
        //Lấy thời gian login cũ
        LocalDateTime previousLogin = account.getLastLogin();

        //Lưu vào session
        session.setAttribute("previousLogin", previousLogin);

        //Update login mới
        account.setLastLogin(LocalDateTime.now());
        accountRepository.save(account);

        // ===== CHECK-IN =====
        if (role.equals("CASHIER")) {
            attendanceService.checkIn(account.getEmployee());
        }

        //Lưu account vào session
        session.setAttribute("account", account);
        session.setAttribute("loggedInAccount", account);
        session.setAttribute("role", role);

        return "redirect:/dashboard";
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
