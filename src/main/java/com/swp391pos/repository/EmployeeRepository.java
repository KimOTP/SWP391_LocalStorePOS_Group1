package com.swp391pos.repository;

import com.swp391pos.entity.Employee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface EmployeeRepository extends JpaRepository<Employee, Integer> {
    @Query("""
        SELECT e FROM Employee e
        WHERE (:fullName IS NULL OR LOWER(e.fullName) LIKE LOWER(CONCAT('%', :fullName, '%')))
        AND (:role IS NULL OR e.role = :role)
        AND (:status IS NULL OR e.status = :status)
        AND (:from IS NULL OR e.createdAt >= :from)
        AND (:to IS NULL OR e.createdAt < :to)
    """)
    Page<Employee> searchEmployee(
            @Param("fullName") String fullName,
            @Param("role") String role,
            @Param("status") Boolean status,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to,
            Pageable pageable
    );

    Optional<Employee> findByEmail(String email);

}