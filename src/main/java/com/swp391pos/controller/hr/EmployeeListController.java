package com.swp391pos.controller.hr;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Employee;
import com.swp391pos.repository.AccountRepository;
import com.swp391pos.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/hr")
public class EmployeeListController {

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private AccountRepository accountRepository;

    // ======================
    // LIST + SEARCH + PAGING
    // ======================
    @GetMapping("/employee_list")
    public String employeeList(
            @RequestParam(required = false) String fullName,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) Boolean status,
            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate creationDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "employeeId") String sortField,
            @RequestParam(defaultValue = "desc") String sortDir,
            Model model
    ) {

        Sort sort = sortDir.equals("asc") ?
                Sort.by(sortField).ascending() :
                Sort.by(sortField).descending();

        Pageable pageable = PageRequest.of(page, 5, sort);

        // ======================
        // FIX DATE FILTER HERE
        // ======================
        LocalDateTime from = null;
        LocalDateTime to = null;

        if (creationDate != null) {
            from = creationDate.atStartOfDay();
            to = creationDate.plusDays(1).atStartOfDay();
        }

        Page<Employee> employeePage = employeeRepository.searchEmployee(
                fullName == null || fullName.isBlank() ? null : fullName,
                role == null || role.isBlank() ? null : role,
                status,
                from,
                to,
                pageable
        );

        model.addAttribute("employeePage", employeePage);
        model.addAttribute("employees", employeePage.getContent());

        List<Account> accounts = accountRepository.findAll();
        model.addAttribute("accounts", accounts);

        model.addAttribute("currentPage", page);
        model.addAttribute("sortField", sortField);
        model.addAttribute("sortDir", sortDir);

        return "hr/manager/employee_list";
    }

    // ======================
    // UPDATE EMPLOYEE
    // ======================
    @PostMapping("/update_employee")
    public String updateEmployee(Employee employee) {

        employeeRepository.save(employee);

        return "redirect:/hr/manager/employee_list";
    }
}