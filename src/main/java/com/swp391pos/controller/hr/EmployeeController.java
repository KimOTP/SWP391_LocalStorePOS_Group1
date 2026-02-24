package com.swp391pos.controller.hr;

import com.swp391pos.entity.Employee;
import com.swp391pos.repository.EmployeeRepository;
import com.swp391pos.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;

@RequiredArgsConstructor
@Controller
public class EmployeeController {

    private final EmployeeRepository employeeRepository;
    private final AttendanceService attendanceService;

    @PostMapping("/create")
    public String createEmployee(Employee employee) {
        employeeRepository.save(employee);
        attendanceService.generateNext7DaysForAllEmployees();
        return "redirect:/hr/employee";
    }
}
