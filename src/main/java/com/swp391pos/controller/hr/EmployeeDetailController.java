package com.swp391pos.controller.hr;

import com.swp391pos.entity.Employee;
import com.swp391pos.entity.Account;
import com.swp391pos.repository.EmployeeRepository;
import com.swp391pos.repository.AccountRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/hr")
public class EmployeeDetailController {

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    // ==============================
    // GET EMPLOYEE DETAIL
    // ==============================
    @GetMapping("/employee_detail/{id}")
    public String editEmployee(
            @PathVariable("id") Integer id,
            HttpSession session,
            Model model) {

        Employee employee = employeeRepository.findById(id).orElse(null);
        if (employee == null) {
            return "redirect:/hr/employee_list";
        }

        // ===== LẤY ACCOUNT ĐANG LOGIN =====
        Account loggedInAccount =
                (Account) session.getAttribute("loggedInAccount");

        // ===== CHẶN SỬA CHÍNH MÌNH =====
        if (loggedInAccount != null &&
                loggedInAccount.getEmployee() != null &&
                loggedInAccount.getEmployee().getEmployeeId().equals(id)) {

            return "redirect:/hr/employee_list";
        }

        // ===== LẤY ACCOUNT CỦA EMPLOYEE ĐƯỢC CHỌN =====
        Account employeeAccount = accountRepository
                .findByEmployee_EmployeeId(id)
                .orElse(null);

        model.addAttribute("employee", employee);
        model.addAttribute("employeeAccount", employeeAccount);

        return "hr/manager/employee_detail";
    }

    // ==============================
    // SAVE EDIT
    // ==============================
    @PostMapping("/edit_employee")
    public String saveEdit(
            @RequestParam Integer employeeId,
            @RequestParam String fullName,
            @RequestParam String email,
            @RequestParam String role,
            @RequestParam Boolean status,
            @RequestParam String username,
            @RequestParam(required = false) String password,
            HttpSession session,
            Model model) {

        Account loggedInAccount =
                (Account) session.getAttribute("loggedInAccount");

        if (loggedInAccount != null &&
                loggedInAccount.getEmployee() != null &&
                loggedInAccount.getEmployee().getEmployeeId().equals(employeeId)) {

            return "redirect:/hr/employee_list";
        }

        Employee employee = employeeRepository.findById(employeeId).orElse(null);
        if (employee == null) {
            return "redirect:/hr/employee_list";
        }

        Account account = accountRepository
                .findByEmployee_EmployeeId(employeeId)
                .orElse(null);

        // ======================
        // CHECK EMAIL TRÙNG
        // ======================
        if (employeeRepository.existsByEmailAndEmployeeIdNot(email, employeeId)) {

            model.addAttribute("errorMessage", "Email already exists!");
            model.addAttribute("employee", employee);
            model.addAttribute("employeeAccount", account);

            return "hr/manager/employee_detail";
        }

        // ======================
        // CHECK USERNAME TRÙNG
        // ======================
        if (accountRepository.existsByUsernameAndEmployee_EmployeeIdNot(username, employeeId)) {

            model.addAttribute("errorMessage", "Username already exists!");
            model.addAttribute("employee", employee);
            model.addAttribute("employeeAccount", account);

            return "hr/manager/employee_detail";
        }

        // ======================
        // UPDATE EMPLOYEE
        // ======================
        employee.setFullName(fullName);
        employee.setEmail(email);
        employee.setRole(role);
        employee.setStatus(status);

        employeeRepository.save(employee);

        // ======================
        // UPDATE ACCOUNT
        // ======================
        if (account != null) {

            account.setUsername(username);

            if (password != null && !password.trim().isEmpty()) {
                String encodedPassword = passwordEncoder.encode(password);
                account.setPasswordHash(encodedPassword);
            }

            accountRepository.save(account);
        }

        return "redirect:/hr/employee_list";
    }
}