package com.swp391pos.repository;

import com.swp391pos.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Integer> {
    Optional<Account> findByUsername(String username);

    boolean existsByUsernameAndEmployee_EmployeeIdNot(String username, Integer employeeId);

    Optional<Account> findByEmployee_Email(String email);

    Optional<Account> findByEmployee_EmployeeId(Integer employeeId);
}