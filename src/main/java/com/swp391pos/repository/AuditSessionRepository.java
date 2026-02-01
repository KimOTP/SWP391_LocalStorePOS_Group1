package com.swp391pos.repository;

import com.swp391pos.entity.AuditSession;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AuditSessionRepository extends JpaRepository<AuditSession, Integer> {
}