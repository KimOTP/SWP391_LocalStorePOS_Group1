package com.swp391pos.repository;

import com.swp391pos.entity.ShiftChangeRequest;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShiftChangeRequestRepository extends JpaRepository<ShiftChangeRequest, Integer> {
}