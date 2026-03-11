package com.swp391pos.repository;

import com.swp391pos.entity.Attendance;
import com.swp391pos.entity.Employee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendanceRepository extends JpaRepository<Attendance, Integer> {
    Optional<Attendance> findByEmployeeAndWorkDate(Employee employee, LocalDate workDate);

    boolean existsByEmployeeAndWorkDate(Employee employee, LocalDate workDate);

    Page<Attendance> findByWorkDate(LocalDate workDate, Pageable pageable);

    Page<Attendance> findByEmployee_EmployeeIdAndWorkDateLessThanEqualOrderByWorkDateDesc(
            Integer employeeId,
            LocalDate date,
            Pageable pageable
    );

    List<Attendance> findByEmployeeAndWorkDateGreaterThanEqual(
            Employee employee,
            LocalDate date
    );

    @Query("""
        SELECT a FROM Attendance a
        WHERE a.employee = :employee
        AND a.workDate BETWEEN :from AND :to
    """)
    List<Attendance> findHistory(
            @Param("employee") Employee employee,
            @Param("from") LocalDate from,
            @Param("to") LocalDate to
    );

    @Query("""
    SELECT a FROM Attendance a
    WHERE
        (:fullName IS NULL OR LOWER(a.employee.fullName) LIKE LOWER(CONCAT('%', :fullName, '%')))
        AND (:shift IS NULL OR a.shift.shiftName = :shift)
        AND (
            :status IS NULL
            OR (:status = 'LATE' AND a.isLate = true)
            OR (:status = 'EARLY_LEAVE' AND a.isEarlyLeave = true)
            OR (:status = 'NORMAL' AND a.isLate = false AND a.isEarlyLeave = false)
        )
        AND a.workDate = CURRENT_DATE
    ORDER BY a.workDate DESC
    """)
    Page<Attendance> searchAttendance(
            @Param("fullName") String fullName,
            @Param("shift") String shift,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate,
            @Param("status") String status,
            Pageable pageable
    );

    List<Attendance> findTop7ByEmployeeAndWorkDateGreaterThanEqualOrderByWorkDateAsc(
            Employee employee,
            LocalDate workDate
    );

    @Query("""
       SELECT a.shift.shiftName
       FROM Attendance a
       WHERE a.employee.employeeId = :empId
       ORDER BY a.workDate DESC
    """)
        List<String> findLatestShift(Integer empId, Pageable pageable);

    Optional<Attendance>
    findByEmployeeEmployeeIdAndWorkDate(
            Integer employeeId,
            LocalDate workDate
    );
}