package com.swp391pos.controller.shift;

import org.springframework.ui.Model;
import com.swp391pos.entity.Attendance;
import com.swp391pos.repository.AttendanceRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
@RequestMapping("/shift")
public class AttendanceHistoryController {

    private final AttendanceRepository attendanceRepository;

    public AttendanceHistoryController(AttendanceRepository attendanceRepository) {
        this.attendanceRepository = attendanceRepository;
    }

    @GetMapping("/attendance_history")
    public String attendanceHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) String fullName,
            @RequestParam(required = false) String shift,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,
            Model model
    ) {

        Pageable pageable = PageRequest.of(page, 5);

        Page<Attendance> attendancePage = attendanceRepository.searchAttendance(
                fullName,
                shift,
                fromDate,
                toDate,
                status,
                pageable
        );

        model.addAttribute("attendancePage", attendancePage);
        model.addAttribute("currentPage", page);

        // giữ lại filter
        model.addAttribute("fullName", fullName);
        model.addAttribute("shift", shift);
        model.addAttribute("status", status);
        model.addAttribute("fromDate", fromDate);
        model.addAttribute("toDate", toDate);

        return "shift/manager/attendance_history";
    }
}
