package com.swp391pos.repository;

import com.swp391pos.entity.AuditSession;
import com.swp391pos.entity.StockIn;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AuditSessionRepository extends JpaRepository<AuditSession, Integer> {
    @Query("SELECT a FROM AuditSession a WHERE a.status.transactionStatusId = :statusId")
    List<AuditSession> findByStatusId(@Param("statusId") Integer statusId);
    AuditSession findByAuditId(int auditId);

}