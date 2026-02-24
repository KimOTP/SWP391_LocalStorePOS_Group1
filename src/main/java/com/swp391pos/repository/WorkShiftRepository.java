package com.swp391pos.repository;

import com.swp391pos.entity.WorkShift;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WorkShiftRepository extends JpaRepository<WorkShift, Integer> {
    Optional<WorkShift> findByShiftNameIgnoreCase(String shiftName);
}