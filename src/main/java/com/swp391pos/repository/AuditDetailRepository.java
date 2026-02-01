package com.swp391pos.repository;

import com.swp391pos.entity.AuditDetail;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditDetailRepository extends JpaRepository<AuditDetail, Long> {
}