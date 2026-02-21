package com.swp391pos.repository;

import com.swp391pos.entity.Account;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Integer> {
    Optional<Account> findByUsername(String username);

    Optional<Account> findByEmployee_Email(String email);

    Optional<Account> findByEmployee_EmployeeId(Integer employeeId);

    @Query("""
        SELECT a FROM Account a
        WHERE (:from IS NULL OR a.employee.createdAt >= :from)
        AND (:to IS NULL OR a.employee.createdAt <= :to)
    """)
    Page<Account> filterByCreatedDate(
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to,
            Pageable pageable
    );
}