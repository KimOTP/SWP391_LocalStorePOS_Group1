package com.swp391pos.controller.hr;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Attendance;
import com.swp391pos.entity.Employee;
import com.swp391pos.service.AttendanceService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/hr")
public class AttendanceRecordController {

    @Autowired
    private AttendanceService attendanceService;

    @GetMapping("/cashier/attendance_record")
    public String attendanceRecord(
            @RequestParam(defaultValue = "0") int page,
            HttpSession session,
            Model model) {

        Account account = (Account) session.getAttribute("loggedInAccount");

        if (account == null || account.getEmployee() == null) {
            return "redirect:/login";
        }

//        Employee employee = account.getEmployee();

        Pageable pageable = PageRequest.of(page, 5);

        Integer employeeId = account.getEmployee().getEmployeeId();

        Page<Attendance> attendancePage =
                attendanceService.getAttendanceHistory(employeeId, pageable);

        model.addAttribute("attendancePage", attendancePage);
        model.addAttribute("currentPage", page);

        return "hr/cashier/attendance_record";
    }
}