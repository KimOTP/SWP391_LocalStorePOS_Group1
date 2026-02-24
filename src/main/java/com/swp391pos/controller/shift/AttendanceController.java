package com.swp391pos.controller.shift;

import com.swp391pos.entity.WorkShift;
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

//    @GetMapping("/manager/attendance")
//    public String attendance(Model model) {
//        attendanceService.deleteManagerAttendance();
//
//        // TẠO 7 NGÀY MỖI LẦN VÀO TRANG
//        attendanceService.generateNext7DaysForAllEmployees();
//
//        List<Attendance> list = attendanceService.getTodayAttendance();
//        List<WorkShift> shiftList = attendanceService.getAllShifts();
//
//        model.addAttribute("attendanceList", list);
//        model.addAttribute("shiftList", shiftList);
//
//        return "shift/manager/attendance";
//    }

//    @PostMapping("/manager/attendance/update")
//    @ResponseBody
//    public void update(@RequestBody Map<String, String> data) {
//
//        Integer attendanceId = Integer.parseInt(data.get("attendanceId"));
//        Integer shiftId = Integer.parseInt(data.get("shiftId"));
//
//        LocalDateTime checkIn =
//                LocalDateTime.parse(data.get("checkInTime"));
//
//        LocalDateTime checkOut =
//                LocalDateTime.parse(data.get("checkOutTime"));
//
//        Attendance attendance =
//                attendanceService.findById(attendanceId);
//
//        WorkShift shift =
//                attendanceService.findShiftById(shiftId);
//
//        attendance.setShift(shift);
//        attendance.setCheckInTime(checkIn);
//        attendance.setCheckOutTime(checkOut);
//
//        attendanceService.save(attendance);
//    }

    @PostMapping("/manager/attendance/update")
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

    @GetMapping("/manager/attendance")
    public String attendance(
            @RequestParam(required = false) String fullName,
            @RequestParam(required = false) String shift,
            @RequestParam(required = false) String status,
            Model model
    ) {

        attendanceService.deleteManagerAttendance();
        attendanceService.generateNext7DaysForAllEmployees();

        List<Attendance> list =
                attendanceService.searchAttendance(fullName, shift, status);

        List<WorkShift> shiftList =
                attendanceService.getAllShifts();

        model.addAttribute("attendanceList", list);
        model.addAttribute("shiftList", shiftList);

        return "shift/manager/attendance";
    }
}