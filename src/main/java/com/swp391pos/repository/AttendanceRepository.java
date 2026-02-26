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

    List<Attendance> findByWorkDate(LocalDate workDate);

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
        a.workDate <= CURRENT_DATE
        AND (:fullName IS NULL OR LOWER(a.employee.fullName) LIKE LOWER(CONCAT('%', :fullName, '%')))
        AND (:shift IS NULL OR a.shift.shiftName = :shift)
        AND (:fromDate IS NULL OR a.workDate >= :fromDate)
        AND (:toDate IS NULL OR a.workDate <= :toDate)
    ORDER BY a.workDate DESC
""")
    Page<Attendance> searchAttendance(
            @Param("fullName") String fullName,
            @Param("shift") String shift,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate,
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