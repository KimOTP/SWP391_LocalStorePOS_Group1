package com.swp391pos.controller.shift;

import com.swp391pos.entity.*;
import com.swp391pos.repository.*;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.time.LocalDate;

@Controller
@RequestMapping("/shift")
public class ChangeShiftController {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private WorkShiftRepository workShiftRepository;

    @Autowired
    private ShiftChangeRequestRepository shiftChangeRequestRepository;

    // =========================
    // LOAD FORM
    // =========================

    @GetMapping("/cashier/change_shift")
    public String showChangeShiftPage(
            @RequestParam(value = "date", required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate workDate,
            HttpSession session,
            Model model
    ) {

        Account account = (Account) session.getAttribute("account");
        if (account == null) return "redirect:/login";

        Employee employee = account.getEmployee();

        // 🔥 Nếu chưa có date → mặc định hôm nay
        if (workDate == null) {
            workDate = LocalDate.now();
        }

        Attendance attendance =
                attendanceRepository
                        .findByEmployeeEmployeeIdAndWorkDate(
                                employee.getEmployeeId(),
                                workDate
                        )
                        .orElse(null);

        if (attendance != null) {
            model.addAttribute("currentShift",
                    attendance.getShift().getShiftName());
        } else {
            model.addAttribute("currentShift", "No shift assigned");
        }

        model.addAttribute("selectedDate", workDate);

        return "shift/cashier/change_shift";
    }


    // =========================
    // SUBMIT REQUEST
    // =========================
    @PostMapping("/cashier/change_shift")
    public String sendShiftRequest(
            @RequestParam("workDate") LocalDate workDate,
            @RequestParam("requestedShift") String requestedShiftName,
            @RequestParam("reason") String reason,
            HttpSession session,
            RedirectAttributes redirectAttributes
    ) {

        Account account = (Account) session.getAttribute("account");
        if (account == null) return "redirect:/login";

        Employee employee = account.getEmployee();

        LocalDate today = LocalDate.now();
        LocalDate maxDate = today.plusDays(7);

        // Nếu vượt quá phạm vi
        if (workDate.isBefore(today) || workDate.isAfter(maxDate)) {

            redirectAttributes.addFlashAttribute("error",
                    "You can only request within 7 days from today!");

            return "redirect:/shift/cashier/change_shift?date=" + today;
        }

        Attendance attendance =
                attendanceRepository
                        .findByEmployeeEmployeeIdAndWorkDate(
                                employee.getEmployeeId(),
                                workDate
                        )
                        .orElse(null);

        if (attendance == null) {
            redirectAttributes.addFlashAttribute("error",
                    "No shift found for this date!");

            return "redirect:/shift/cashier/change_shift?date=" + workDate;
        }

        WorkShift requestedShift =
                workShiftRepository
                        .findByShiftName(requestedShiftName)
                        .orElse(null);

        if (requestedShift == null) {
            redirectAttributes.addFlashAttribute("error",
                    "Shift not found!");

            return "redirect:/shift/cashier/change_shift?date=" + workDate;
        }

        if (attendance.getShift().getShiftId()
                .equals(requestedShift.getShiftId())) {

            redirectAttributes.addFlashAttribute("error",
                    "You are already assigned to this shift!");

            return "redirect:/shift/cashier/change_shift?date=" + workDate;
        }

        ShiftChangeRequest request = new ShiftChangeRequest();
        request.setEmployee(employee);
        request.setWorkDate(workDate);
        request.setCurrentShift(attendance.getShift());
        request.setRequestedShift(requestedShift);
        request.setReason(reason);
        request.setStatus("Pending");

        shiftChangeRequestRepository.save(request);

        redirectAttributes.addFlashAttribute("success",
                "Request sent successfully!");

        return "redirect:/shift/cashier/change_shift?date=" + workDate;
    }
}