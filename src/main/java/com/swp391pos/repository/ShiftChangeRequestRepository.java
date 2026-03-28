package com.swp391pos.repository;

import com.swp391pos.entity.ShiftChangeRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;


public interface ShiftChangeRequestRepository
        extends JpaRepository<ShiftChangeRequest, Integer> {
    Page<ShiftChangeRequest> findByEmployeeEmployeeIdOrderByWorkDateDesc(
            Integer employeeId,
            Pageable pageable
    );

    @Query("""
           SELECT r FROM ShiftChangeRequest r
           JOIN FETCH r.employee
           JOIN FETCH r.currentShift
           JOIN FETCH r.requestedShift
           LEFT JOIN FETCH r.manager
           """)
    Page<ShiftChangeRequest> findAllWithDetails(Pageable pageable);

    @Query(value = """
        SELECT r FROM ShiftChangeRequest r
        LEFT JOIN r.employee e
        LEFT JOIN r.currentShift cs
        LEFT JOIN r.requestedShift rs
        LEFT JOIN r.manager m
        WHERE (:employeeId IS NULL OR e.employeeId = :employeeId)
        AND (:currentShiftId IS NULL OR cs.shiftId = :currentShiftId)
        AND (:requestedShiftId IS NULL OR rs.shiftId = :requestedShiftId)
        AND (:status IS NULL OR LOWER(r.status) = LOWER(:status))
        ORDER BY r.workDate DESC
    """,
                countQuery = """
        SELECT COUNT(r) FROM ShiftChangeRequest r
        LEFT JOIN r.employee e
        LEFT JOIN r.currentShift cs
        LEFT JOIN r.requestedShift rs
        WHERE (:employeeId IS NULL OR e.employeeId = :employeeId)
        AND (:currentShiftId IS NULL OR cs.shiftId = :currentShiftId)
        AND (:requestedShiftId IS NULL OR rs.shiftId = :requestedShiftId)
        AND (:status IS NULL OR LOWER(r.status) = LOWER(:status))
    """)
        Page<ShiftChangeRequest> filterRequests(
                @Param("employeeId") Integer employeeId,
                @Param("currentShiftId") Integer currentShiftId,
                @Param("requestedShiftId") Integer requestedShiftId,
                @Param("status") String status,
                Pageable pageable
        );
}