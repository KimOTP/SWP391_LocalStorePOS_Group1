package com.swp391pos.service;

import com.swp391pos.entity.Attendance;
import com.swp391pos.entity.Employee;
import com.swp391pos.entity.WorkShift;
import com.swp391pos.repository.AttendanceRepository;
import com.swp391pos.repository.WorkShiftRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import com.swp391pos.repository.EmployeeRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final WorkShiftRepository workShiftRepository;
    private final EmployeeRepository employeeRepository;


    public Page<Attendance> getAttendanceHistory(Integer employeeId, Pageable pageable) {
        return attendanceRepository
                .findByEmployee_EmployeeIdAndWorkDateLessThanEqualOrderByWorkDateDesc(
                        employeeId,
                        LocalDate.now(),
                        pageable
                );
    }

    // Check in
    public void checkIn(Employee employee) {
        LocalDate today = LocalDate.now();

        Attendance attendance = attendanceRepository
                .findByEmployeeAndWorkDate(employee, today)
                .orElseThrow(() -> new RuntimeException("No attendance record for today"));

        attendance.setCheckInTime(LocalDateTime.now());
        attendanceRepository.save(attendance);
    }

    // Auto mark absent
    public void autoMarkAbsent() {

        LocalDate today = LocalDate.now();
        List<Attendance> list = attendanceRepository.findByWorkDate(today);

        for (Attendance attendance : list) {

            if (attendance.getCheckInTime() == null) {
                attendance.setAutoCheckout(true);

                save(attendance); //dùng save() để áp dụng logic
            }
        }
    }

    // Lấy attendance hôm nay
    public List<Attendance> getTodayAttendance() {

        LocalDate today = LocalDate.now();

        List<Attendance> list =
                attendanceRepository.findByWorkDate(today);

        for (Attendance attendance : list) {
            save(attendance); // cập nhật lại trạng thái
        }

        //Loại bỏ MANAGER
        list.removeIf(a ->
                a.getEmployee().getRole().equals("MANAGER"));

        return list;
    }

    public void deleteManagerAttendance() {
        List<Attendance> list = attendanceRepository.findAll();

        for (Attendance attendance : list) {
            if (attendance.getEmployee().getRole()
                    .equalsIgnoreCase("Manager")) {
                attendanceRepository.delete(attendance);
            }
        }
    }

    public Attendance findById(Integer id) {
        return attendanceRepository.findById(id).orElseThrow();
    }

    public WorkShift findShiftById(Integer id) {
        return workShiftRepository.findById(id).orElseThrow();
    }

    public void save(Attendance attendance) {

        WorkShift shift = attendance.getShift();

        // Reset trước
        attendance.setIsLate(false);
        attendance.setIsEarlyLeave(false);
        attendance.setAutoCheckout(false);

        // ===== CHECK LATE (grace 10 phút) =====
        if (attendance.getCheckInTime() != null) {

            LocalTime shiftStart = shift.getStartTime();
            LocalTime checkIn = attendance.getCheckInTime().toLocalTime();

            long minutesLate = java.time.Duration
                    .between(shiftStart, checkIn)
                    .toMinutes();

            if (minutesLate > 10) {   // > 10 phút mới tính Late
                attendance.setIsLate(true);
            }
        }

        // ===== CHECK EARLY LEAVE (grace 10 phút) =====
        if (attendance.getCheckOutTime() != null) {

            LocalTime shiftEnd = shift.getEndTime();
            LocalTime checkOut = attendance.getCheckOutTime().toLocalTime();

            long minutesEarly = java.time.Duration
                    .between(checkOut, shiftEnd)
                    .toMinutes();

            if (minutesEarly > 10) {   // > 10 phút mới tính Early
                attendance.setIsEarlyLeave(true);
            }
        }

        // ===== CHECK EXPIRED =====
        if (attendance.getCheckInTime() == null) {

            if (attendance.getWorkDate().isBefore(LocalDate.now())) {
                attendance.setAutoCheckout(true);
            }
        }

        attendanceRepository.save(attendance);
    }

    public List<WorkShift> getAllShifts() {
        return workShiftRepository.findAll();
    }

    public void generateNext7DaysForAllEmployees() {

        LocalDate today = LocalDate.now();

        List<Employee> employees = employeeRepository.findAll();
        List<WorkShift> shifts = workShiftRepository.findAll();

        if (shifts.isEmpty()) {
            throw new RuntimeException("No shift configured");
        }

        WorkShift shift = shifts.get(0);

        for (int i = 0; i < 7; i++) {

            LocalDate date = today.plusDays(i);

            for (Employee employee : employees) {

                if (employee.getRole().equals("MANAGER"))
                    continue;

                boolean exists =
                        attendanceRepository
                                .existsByEmployeeAndWorkDate(employee, date);

                if (!exists) {

                    Attendance attendance = new Attendance();
                    attendance.setEmployee(employee);
                    attendance.setShift(shift);
                    attendance.setWorkDate(date);

                    attendanceRepository.save(attendance);
                }
            }
        }
    }

    public List<Attendance> searchAttendance(
            String fullName,
            String shiftName,
            String status
    ) {

        List<Attendance> list = getTodayAttendance();

        if (fullName != null && !fullName.isBlank()) {
            list = list.stream()
                    .filter(a -> a.getEmployee()
                            .getFullName()
                            .toLowerCase()
                            .contains(fullName.toLowerCase()))
                    .toList();
        }

        if (shiftName != null && !shiftName.isBlank()) {
            list = list.stream()
                    .filter(a -> a.getShift()
                            .getShiftName()
                            .equalsIgnoreCase(shiftName))
                    .toList();
        }

        if (status != null && !status.isBlank()) {

            list = list.stream().filter(a -> {

                if (status.equals("Expired")) return a.getAutoCheckout();
                if (status.equals("Late")) return a.getIsLate();
                if (status.equals("Early Leave")) return a.getIsEarlyLeave();
                if (status.equals("Normal"))
                    return !a.getIsLate() && !a.getIsEarlyLeave() && !a.getAutoCheckout();

                return true;
            }).toList();
        }

        return list;
    }

    //Cập nhât attendance và shift tương lai
    public void updateAttendanceAndFutureShifts(
            Integer attendanceId,
            Integer shiftId,
            LocalDateTime checkInTime,
            LocalDateTime checkOutTime
    ) {

        Attendance current = attendanceRepository
                .findById(attendanceId)
                .orElseThrow();

        WorkShift newShift = workShiftRepository
                .findById(shiftId)
                .orElseThrow();

        Employee employee = current.getEmployee();
        LocalDate selectedDate = current.getWorkDate();

        // ===== UPDATE CURRENT DAY =====
        current.setShift(newShift);
        current.setCheckInTime(checkInTime);
        current.setCheckOutTime(checkOutTime);
        save(current);

        // ===== UPDATE FUTURE DAYS =====
        List<Attendance> futureList =
                attendanceRepository
                        .findByEmployeeAndWorkDateGreaterThanEqual(
                                employee,
                                selectedDate.plusDays(1)
                        );

        for (Attendance a : futureList) {
            a.setShift(newShift);
            save(a);
        }
    }
}