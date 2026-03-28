package com.swp391pos.service;

import com.swp391pos.entity.Attendance;
import com.swp391pos.entity.Employee;
import com.swp391pos.entity.ShiftChangeRequest;
import com.swp391pos.repository.AttendanceRepository;
import com.swp391pos.repository.ShiftChangeRequestRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class ShiftChangeService {

    @Autowired
    private ShiftChangeRequestRepository shiftChangeRequestRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Transactional
    public void approveRequest(Integer requestId, Employee manager) {

        ShiftChangeRequest request =
                shiftChangeRequestRepository.findById(requestId)
                        .orElseThrow();

        if (!request.getStatus().equals("Pending")) {
            return;
        }

        request.setStatus("Approved");
        request.setManager(manager);
        request.setReviewedAt(LocalDateTime.now());

        Attendance attendance = attendanceRepository
                .findByEmployeeEmployeeIdAndWorkDate(
                        request.getEmployee().getEmployeeId(),
                        request.getWorkDate()
                )
                .orElse(null);

        if (attendance != null) {
            attendance.setShift(request.getRequestedShift());
            attendanceRepository.save(attendance);
        }

        shiftChangeRequestRepository.save(request);
    }
}