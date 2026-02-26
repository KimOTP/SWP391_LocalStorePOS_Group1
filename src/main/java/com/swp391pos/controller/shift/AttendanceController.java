package com.swp391pos.controller.shift;

import com.swp391pos.entity.WorkShift;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.ui.Model;
import com.swp391pos.entity.Attendance;
import com.swp391pos.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/shift")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    @PostMapping("/attendance/update")
    @ResponseBody
    public void update(@RequestBody Map<String, String> data) {

        Integer attendanceId = Integer.parseInt(data.get("attendanceId"));
        Integer shiftId = Integer.parseInt(data.get("shiftId"));

        LocalDateTime checkIn = null;
        LocalDateTime checkOut = null;

        if (data.get("checkInTime") != null && !data.get("checkInTime").isBlank()) {
            checkIn = LocalDateTime.parse(data.get("checkInTime"));
        }

        if (data.get("checkOutTime") != null && !data.get("checkOutTime").isBlank()) {
            checkOut = LocalDateTime.parse(data.get("checkOutTime"));
        }

        attendanceService.updateAttendanceAndFutureShifts(
                attendanceId,
                shiftId,
                checkIn,
                checkOut
        );
    }

//    @GetMapping("/attendance")
//    public String attendance(
//            @RequestParam(defaultValue = "0") int page,
//            @RequestParam(required = false) String fullName,
//            @RequestParam(required = false) String shift,
//            @RequestParam(required = false) String status,
//            Model model
//    ) {
//
////        attendanceService.deleteManagerAttendance();
////        attendanceService.generateNext7DaysForAllEmployees();
////
//        Pageable pageable = PageRequest.of(page, 5);
//
//        Page<Attendance> attendancePage =
//                attendanceService.getAttendancePage(pageable);
//
//        List<WorkShift> shiftList =
//                attendanceService.getAllShifts();
//
//        model.addAttribute("attendancePage", attendancePage);
//        model.addAttribute("attendanceList", attendancePage.getContent());
//        model.addAttribute("shiftList", shiftList);
//        model.addAttribute("currentPage", page);
//
//        return "shift/manager/attendance";
//    }

@GetMapping("/attendance")
public String attendance(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(required = false) String fullName,
        @RequestParam(required = false) String shift,
        @RequestParam(required = false) String status,
        Model model
) {

        attendanceService.deleteManagerAttendance();
        attendanceService.generateNext7DaysForAllEmployees();


    Pageable pageable = PageRequest.of(page, 5);

    Page<Attendance> attendancePage =
            attendanceService.getAttendancePage(
                    fullName,
                    shift,
                    status,
                    pageable
            );

    model.addAttribute("attendancePage", attendancePage);
    model.addAttribute("attendanceList", attendancePage.getContent());
    model.addAttribute("shiftList",
            attendanceService.getAllShifts());
    model.addAttribute("currentPage", page);

    return "shift/manager/attendance";
}
}