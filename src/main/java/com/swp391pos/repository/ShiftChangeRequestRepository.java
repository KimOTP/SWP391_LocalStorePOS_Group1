package com.swp391pos.repository;

import com.swp391pos.entity.ShiftChangeRequest;
import com.swp391pos.entity.Employee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ShiftChangeRequestRepository
        extends JpaRepository<ShiftChangeRequest, Integer> {
    Page<ShiftChangeRequest> findByEmployeeEmployeeIdOrderByWorkDateDesc(
            Integer employeeId,
            Pageable pageable
    );
}