package com.swp391pos.repository;

import com.swp391pos.entity.InvLogHeader;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InvLogHeaderRepository extends JpaRepository<InvLogHeader, Long> {
}