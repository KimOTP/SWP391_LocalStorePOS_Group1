package com.swp391pos.controller.shift;

import com.swp391pos.entity.Account;
import com.swp391pos.entity.Attendance;
import com.swp391pos.entity.Employee;
import com.swp391pos.repository.AttendanceRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/shift")
public class WorkScheduleController {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @GetMapping("/work_schedule")
    public String workSchedule(HttpSession session, Model model) {

        // Lấy account đang login
        Account account = (Account) session.getAttribute("account");

        if (account == null) {
            return "redirect:/login";
        }

        Employee employee = account.getEmployee();

        // Lấy 7 ngày tăng dần từ hôm nay
        List<Attendance> scheduleList =
                attendanceRepository
                        .findTop7ByEmployeeAndWorkDateGreaterThanEqualOrderByWorkDateAsc(
                                employee,
                                LocalDate.now()
                        );

        model.addAttribute("scheduleList", scheduleList);

        return "shift/cashier/work_schedule";
    }
}