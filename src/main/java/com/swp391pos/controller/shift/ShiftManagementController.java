package com.swp391pos.controller.shift;

import com.swp391pos.entity.WorkShift;
import com.swp391pos.repository.WorkShiftRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.util.List;

@Controller
@RequestMapping("/shift")
@RequiredArgsConstructor
public class ShiftManagementController {

    private final WorkShiftRepository workShiftRepository;

    // Hiển thị danh sách
    @GetMapping("/manager/shift_management")
    public String shiftManagement(Model model) {
        List<WorkShift> list = workShiftRepository.findAll();
        model.addAttribute("shiftList", list);
        return "shift/manager/shift_management";
    }

    // Update shift (AJAX)
    @PostMapping("/update")
    @ResponseBody
    public String updateShift(@RequestParam Integer id,
                              @RequestParam String name,
                              @RequestParam String start,
                              @RequestParam String end) {

        WorkShift shift = workShiftRepository.findById(id).orElse(null);
        if (shift == null) return "error";

        shift.setShiftName(name);
        shift.setStartTime(java.time.LocalTime.parse(start));
        shift.setEndTime(java.time.LocalTime.parse(end));

        workShiftRepository.save(shift);

        return "success";
    }
}